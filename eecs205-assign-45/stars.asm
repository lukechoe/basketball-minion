; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

      invoke DrawStar, 2, 30
      invoke DrawStar, 25, 25
      invoke DrawStar, 400, 234
      invoke DrawStar, 601, 323
      invoke DrawStar, 600, 456
      invoke DrawStar, 235, 111
      invoke DrawStar, 124, 342
      invoke DrawStar, 200, 236
      invoke DrawStar, 211, 573
      invoke DrawStar, 492, 54
      invoke DrawStar, 324, 212
      invoke DrawStar, 398, 420
      invoke DrawStar, 128, 89
      invoke DrawStar, 193, 398
      invoke DrawStar, 532, 128
      invoke DrawStar, 100, 428


 

      

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
