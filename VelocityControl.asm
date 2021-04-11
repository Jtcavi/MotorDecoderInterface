; Starting code with basic constants and simple subroutine
; random comment

ORG 0
Start:
	LOAD VelControlOn
	JPOS Velocity
	LOAD PosControlOn
	JPOS Position
	
Velocity:	
	IN   Switches
	;LOAD  VelControl 
	OUT   PWM
	
	; IN    Quad
	; OUT   Hex0
	CALL  ReadVelocity
	JUMP  Velocity

ReadVelocity:
	CALL	Delay
	IN		Quad
	; OUT 	Hex0
	SUB		OldPos
	; SHIFT	1
	SHIFT   5
	OUT		Hex0
	IN 		Quad 
	STORE	OldPos
	RETURN

Delay:
	OUT	Timer ; writing something to timer resets it to 0 

WaitingLoop:
	IN	Timer		; time counts up to 32 in 1 sec or at 32 Hz 
	ADDI	-1 		; waiting 1/32 of a second 
	JNEG	WaitingLoop
	RETURN
	
Position:
	IN   Switches
	; LOAD  PosControlSpeed
	OUT   PWM
	
	IN    Quad
	CALL  Abs
	OUT   Hex0
	SUB   PosControl
	JZERO End
	
	JUMP  Position
	
End:
	LOAD  Zero
	OUT   PWM
	JUMP  End
	
Abs:
	JPOS   Abs_r        ; If already positive, return
Negate:
	XOR    NegOne       ; Flip all bits
	ADDI   1            ; Add one
Abs_r:
	RETURN


; IO address constants
Switches:  EQU &H000
Hex0:      EQU &H004
Hex1:	   EQU &H005
PWM:       EQU &H021
Quad:      EQU &H0F1
Timer:	   EQU &H002

; constants
Zero:      DW 0
NegOne:    DW -1

VelControlOn:    DW 1
PosControlOn:	 DW 0
VelControl:      DW &B01111
PosControlSpeed: DW &B11001
PosControl:      DW 540
Countprev:	 	 DW 0
OldPos: 		 DW 0 