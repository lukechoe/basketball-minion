; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	

      
;;   For example, if your procedure uses only the eax and ebx registers
DrawLine PROC USES eax ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
;;DrawLine PROC x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD 
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

	LOCAL delta_x: DWORD, delta_y: DWORD, inc_x: DWORD, inc_y: DWORD,
      error: DWORD, curr_x: DWORD, curr_y: DWORD, prev_error: DWORD
      
	;; Place your code here
      
      mov eax, x1
      sub eax, x0
      cmp eax, 0
      jge next
      neg eax
                         ;; delta_x = abs(x1-x0)

next: mov delta_x, eax
      mov eax, y1
      sub eax, y0
      cmp eax, 0
      jge next2
      neg eax
                         ;; delta_y = abs(y1-y0)

next2:mov delta_y, eax
      mov eax, x0
      mov ebx, x1
      cmp eax, ebx
      jge e1
      mov inc_x, 1
      jmp con1                ;; inc_x = 1 else...

e1:   mov inc_x, -1           ;; inc_x = -1 

con1: mov eax, y0
      mov ebx, y1
      cmp eax, ebx
      jge e2
      mov inc_y, 1
      jmp iff                ;; inc_y = 1 else...

e2:   mov inc_y, -1           ;; inc_y = 1 

iff:  mov eax, delta_x        ;; if delta_x > delta_y
      cmp eax, delta_y
      jle e3
      mov eax, delta_x
      mov ebx, 2
      mov edx, 0
      div ebx
      mov error, eax          ;; error = delta_x/2 else...
      jmp next3

e3:   mov eax, delta_y
 
      ;;mov delta_y, eax
      ;;mov eax, delta_y
      mov edx, 0
      mov ebx, 2
      div ebx
      neg eax
      mov error, eax          ;; error = delta_y/2

next3:mov eax, x0
      mov ebx, y0
      mov curr_x, eax
      mov curr_y, ebx
      invoke DrawPixel, curr_x, curr_y, color         ;;first DrawPixel call


cycle:mov eax, curr_x         ;; while (curr_x != x1 || curr_y != y1)
      mov ebx, curr_y
      mov ecx, x1
      mov edx, y1

      cmp eax, ecx            ;; first compare
      jne do
      cmp ebx, edx            ;; second compare
      je end1
do:   invoke DrawPixel, curr_x, curr_y, color
      mov eax, error
      mov prev_error, eax
      mov eax, delta_x
      neg eax
      cmp prev_error, eax     ;;first if statement compared
      jle next4               ;; if false, jump to test second conditional
      mov eax, error          ;; continuation of first conditional
      mov edx, delta_y
      sub eax, edx
      mov error, eax
      mov eax, curr_x
      mov ebx, inc_x
      add eax, ebx
      mov curr_x, eax

next4:mov eax, prev_error     ;; Do the second if statement
      cmp eax, delta_y
      jge cycle 
      mov ecx, delta_x
      mov eax, error
      add eax, ecx
      mov error, eax
      mov eax, curr_y
      add eax, inc_y
      mov curr_y, eax
      jmp cycle               
      
end1:                         
      
      

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
