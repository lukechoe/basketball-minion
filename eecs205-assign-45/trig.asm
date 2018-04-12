; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES ebx ecx edx esi angle:FXPT

LOCAL i: DWORD, PI_three_fourth ;Local declarations

	mov esi, angle
	mov ecx, PI
	mov PI_three_fourth, 0
	add PI_three_fourth, ecx
	mov ecx, PI_HALF
	add PI_three_fourth, ecx ;;Initializes local variable to be 3*pi/4

	eval:
	xor eax, eax ;;Clear eax
	cmp esi, 0   ;;Check if angle is negative
	jl increase
	cmp esi, PI_HALF  ;;Check if angle is between 0 and pi/2
	jl q1
	cmp esi, PI       ;;Check if angle is between pi/2 and PI
	jl q2
	cmp esi, PI_three_fourth  ;;Check if angle is between pi and 3*pi/4
	jl q3
	cmp esi, TWO_PI           ;;Check if angle is between 3*pi/4 and 2pi
	jl q4
	cmp esi, TWO_PI           ;;Checks if angle is greater than 2pi
	jge reduce

	q1: ;;only for angles in quadrant one (0 to pi/2)
	mov eax, PI_INC_RECIP       
	imul esi                    ;;Multiple recip by angle to get index
 	movzx ecx, [SINTAB+edx*2]   ;;Find value of sin(angle)
	mov eax, ecx				;;Store value in eax and then return
	jmp finish
	
	q2: ;;only for angles in quadrant two (pi/2 to pi)
	mov eax, PI_INC_RECIP       
	mov ebx, PI
	sub ebx, esi                ;;Trigonometry identity to get sin value
	imul ebx
	movzx ecx, [SINTAB+edx*2]   ;;Find value of sin(angle) except it is (pi - angle)
	mov eax, ecx
	jmp finish

	q3: ;;only for angles in quadrant three (pi to 3*pi/4)
	mov eax, PI_INC_RECIP
	sub esi, PI
	imul esi
	movzx ecx, [SINTAB+edx*2]
	imul ecx, -1
	mov eax, ecx
	jmp finish

	q4:
	mov eax, PI_INC_RECIP
	mov ebx, TWO_PI 
	sub ebx, esi
	imul ebx
	movzx ecx, [SINTAB+edx*2]
	imul ecx, -1
	mov eax, ecx
	jmp finish

	reduce:
	mov ebx, TWO_PI
	sub esi, ebx
	cmp esi, TWO_PI
	jge reduce
	jmp eval

	increase:
	mov ebx, TWO_PI
	add esi, ebx
	cmp esi, 0 
	jl increase
	jmp eval

finish:
	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC angle:FXPT
      
      mov esi, angle
      add esi, PI_HALF
      invoke FixedSin, esi
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
