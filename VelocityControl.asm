; Starting code with basic constants and simple subroutine
; random comment

ORG 0
Start:
	LOAD VelControlOn
	JPOS VelConvert
	LOAD PosControlOn
	JPOS Position
	
VelConvert:
	CALL  MultLoop ; converts rpm to counts per second
	OUT   Hex0
CompVel:
	LOAD  CurrOutput
	ADD   4 ; fast vel ramp
	STORE CurrOutput
	
	OUT   PWM ; out put to motor
	
	CALL  ReadVelocity ; Read velocity

	LOAD  ReadOutput ; read velocity value from timer
	SUB   VelControl ;
	JNEG  CompVel ; If speed is still too low, repeat and increment pwm by 4

	JUMP  End
	
ReadVelocity:
	CALL	Delay
	IN		Quad

	SUB		OldPos

	SHIFT   5
	OUT		Hex0
	STORE   ReadOutput
	
	IN 		Quad 
	STORE	OldPos
	RETURN

Delay:
	OUT	Timer ; writing something to timer resets it to 0 

WaitingLoop:
	IN      Timer   ; time counts up to 32 in 1 sec or at 32 Hz 
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
	
MultLoop: ; mult rpm by 9 to get cps
	LOAD   VelControl
	
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	ADD    VelControl
	
	STORE  VelControl ; stored in vel control variable
	
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
VelControl:      DW 45 ; integer between 30 and 60
PosControlSpeed: DW &B1111001
PosControl:      DW 540
Countprev:	 	 DW 0
OldPos: 		 DW 0

CurrOutput:	     DW &B0000000 ; pwm value
ReadOutput:      DW 0 ; cps value

DirectionMode:   DW 1 
ForwardMask:     DW &B010000000 ; counterclockwise movement
ReverseMask:     DW &B100000000 ; clockwise movement