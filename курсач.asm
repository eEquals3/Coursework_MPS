.386
;������ ���� ��� � �����
RomSize    EQU   4096

			ADC_InPort = 0FEh
			ButtonInPort = 0FEh
			IncDecButtonPort = 0FCh
			ADC_OutPort = 0F7h
			ADCOutPort1 = 0F7h
			ADCOutPort2 = 0FDh
			SensorsOutPort = 0FAh
			DisplayOutPort = 0FEh
			DisplayOutPowerPort = 0FCh
			DisplaySensorOutPort = 0FDh
			DisplaySensorOutPowerPort = 0FBh
			CompressorsPort = 0FAh
			NMax = 50

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����

			TemperatureFridge db ?
			TemperatureFridgeBCD db 3 dup(?)
			TemperatureFridgeBCD_Old db 3 dup(?)
			TemperatureFridgeBCD_Repair db 2 dup(?)
			SelectedTemperatureFridge db 2 dup (?)
			TemperatureFreezer db ?
			TemperatureFreezerBCD db 3 dup(?)
			TemperatureFreezerBCD_Old db 3 dup(?)
			TemperatureFreezerBCD_Repair db 2 dup (?)
			SelectedTemperatureFreezer db 2 dup (?)
			DoorFridgeOpenFlag db ?
			DoorFreezerOpenFlag db ?
			FreezingFlag db ?
			DataHexArr db 10 dup(?) 
			DataHexTabl db 10 dup(?)
			OldIncDecButtonsImage db ?
			WaitModeFridge db ?
			WaitModeFreezer db ?
			TempretureFreezerOn dw ?
			FridgeCompressor db ?
			FreezerCompressor db ?
			RepairFlag db ?
			TimerFridge dw 2 dup (?)
			TimerFreezer dw 2 dup (?)
			TimeOutFlagFridge db ?
			TimeOutFlagFreezer db ?

Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 2000h
;������ ����室��� ࠧ��� �⥪�
           dw    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;����� ࠧ������� ���ᠭ�� ����⠭�



InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:Data
		   
		   HexArr DB 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
		   HexTabl DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
		   
Initialization PROC									;���㫥��� ��� �祥�
	       mov ax, 0
		   mov RepairFlag, ah
		   mov FridgeCompressor, ah
		   mov FreezerCompressor, ah
		   mov TempretureFreezerOn, ax
		   mov TemperatureFreezer, ah
		   mov TemperatureFridge, ah
		   mov TemperatureFreezerBCD, ah
		   mov TemperatureFreezerBCD+1, ah
		   mov TemperatureFreezerBCD+2, ah
		   mov TemperatureFreezerBCD_Repair, ah
		   mov TemperatureFreezerBCD_Repair+1, ah
		   mov TemperatureFreezerBCD_Old, ah
		   mov TemperatureFreezerBCD_Old+1, ah
		   mov TemperatureFreezerBCD_Old+2, ah
		   mov TemperatureFridgeBCD, ah
		   mov TemperatureFridgeBCD+1, ah
		   mov TemperatureFridgeBCD+2, ah
		   mov TemperatureFridgeBCD_Repair, ah
		   mov TemperatureFridgeBCD_Repair+1, ah
		   mov TemperatureFridgeBCD_Old, ah
		   mov TemperatureFridgeBCD_Old+1, ah
		   mov TemperatureFridgeBCD_Old+2, ah
		   mov DoorFreezerOpenFlag, ah
		   mov DoorFridgeOpenFlag, ah
		   mov FreezingFlag, ah
		   mov SelectedTemperatureFridge, ah
		   mov SelectedTemperatureFridge+1, ah
		   mov SelectedTemperatureFreezer, ah
		   mov WaitModeFridge, ah
		   mov WaitModeFreezer, ah
		   mov ah, 1h
		   mov SelectedTemperatureFreezer+1, ah
		   mov ax, 0000h
		   mov bx, 0000h
		   mov TimerFridge, ax
		   mov TimerFridge+2, bx
		   mov TimerFreezer, ax
		   mov TimerFreezer+2, bx
		   call CopyArr
		   Ret
Initialization ENDP	 

ButtonsInput PROC									;��ࠡ�⪠ ������ ������/������� ���३, �.�. �� ������ ०��� � �� �� �㦭� ��ࠡ�⪠ �ॡ���� � �஭⮢
		   in al, ButtonInPort
		   not al
		   test al, 01h
		   jz NoDoorFridgeOpen
		   mov DoorFridgeOpenFlag, 01h
NoDoorFridgeOpen:
		   test al, 02h
		   jz NoDoorFreezerOpen
		   mov DoorFreezerOpenFlag, 01h
NoDoorFreezerOpen:
		   test al, 04h		   
		   jz NoFreezingFlag
		   mov FreezingFlag, 01h
NoFreezingFlag:		   
		   Ret
ButtonsInput ENDP 


ContactBounceSupressing PROC 
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
		   not al
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
		   Ret
ContactBounceSupressing ENDP


IncDecButtonsInput PROC
		   mov dx, IncDecButtonPort
		   in al, dx
		   not al
		   cmp al, OldIncDecButtonsImage
		   je NoPressedButton
		   mov OldIncDecButtonsImage, al
		   cmp al, 0h
		   je NoPressedButton
		   call ContactBounceSupressing
		   
		   test al, 1h								;�஢�ઠ ���孥�� �।��� ��� 宫����쭮� ������
		   jz NoPress1
		   lea si, SelectedTemperatureFridge
		   mov ah, [si+1]
		   cmp ah, 1h
		   jne notMax1
		   mov ah, [si]
		   cmp ah, 2h
		   je NoPressedButton
NotMax1:   mov ah, [si+1]
		   mov al, [si]
		   inc al
		   AAA
		   mov [si+1], ah
		   mov [si], al
		   jmp NoPressedButton
		   
NoPress1:  test al, 2h								;�஢�ઠ ������� �।��� ��� 宫����쭮� ������
		   jz NoPress2
		   lea si, SelectedTemperatureFridge
		   mov ah, [si+1]
		   cmp ah, 0h
		   jne notMax2
		   mov ah, [si]
		   cmp ah, 0h
		   je NoPressedButton
NotMax2:   mov ah, [si+1]
		   mov al, [si]
		   dec al
		   AAS
		   mov [si+1], ah
		   mov [si], al
		   jmp NoPressedButton
		   
NoPress2:  test al, 4h								;�஢�ઠ ���孥�� �।��� ��� ��஧��쭮� ������
		   jz NoPress3
		   lea si, SelectedTemperatureFreezer
		   mov ah, [si+1]
		   cmp ah, 1h
		   jne notMax3
		   mov ah, [si]
		   cmp ah, 0h
		   je NoPressedButton
NotMax3:   mov ah, [si+1]
		   mov al, [si]
		   dec al
		   AAS
		   mov [si+1], ah
		   mov [si], al
		   jmp NoPressedButton
		   
NoPress3:  test al, 8h									;�஢�ઠ ������� �।��� ��� 宫����쭮� ������
		   jz NoPressedButton
		   lea si, SelectedTemperatureFreezer
		   mov ah, [si+1]
		   cmp ah, 2h
		   jne notMax4
		   mov ah, [si]
		   cmp ah, 5h
		   je NoPressedButton
NotMax4:   mov ah, [si+1]
		   mov al, [si]
		   inc al
		   AAA
		   mov [si+1], ah
		   mov [si], al
NoPressedButton:
		    
		   Ret
IncDecButtonsInput ENDP


AdcProcessing  PROC									;����ணࠬ�� ��� ����樨 �।�, ������ ॠ��� ���稪��
           out ADC_OutPort, al						;��।�����: ��᪠ ��� �뤥����� ��� ��⮢���� � Ready ���� (bl)
SCtrl1:    in al, ADC_InPort						;			 ��᪠ ��� ���뢠��� ᨣ���� Start (al)
           test al, bl								;			 ���� ��� ����� ���祭�� (dx)
           jz SCtrl1								; 			 ���� ���� ��� ��।�� ������ (di)
		   xor al,al		
           out ADC_OutPort, al
           in al, dx
           not al
           shr al, 0
           cmp al, 0
           jnz AllNotZero 
		   inc al          
AllNotZero:
           Ret

AdcProcessing  ENDP


ADCController PROC									;�.�. 2 ���, � �� ����ணࠬ�� ��� ��।�� ��ࠬ��஢ � ����ணࠬ�� ��� ࠡ��� � ���
		   mov al, 00000010b						;��।������ ��ࠬ���� ���ᠭ� ���
		   lea di, TemperatureFridge
		   mov dx, ADCOutPort1
		   mov bl, 40h
		   call AdcProcessing
		   not al									;������஢���� १���� ��� 宫����쭨��, �.�. ⥬������� ������⥫쭠�
		   mov [di], al
		   mov al, 00000100b
		   lea di, TemperatureFreezer
		   mov bl, 80h
		   mov dx, ADCOutPort2
		   call AdcProcessing
		   mov [di], al								;������⢨� �����ᨨ ��� ��஧��쭨��, �.�. ����⥫쭠�
		   Ret
ADCController ENDP


BinaryToBCD PROC NEAR								;����ணࠬ�� ��� �८�ࠧ������ ���筮�� ���� � BCD ��� �� ������� ��୥�
		   MOV CX, 8								;��।�����: ���� ���� ������ ⥬������� � ������� ���� (bl)
M2: 	   mov DI, si								;			 ���� �祥� �㤠 �������� १���� (si)
		   SHL BL, 1								;! �८�ࠧ������ ����� � 㯠�������� �ଠ� 
		   PUSH CX
		   MOV CX, 3
		   M1: MOV AL, [DI]
		   ADC AL, [DI]
		   DAA
		   MOV [DI], AL
		   INC DI
		   LOOP M1
		   POP CX
		   LOOP M2
		   Ret
BinaryToBCD ENDP
	
	
BinaryToBCDController PROC							;��� � � ��砥 � ���, �ணࠬ�� ��� ��।�� ���ᮢ ��� 2 ࠧ��� ���祭��
		   mov BL, TemperatureFridge
		   lea si, TemperatureFridgeBCD
		   call BinaryToBCD
		   mov BL, TemperatureFreezer
		   lea si, TemperatureFreezerBCD
		   call BinaryToBCD
		   Ret
BinaryToBCDController ENDP


UnpackingResult PROC								;�.�. BCD १���� � ��� �����������, � �ᯠ���뢠�� ���
		   mov al, [si]								;��।�����: ���� ������������� १���� (si)
		   and al, 11110000b
		   mov ah, al
		   shr ah, 4
		   mov al, [si]
		   and al, 00001111b
		   mov bl, [si+1]
		   mov [si], al
		   mov [si+1], ah
		   mov [si+2], bl
		   Ret
UnpackingResult ENDP


UnpackingResultCOntroller PROC						;��� � �� �⮣� - ����஫��� ��� ����ணࠬ�, ��।������� ��ࠬ���� ���ᠭ� ࠭��
		   lea si, TemperatureFridgeBCD
		   call UnpackingResult
		   lea si, TemperatureFreezerBCD
		   call UnpackingResult
		   Ret
UnpackingResultCOntroller ENDP


SensorTempOut PROC									;����ணࠬ�� ��� �������᪮�� �뢥����� ⥬������� �� ��������� 
           lea bx, DataHexTabl
		   mov al, 0FFh
		   out DisplaySensorOutPowerPort, al	   
           mov al, byte ptr ds:[bp+2]
           xlat	
           out DisplaySensorOutPort, al 
		   mov dl, al
		   mov al, ah        		   
           out DisplaySensorOutPowerPort, al        
           mov al, 0FFh            
           out DisplaySensorOutPowerPort, al
		   rol ah, 1
		   
		   mov al, byte ptr ds:[bp+1]                                   
           xlat	
		   or al, 10000000b
           out DisplaySensorOutPort, al 
		   mov dl, al
		   mov al, ah            
           out DisplaySensorOutPowerPort, al        
           mov al, 0FFh            
           out DisplaySensorOutPowerPort, al
		   rol ah, 1 
		   
		   mov al, byte ptr ds:[bp]                                     
           xlat	
           out DisplaySensorOutPort, al 
		   mov dl, al
		   mov al, ah            
           out DisplaySensorOutPowerPort, al        
           mov al, 0FFh            
           out DisplaySensorOutPowerPort, al
		   rol ah, 1    
           Ret
SensorTempOut ENDP


SensorTempOutControler PROC
		   mov ah, 11111110b;00000001b
		   lea bp, TemperatureFridgeBCD		   
		   call SensorTempOut
		   lea bp, TemperatureFreezerBCD
		   call SensorTempOut
		   
		   mov al, 0FFh 
		   out DisplayOutPowerPort, al
		   mov al, 01000000b						;��᮪ ��� �뢮�� �����
		   out DisplaySensorOutPort, al
		   out DisplayOutPort, al
		   mov al, 01111111b
		   out DisplaySensorOutPowerPort, al
		   mov al, 0FFh            
           out DisplaySensorOutPowerPort, al
		   out DisplayOutPowerPort, al
		   Ret
SensorTempOutControler ENDP


IndicatorTempOut PROC									;����ணࠬ�� ��� �������᪮�� �뢥����� ⥬������� �� ��������� 
           lea bx, DataHexTabl
		   mov al, 0FFh
		   out DisplayOutPowerPort, al	   
           mov al, byte ptr ds:[bp+1]
           xlat	
           out DisplayOutPort, al 
		   mov dl, al
		   mov al, ah        		   
           out DisplayOutPowerPort, al        
           mov al, 0FFh            
           out DisplayOutPowerPort, al
		   rol ah, 1

		   mov al, byte ptr ds:[bp]                                     
           xlat	
           out DisplayOutPort, al 
		   mov dl, al
		   mov al, ah            
           out DisplayOutPowerPort, al        
           mov al, 0FFh            
           out DisplayOutPowerPort, al
		   rol ah, 1    
           Ret
IndicatorTempOut ENDP


IndicatorTempOutControler PROC
		   mov ah, 11111110b;00000001b
		   lea bp, SelectedTemperatureFridge   
		   call IndicatorTempOut
		   lea bp, SelectedTemperatureFreezer
		   call IndicatorTempOut
		   Ret
IndicatorTempOutControler ENDP


ToZero Proc 										;����ணࠬ�� ��� ���⪨ �祥� ����� ��� ���४⭮� 横��筮� ࠡ��� ����ணࠬ�� �८�ࠧ������ ������
		   
		   lea si, TemperatureFridgeBCD_Old
		   lea di, TemperatureFridgeBCD
		   mov al, [di]
		   mov ah, [di+1]
		   mov bh, [di+2]
		   mov TemperatureFridgeBCD_Old, al
		   mov TemperatureFridgeBCD_Old+1, ah
		   mov TemperatureFridgeBCD_Old+2, bh
		   lea si, TemperatureFreezerBCD_Old
		   lea di, TemperatureFreezerBCD
		   mov al, [di]
		   mov ah, [di+1]
		   mov bh, [di+2]
		   mov TemperatureFreezerBCD_Old, al
		   mov TemperatureFreezerBCD_Old+1, ah
		   mov TemperatureFreezerBCD_Old+2, bh
		   mov ah, 0
		   mov TemperatureFreezerBCD, ah
		   mov TemperatureFreezerBCD+1, ah
		   mov TemperatureFreezerBCD+2, ah
		   mov TemperatureFridgeBCD, ah
		   mov TemperatureFridgeBCD+1, ah
		   mov TemperatureFridgeBCD+2, ah
		   mov DoorFreezerOpenFlag, ah
		   mov DoorFridgeOpenFlag, ah
		   mov FreezingFlag, ah
		   Ret
ToZEro ENDP   


FreezingFridge PROC
		   mov al, [si]
		   mov ah, [si+1]
		   mov bl, [di+1]
		   mov bh, [di+2]
		   test WaitModeFridge, 01h
		   jz WaitMode 
		   cmp ax, bx
		   jae NoFreezing
		   jmp next
WaitMode:  
		   cmp ax, bx
		   ja NoFreezing		   
next:	   add bp, dx
		   
		   mov al, 0
		   mov ah, [si]
		   mov bl, [di]
		   mov bh, [di+1]
		   cmp ax, bx
		   jne WaitMOdeOF
		   mov WaitModeFridge, 01h
		   Jmp NoFreezing
WaitMOdeOF:mov WaitModeFridge, 00h		   
NoFreezing:Ret
FreezingFridge ENDP

FreezingFreezer PROC
		   mov al, [si]
		   mov ah, [si+1]
		   mov bl, [di+1]
		   mov bh, [di+2]
		   dec al
		   aas
		   mov TempretureFreezerOn,ax
		   test WaitModeFreezer, 01h	   
		   jnz toTest	   
		   cmp ax, bx
		   jl toTest
		   add bp, dx 
toTest:		   
		   mov al, [si]
		   mov ah, [si+1]
		   mov bl, [di+1]
		   mov bh, [di+2]
		   sub ax, bx
		   Ja Next
		   mov WaitModeFreezer, 01h
Next:	   
		   mov al, [di+1]
		   mov ah, [di+2]
		   mov bx, TempretureFreezerOn
		   cmp ax, bx
		   jge Exit
		   mov WaitModeFreezer, 00h    
Exit:	   Ret
FreezingFreezer ENDP


FreezingCOntroller PROC
		   mov al, 0h
		   mov bp, 0h
		   mov al, FreezingFlag
		   test al, 01h
		   jnz NotFreez
		   mov al, RepairFlag
		   test al, 01h
		   jnz NotFreez
		   lea si, SelectedTemperatureFridge
		   lea di, TemperatureFridgeBCD
		   mov dx, 1h
		   call FreezingFridge
		   lea si, SelectedTemperatureFreezer
		   lea di, TemperatureFreezerBCD
		   mov dx, 2h
		   call FreezingFreezer
		   mov ax, bp
		   test al, 01h
		   jz NoFridgeCompressor
		   mov FridgeCompressor, 01h
		   jmp next1
NoFridgeCompressor:
		   mov FridgeCompressor, 00h
next1:	   test al, 02h
		   jz NoFreezerCompressor
		   mov FreezerCompressor, 02h
		   jmp next2
NoFreezerCompressor:
		   mov FreezerCompressor, 00h
next2:	 
NotFreez:  Ret
FreezingCOntroller ENDP


RepairModeFridge PROC 
		   mov al, DoorFridgeOpenFlag
		   test al, 01h
		   jnz NoDoorOpen
		   mov al, FreezingFlag
		   test al, 01h
		   jz Exit
NoDoorOpen:
		   mov TemperatureFridgeBCD_Old, 0
		   mov TemperatureFridgeBCD_Old+1, 7
		   mov TemperatureFridgeBCD_Old+2, 2 
		   lea si, TemperatureFridgeBCD
		   mov ah, [si+2]
		   mov al, [si+1]
		   inc al
		   aaa
		   mov TemperatureFridgeBCD_Repair, al
		   mov TemperatureFridgeBCD_Repair+1, ah
		   jmp ToEnd
		   
Exit:	   lea si, TemperatureFridgeBCD_Old			;
		   lea di, TemperatureFridgeBCD				;
		   mov al, [si+2]
		   mov bl, [di+2]
		   cmp al, bl
		   jl next
		   mov al, [si]								;
		   mov ah, [si+1]							;
		   mov bl, [di]								;
		   mov bh, [di+1]							;
		   cmp ax, bx								;���室 �᫨ ⥪�饥 ���祭�� ����� �।��饣�
		   jle next									;���室 �᫨ �।��饥 ���祭�� ����� ⥪�饣�
		   lea si, TemperatureFridgeBCD					;
		   lea di, TemperatureFridgeBCD_Repair			;
		   mov al, [si+1]								;
		   mov ah, [si+2]								;
		   inc al										;����䨪��� ���祭�� ��稭��
		   aaa											;
		   mov bh, SelectedTemperatureFridge+1			;
		   mov bl, SelectedTemperatureFridge			;
		   xchg ax,bx									;
		   inc al										;
		   inc al										;
		   aaa											;
		   xchg	ax, bx	   								;
		   cmp bx, ax									;
		   jg NotPossible								;
		   mov [di], al									;
		   mov [di+1], ah								;
		   jmp next		   							;
NotPossible:											;
		   mov [di], bl									;
		   mov [di+1], bh								;
next:		
		   lea si, SelectedTemperatureFridge
		   lea di, TemperatureFridgeBCD_Repair
		   mov al, [si]
		   mov ah, [si+1]
		   inc al
		   inc al
		   aaa
		   mov bl, [di]
		   mov bh, [di+1]
		   cmp ax, bx
		   jle next1
		   mov TemperatureFridgeBCD_Repair, al
		   mov TemperatureFridgeBCD_Repair+1, ah
		   
next1:	   lea si, TemperatureFridgeBCD				;
		   lea di, TemperatureFridgeBCD_Repair		;
		   mov al, [si+1]							;
		   mov ah, [si+2]							;�ࠢ����� ���祭�� ��稭�� � ⥪�饩 ⥬�������
		   mov bl, [di]								;
		   mov bh, [di+1]							;
		   cmp ax, bx								;
		   jl NoCorrectionNeeded					;���室 �᫨ ⥪�饥 ���祭�� ����� ���祭�� ��稭��
		   or bp, 80h

NoCorrectionNeeded:
ToEnd:	   Ret
RepairModeFridge ENDP


RepairModeFreezer PROC 
		   mov al, DoorFreezerOpenFlag
		   test al, 01h
		   jnz NoDoorOpen
		   mov al, FreezingFlag
		   test al, 01h
		   jz Exit
NoDoorOpen:
		   mov TemperatureFreezerBCD_Old, 0
		   mov TemperatureFreezerBCD_Old+1, 0
		   mov TemperatureFreezerBCD_Old+2, 0 
		   lea si, TemperatureFreezerBCD
		   mov ah, [si+2]
		   mov al, [si+1]
		   dec al
		   dec al
		   aas
		   mov TemperatureFreezerBCD_Repair, al
		   mov TemperatureFreezerBCD_Repair+1, ah
		   jmp ToEnd
Exit:	   lea si, TemperatureFreezerBCD_Old
		   lea di, TemperatureFreezerBCD
		   mov al, [si+2]
		   mov bl, [di+2]
		   cmp al, bl
		   jg next
		   mov al, [si]								;
		   mov ah, [si+1]							;
		   mov bl, [di]								;
		   mov bh, [di+1]							;
		   cmp ax, bx								;���室 �᫨ ⥪�饥 ���祭�� ����� �।��饣�
		   jge next									;���室 �᫨ �।��饥 ���祭�� ����� ⥪�饣�
		   lea si, TemperatureFreezerBCD					;
		   lea di, TemperatureFreezerBCD_Repair			;
		   mov al, [si+1]								;
		   mov ah, [si+2]								;
		   dec al	
		   dec al		   ;����䨪��� ���祭�� ��稭��
		   aas											;
		   mov bh, SelectedTemperatureFreezer+1			;
		   mov bl, SelectedTemperatureFreezer			;
		   xchg ax,bx									;
		   dec al										;
		   dec al										;
		   dec al										;
		   aas											;
		   xchg	ax, bx	   								;
		   cmp bx, ax									;
		   jl NotPossible								;
		   mov [di], al									;
		   mov [di+1], ah								;
		   jmp next		   								;
NotPossible:											;
		   mov [di], bl									;
		   mov [di+1], bh								;
next:		
		   lea si, SelectedTemperatureFreezer
		   lea di, TemperatureFreezerBCD_Repair
		   mov al, [si]
		   mov ah, [si+1]
		   inc al
		   inc al
		   inc al
		   aaa
		   mov bl, [di]
		   mov bh, [di+1]
		   cmp ax, bx
		   jge next1
		   mov TemperatureFreezerBCD_Repair, al
		   mov TemperatureFreezerBCD_Repair+1, ah
		   
next1:	   lea si, TemperatureFreezerBCD				;
		   lea di, TemperatureFreezerBCD_Repair		;
		   mov al, [si+1]							;
		   mov ah, [si+2]							;�ࠢ����� ���祭�� ��稭�� � ⥪�饩 ⥬�������
		   mov bl, [di]								;
		   mov bh, [di+1]							;
		   cmp ax, bx								;
		   jg NoCorrectionNeeded					;���室 �᫨ ⥪�饥 ���祭�� ����� ���祭�� ��稭��
		   or bp, 40h

NoCorrectionNeeded:
ToEnd:	   Ret
RepairModeFreezer ENDP


RepairModeController PROC
		   mov bp, 0h
		   call RepairModeFridge
		   call RepairModeFreezer
		   mov al, FreezingFlag
		   test al, 01h
		   mov al, 0h
		   jnz Exit
		   
		   mov al, 0h
		   or ax, bp
		   
		   test bp, 80h
		   jnz noFridgeCompressor
		   mov bl, DoorFridgeOpenFlag
		   test bl, 01h
		   jnz noFridgeCompressor
		   or al, FridgeCompressor
noFridgeCompressor:
		   
		   test ax, 40h
		   jnz noFreezerCompressor
		   mov bl, DoorFreezerOpenFlag
		   test bl, 01h
		   jnz noFreezerCompressor
		   or al, FreezerCompressor
noFreezerCompressor:
Exit:
		   mov bp, ax
		   call TimerRepairCOntroller
		   Ret
RepairModeController ENDP

TimerRepairFridge PROC
		   mov al, TemperatureFridgeBCD
		   mov ah, TemperatureFridgeBCD+1
		   mov bl, TemperatureFridgeBCD_Old
		   mov bh, TemperatureFridgeBCD_Old+1
		   cmp ax, bx
		   jne RepairFridgeCounter
		   mov al, TemperatureFridgeBCD+2
		   mov bl, TemperatureFridgeBCD_Old+2
		   cmp al, bl 
		   jne RepairFridgeCounter
		   
		   test bp, 0080h
		   jnz Exit
		   test bp, 0001h
		   jz Exit
		   test TimeOutFlagFridge, 01h
		   jnz TimeOut
		   
		   mov ax, TimerFridge
		   dec ax
		   mov TimerFridge, ax
		   cmp ax, 0h
		   jne Exit
		   mov ax, TimerFridge+2
		   cmp ax, 0h
		   jne TimeOut
		   dec ax
		   mov TimerFridge+2, ax
		   jmp Exit
RepairFridgeCounter:
		   mov TimeOutFlagFridge, 00h
		   mov ax, 00FFFh
		   mov bx, 005Fh
		   mov TimerFridge, ax
		   mov TimerFridge+2, bx
		   jmp Exit
TimeOut:
		   mov TimeOutFlagFridge, 01h
		   and bp, 0000000011111110b
		   or bp, 0000000010000000b
Exit:	   Ret
TimerRepairFridge ENDP

TimerRepairFreezer PROC
		   mov al, TemperatureFreezerBCD
		   mov ah, TemperatureFreezerBCD+1
		   mov bl, TemperatureFreezerBCD_Old
		   mov bh, TemperatureFreezerBCD_Old+1
		   cmp ax, bx
		   jne RepairFridgeCounter
		   mov al, TemperatureFreezerBCD+2
		   mov bl, TemperatureFreezerBCD_Old+2
		   cmp al, bl 
		   jne RepairFridgeCounter
		   
		   test bp, 0040h
		   jnz Exit
		   test bp, 0002h
		   jz Exit
		   test TimeOutFlagFreezer, 01h
		   jnz TimeOut
		   
		   mov ax, TimerFreezer
		   dec ax
		   mov TimerFreezer, ax
		   cmp ax, 0h
		   jne Exit
		   mov ax, TimerFreezer+2
		   cmp ax, 0h
		   jne TimeOut
		   dec ax
		   mov TimerFreezer+2, ax
		   jmp Exit
RepairFridgeCounter:
		   mov TimeOutFlagFreezer, 00h
		   mov ax, 00FFFh
		   mov bx, 005Fh
		   mov TimerFreezer, ax
		   mov TimerFreezer+2, bx
		   jmp Exit
TimeOut:
		   mov TimeOutFlagFreezer, 01h
		   and bp, 0000000011111101b
		   or bp, 0000000001000000b
Exit:	   Ret
TimerRepairFreezer ENDP


TimerRepairCOntroller PROC 
		   Call TimerRepairFridge
		   Call TimerRepairFreezer
		   Ret
TimerRepairCOntroller ENDP 


LightAndModeOutput PROC								
		   mov ax, bp 								
		   Test DoorFridgeOpenFlag, 1
		   jz NoDoorFridgeOpen
		   add al, 00001000b
NoDoorFridgeOpen:
		   test DoorFreezerOpenFlag, 1
		   jz NoDoorFreezerOpen
		   add al, 00010000b
NoDoorFreezerOpen:
		   test FreezingFlag, 1
		   jz NoFreezingFlag
		   add al, 00000100b
NoFreezingFlag:
		   Out SensorsOutPort, al
		   Ret
LightAndModeOutput ENDP


CopyArr PROC
		   MOV CX, 10 ;����㧪� ����稪� 横���
		   LEA BX, HexArr ;����㧪� ���� ���ᨢ� ���
		   LEA BP, HexTabl ;����㧪� ���� ⠡���� �८�ࠧ������
		   LEA DI, DataHexArr ;����㧪� ���� ���ᨢ� ��� � ᥣ���� ������
		   LEA SI, DataHexTabl ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
M0:
		   MOV AL, CS:[BX] ;�⥭�� ���� �� ���ᨢ� � ��������
		   MOV [DI], AL ;������ ���� � ᥣ���� ������/DataHexArr
		   INC BX ;����䨪��� ���� HexArr
		   INC DI ;����䨪��� ���� DataHexArr
		   LOOP M0
			
		   MOV CX, 10 ;����㧪� ����稪� 横���
M1:
		   MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
		   MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataHexTabl
		   INC BP ;����䨪��� ���� HexTabl
		   INC SI ;����䨪��� ���� DataHexTabl
		   LOOP M1
		   XOR bp,bp
		   ret
CopyArr ENDP



Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
		   
		   call Initialization
MainLoop: 		   
		   call ButtonsInput
		   call IncDecButtonsInput
		   call ADCController
		   call BinaryToBCDController
		   call UnpackingResultCOntroller
		   call IndicatorTempOutControler
		   call SensorTempOutControler
		   call FreezingCOntroller
		   call RepairModeController   
		   call LightAndModeOutput
		   call ToZero
		   jmp MainLoop
;����� ࠧ��頥��� ��� �ணࠬ��


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
