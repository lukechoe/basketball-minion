; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES edx ebx ecx esi x:DWORD, y:DWORD, color:DWORD 
	LOCAL ScreenWidth: DWORD, ScreenHeight: DWORD

	;;Check to make sure x and y are within the bounds 0,0 and 639, 479
	cmp x, 0
	jl finish
	cmp y, 0 
	jl finish
	cmp x, 640
	jge finish
	cmp y, 480
	jge finish


	mov eax, y
	mov esi, 640
	mul esi
	add eax, x     			;;puts the index of the vertical direction into eax
	
	mov edx, ScreenBitsPtr
	add eax, edx			;;adds the index of the horizontal direction into eax
	mov ecx, color
	mov BYTE PTR [eax], cl  ;;

	finish:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL dwWidth:DWORD, dwHeight:DWORD, color:BYTE, bTransparent:BYTE,
        x:DWORD, y:DWORD

  	mov esi, ptrBitmap 									;;esi now has the address of ptrBitmap in memory
  
  	mov al, (EECS205BITMAP PTR[esi]).bTransparent
  	mov bTransparent, al              					;;stores byte of transparency
  

	mov edi, xcenter
  	mov eax, (EECS205BITMAP PTR[esi]).dwWidth			;;Stores width into dwWidth
  	mov dwWidth, eax
  	sar eax, 1                                            

  	sub edi, eax                                        
  	mov x, edi											;;x holds the location of the starting point in the x-direction by subtracting width/2 from the center point


	
	mov ecx, ycenter
  	mov eax, (EECS205BITMAP PTR[esi]).dwHeight			;;Stores height into dwHeight
  	mov dwHeight,eax 
  	sar eax, 1                                                

  	sub ecx, eax                                        ;;y holds the location of the starting point in the y-direction by subtracting height/2 from the center point
  	mov y, ecx
  
  	mov ebx, 0                                          ;;counter needed for the first loop
  	mov esi, (EECS205BITMAP PTR[esi]).lpBytes           ;;esi stores start colors
  

  	Column:
      	mov edi, x                                      ;;edi stores the starting x pixel location
      	mov edx, 0                                      ;;reset the incrementer
      	
    	Row:
      		mov eax, ebx                                ;;Finds appropriate row to start invoking DrawPixel
      		imul eax, dwWidth                                    
      		add eax, edx                                ;;add the column position
      		add eax, esi                                ;;add the color start to current position (eax)

      ;; skip if transparent
      		mov al, BYTE PTR [eax]                      ;;Find the color at the current position (eax)
      		cmp al, bTransparent
      		je next


      		;;skip if x and y are out of lower bounds
      		cmp edi, 0
      		jl next
      		cmp ecx, 0
      		jl next
      		;;skip if x and y are otu of upper bounds
      		cmp edi, 640
      		jge next
      		;;skip if out of y bounds
      		cmp ecx, 480
      		jge next
      		;;Otherwise, move bTransparent into eax and invoke the DrawPixel procedure
      		movzx eax, al
      		INVOKE DrawPixel, edi, ecx, eax

    	next:
      		inc edi
      		inc edx                                         
      		cmp edx, dwWidth
      		jl Row

    inc ebx ;;incrementer meant to keep track of how many times the outer loop gets repeated 
    inc ecx ;;           
    ;;Loop through the columns again if the row is less than the height
	cmp ebx, dwHeight
    jl Column

	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cosa:FXPT, sina:FXPT, shiftX:DWORD, shiftY:DWORD, dstHeight:DWORD, dstWidth:DWORD,srcX:DWORD,srcY:DWORD, x:DWORD, y:DWORD
 
  	INVOKE FixedCos, angle
  	mov ebx, eax                                          
  	mov cosa, ebx				;;store cos(a) of angle into cosa

  	INVOKE FixedSin, angle
  	mov edi, eax                                         
  	mov sina, edi				;;store sin(a) of angle into sina

  	mov esi, lpBmp      

  	mov edx, (EECS205BITMAP PTR[esi]).dwWidth              
  	mov ecx, (EECS205BITMAP PTR[esi]).dwHeight 		             

  	;; Find shiftX
  	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
  	sal eax, 16
  	sar ebx, 1     
  	imul ebx     										
  	mov shiftX, edx 								
  	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  	sal eax, 16
  	sar edi, 1                                        
  	imul edi                                                       
  	sub shiftX, edx                   				   	;;find value of shiftx and subtract the width at that address    
  														;;multiple width by cosa/2 then take the difference of that with height*sina/2         

  	;; Find shiftY
  	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
  	mov ebx, cosa
  	mov edi, sina
  	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  	sal eax, 16                                         
  	sar ebx, 1                                               
  	imul ebx                                                
  	mov shiftY, edx   
  	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
  	sal eax, 16                                        	;;same logic for shiftY
  	sar edi, 1                                                
  	imul edi                                                  
  	add shiftY, edx                                           

  ;;distance of height and width calculated
  	mov ecx, (EECS205BITMAP PTR[esi]).dwHeight
  	add ecx, (EECS205BITMAP PTR[esi]).dwWidth
  	mov dstWidth, ecx
  	mov dstHeight, ecx
  	neg ecx

  	column:
    	mov edi, dstHeight				;;store dstheight in edi	
    	neg edi							
 

    row:
      ;;Find srcX
      	mov eax, ecx
      	sal eax, 16
      
      	imul cosa						;;multiply by cosa to get angle
      	mov srcX, edx					;;take numberical fxpt value and store it in srcX
      	mov eax, edi         
      	sal eax, 16
      	imul sina
      	add srcX, edx					;;add height and multiply by sina


      ;;Find srcY
      
      	mov eax, edi
      	sal eax, 16
      	imul cosa
      	mov srcY, edx

      	mov eax, ecx
      	sal eax, 16
      
      	imul sina  							
      	sub srcY, edx



      	;;skip to next loop if out of bounds. Compare for less than 0 and greater than width and height 
      	mov eax, xcenter
      	add eax, ecx
      	sub eax, shiftX
      	cmp eax, 0
      	jl next
      	cmp eax, 640
      	jge next
      	mov x, eax
      	mov eax, ycenter
      	add eax, edi
      	sub eax, shiftY
      	cmp eax, 0
      	jl next
      	cmp eax, 480
      	jge next
      	mov y, eax
      	mov eax, srcX
      	cmp eax, 0
      	jl next
      	cmp eax, (EECS205BITMAP PTR[esi]).dwWidth
      	jge next										;;check if eax (width) is within range of blitmap
      	mov eax, srcY
      	cmp eax, 0
      	jl next
      	cmp eax, (EECS205BITMAP PTR[esi]).dwHeight
      	jge next										;;check if eax, (height) is within range of blitmap



      	mov eax, srcY
      	imul (EECS205BITMAP PTR[esi]).dwWidth
      	add eax, srcX
      	add eax, (EECS205BITMAP PTR[esi]).lpBytes
      	mov al, BYTE PTR [eax]

      	;;If already the same as transparent then loop at next pixel
      	cmp al, (EECS205BITMAP PTR[esi]).bTransparent
      	je next
      	movzx eax, al
      	INVOKE DrawPixel, x, y, eax

      	next:
      	inc edi 
      	cmp edi, dstHeight
      	jl row

    	inc ecx					;;increment counter 
    	cmp ecx, dstWidth		;;continue until width is at the end
    	jl column

	ret 			; Don't delete this line!!!		
RotateBlit ENDP

END
