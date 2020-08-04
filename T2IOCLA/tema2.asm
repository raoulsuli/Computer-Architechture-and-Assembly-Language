%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main

xor_image:
	push ebp
	mov ebp,esp
	
	mov eax, dword [ebp + 8] ; image
	; ebp + 12 width
	; ebp + 16 height
	mov edx, dword [ebp + 20] ; the value which we use to xor
	
	xor ecx,ecx
	xor edi,edi
	xor ebx,ebx

loop:
	xor [eax + 4 * ecx], edx ; doing xor
	inc ecx   ;iterating
	inc ebx ; counting columns
	cmp ebx, dword [ebp + 12] ; comparing columns with width of the matrix
	je nextline
	cmp edi, dword [ebp + 16] ; comparing rows with the height of the matrix 
	je out
	jmp loop

nextline: 
	inc edi   ;increment the line
	mov ebx,0 ; reset the counter for columns
	jmp loop

out:
	leave
	ret

find_text:
	push ebp
	mov ebp,esp

	mov eax, dword [ebp + 8] ; image
	;ebp + 12 width
	;ebp + 16 height
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

iterate:
	cmp byte [eax + 4 * ecx], 'r' 
	je next

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12] ; img_width
	jge newline

	cmp edx, dword [ebp + 16] ; img_height
	je wrong_xor

	jmp iterate

newline:
	inc edx    ; increments the row counter
	mov ebx, 0
	jmp iterate

next:
	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline

	cmp byte [eax + 4 * ecx], 'e'
	jne not_found

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline

	cmp byte [eax + 4 * ecx], 'v'
	jne not_found

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline	

	cmp byte [eax + 4 * ecx], 'i'
	jne not_found

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline

	cmp byte [eax + 4 * ecx], 'e'
	jne not_found

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline

	cmp byte [eax + 4 * ecx], 'n'
	jne not_found

	inc ecx
	inc ebx

	cmp ebx, dword [ebp + 12]
	je newline

	cmp byte [eax + 4 * ecx], 't'
	jne iterate

	mov eax, edx ; elements index if the finding succeds
	jmp out_f

not_found:
	inc ecx
	inc ebx
	jmp iterate

wrong_xor:
	mov eax, -1 ; -1 if the finding fails

out_f:
	leave
	ret

print_text:
	push ebp
	mov ebp,esp

	mov eax, dword [ebp + 16] ; line at which we found the text
	mov ebx, dword [ebp + 12]; width of the matrix
	mul ebx
	mov ecx,eax ; the index for the beggining of the sentence
	mov eax, dword [ebp + 8] ; image

print:
	cmp byte [eax + 4 * ecx], 0  ; we found null terminator so it s done
	je done1
	PRINT_CHAR [eax + 4 * ecx] 
	inc ecx
	jmp print

done1:
	NEWLINE
	PRINT_DEC 4, [ebp + 20]
	NEWLINE
	PRINT_DEC 4, [ebp + 16]

	leave
	ret

bruteforce_singlebyte_xor:
	push ebp
	mov ebp,esp
	sub esp, 8

	xor edi,edi
	mov [ebp - 4], edi ; the value we use to xor with 

repeat:
	mov edi, [ebp - 4]  ; save the value

	push edi
	push dword [img_height]
	push dword [img_width]
	push dword [img]
	call xor_image
	add esp,16

	push dword [img_height]
	push dword [img_width]
	push dword [img]
	call find_text
	add esp,12

	cmp eax, -1 ; if eax = -1, text finding failed
	je nextone
	mov edi, [ebp - 4] ; else we found it and we will print it 
	mov [ebp - 8], eax  ; save the xor and the line in eax and edi
	jmp final

nextone:

	mov edi, [ebp - 4]	
	push edi
	push dword [img_height]
	push dword [img_width]
	push dword [img]
	call xor_image  ; revert the xor
	add esp,16

	mov edi, [ebp - 4]
	inc edi
	mov [ebp - 4], edi
	jmp repeat

final:
	leave
	ret

morse_encrypt:
	push ebp
	mov ebp,esp

	mov eax, dword [ebp + 8]; img given
	mov ebx, dword [ebp + 12] ; *msg given as a parameter
	mov ecx, dword [ebp + 16] ; byte id
	xor edx,edx

encrypt:
	cmp byte [ebx + edx], 0 ; end of text
	je out_of_func

	cmp byte [ebx + edx], 'A' ; comparing each letter of the alphabet
	jne Bletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Bletter:
	cmp byte [ebx + edx], 'B'
	jne Cletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Cletter:
	cmp byte [ebx + edx], 'C'
	jne Dletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Dletter:
	cmp byte [ebx + edx], 'D'
	jne Eletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Eletter:
	cmp byte [ebx + edx], 'E'
	jne Fletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Fletter:
	cmp byte [ebx + edx], 'F'
	jne Gletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt  

Gletter:
	cmp byte [ebx + edx], 'G'
	jne Hletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx 

	inc edx

	jmp encrypt 

Hletter:
	cmp byte [ebx + edx], 'H'
	jne Iletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Iletter:
	cmp byte [ebx + edx], 'I'
	jne Jletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt  

Jletter:
	cmp byte [ebx + edx], 'J'
	jne Kletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Kletter:
	cmp byte [ebx + edx], 'K'
	jne Lletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Lletter:
	cmp byte [ebx + edx], 'L'
	jne Mletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Mletter:
	cmp byte [ebx + edx], 'M'
	jne Nletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx 

	inc edx

	jmp encrypt

Nletter:
	cmp byte [ebx + edx], 'N'
	jne Oletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt  

Oletter:
	cmp byte [ebx + edx], 'O'
	jne Pletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Pletter:
	cmp byte [ebx + edx], 'P'
	jne Qletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Qletter:
	cmp byte [ebx + edx], 'Q'
	jne Rletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Rletter:
	cmp byte [ebx + edx], 'R'
	jne Sletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Sletter:
	cmp byte [ebx + edx], 'S'
	jne Tletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Tletter:
	cmp byte [ebx + edx], 'T'
	jne Uletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Uletter:
	cmp byte [ebx + edx], 'U'
	jne Vletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Vletter:
	cmp byte [ebx + edx], 'V'
	jne Wletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Wletter:
	cmp byte [ebx + edx], 'W'
	jne Xletter

	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Xletter:
	cmp byte [ebx + edx], 'X'
	jne Yletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt 

Yletter:
	cmp byte [ebx + edx], 'Y'
	jne Zletter

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

Zletter:
	cmp byte [ebx + edx], 'Z'
	jne comma

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx 
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx

	jmp encrypt

comma:
	cmp byte [ebx + edx], ',' ; finding a comma
	jne encrypt

	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '.'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], '-'
	inc ecx
	mov byte [eax + 4 * ecx], ' '
	inc ecx

	inc edx
	jmp encrypt    

out_of_func:
	mov byte [eax + 4 *(ecx - 1)], 0 ; putting the null terminator
	leave
	ret

lsb_encode:
	push ebp
	mov ebp,esp
	sub esp,4

	mov eax, dword [ebp + 8] ; img
	mov ebx, dword [ebp + 12] ; *msg given as a parameter
	mov ecx, dword [ebp + 16] ; byte id
	dec ecx

	xor edx,edx
	xor edi,edi

	mov dl, 0b10000000 ; this is the mask i chose
	mov byte [ebp - 4], dl ; save it for further use

check:	
	test byte [ebx + edi], dl ; test if the msg given has a bit set
	jnz positive ; positive means the bit is 1

	and byte [eax + 4 * ecx], 0b11111110 ; do the lsb 0

	jmp increment ; loop

positive:
	or byte [eax + 4 * ecx], 0b00000001 ; do the lsb 1

increment:
	inc ecx
	shr dl,1

	cmp dl, 0
	je next_byte ; iterate through the message/word

	jmp check

next_byte:
	mov dl, byte [ebp - 4]
	inc edi

	cmp byte [ebx + edi], 0
	je out_ff

	jmp check

out_ff:
	and byte [eax + 4 * ecx], 0b11111110 ; print 8 0's ( null terminator)
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110
	inc ecx
	and byte [eax + 4 * ecx], 0b11111110

	leave
	ret

lsb_decode:
	push ebp
	mov ebp,esp

	mov ebx, dword [ebp + 8] ;img
	mov ecx, dword [ebp + 12] ; counter
	dec ecx

	xor eax,eax
	xor edx,edx
	xor edi,edi

	mov eax,1 ; we use eax to add values which eventually create the byte needed
	mov dl,7 ; counter for the bits

find:
	test byte [ebx + 4 * ecx], 0b00000001
	jnz poz

	test byte [ebx + 4 * (ecx + 1)], 0b00000001
	jnz back

	test byte [ebx + 4 * (ecx + 2)], 0b00000001
	jnz back

	test byte [ebx + 4 * (ecx + 3)], 0b00000001
	jnz back

	test byte [ebx + 4 * (ecx + 4)], 0b00000001
	jnz back

	test byte [ebx + 4 * (ecx + 5)], 0b00000001
	jnz back

	test byte [ebx + 4 * (ecx + 6)], 0b00000001
	jnz back

	cmp dl,1 ; if it's the last bit it means we stop and print the last letter
	je escape

	test byte [ebx + 4 * (ecx + 7)], 0b00000001
	jz outfunc	

back:
	dec dl

	inc ecx
	jmp test

poz:
	cmp dl, 7 ; shift with the correct value
	je do7
	cmp dl, 6
	je do6
	cmp dl, 5
	je do5
	cmp dl, 4
	je do4
	cmp dl, 3
	je do3
	cmp dl, 2
	je do2
	cmp dl ,1
	je do1
	jmp back_at

do7:
	shl eax, 7
	jmp back_at
do6:
	shl eax,6
	jmp back_at
do5:
	shl eax,5
	jmp back_at
do4:
	shl eax,4
	jmp back_at
do3:
	shl eax,3
	jmp back_at
do2:
	shl eax,2
	jmp back_at
do1:
	shl eax,1

back_at:

	shl eax, 0
	add edi,eax

	mov eax,1

	dec dl
	inc ecx
	jmp test

test:
	cmp dl, -1
	jne find

escape:
	PRINT_CHAR edi

	mov edi,0
	mov dl,7
	jmp find

outfunc:

	leave
	ret
find_max: ; a function that finds the maximum value out of a matrix 
	push ebp 
	mov ebp,esp
	add esp,4

	mov ebx, dword [ebp + 12]
	mov eax, dword [ebp + 16]

	mul ebx

	mov [ebp - 4], eax

	xor eax,eax
	xor ebx,ebx

	mov eax, dword [ebp + 8]
	xor ecx,ecx
	xor edi,edi


do_again:
	cmp ecx, [ebp - 4]
	je out_fff
	cmp edi, [eax + 4 * ecx]
	jl update
	inc ecx
	jmp do_again

update:
	mov edi, [eax + 4 * ecx]
	inc ecx
	jmp do_again

out_fff:
	mov eax,edi
	leave
	ret 

blur:
	push ebp
	mov ebp,esp
	sub esp,16

	;ebp + 12 width
	;ebp + 16 height

	mov eax, dword [ebp + 12] ; width
	dec eax
	mov [ebp - 4], eax ; width - 1
	mov eax, dword [ebp + 16] ; height
	dec eax
	mov [ebp - 8], eax ; height - 1

	mov byte [ebp - 12], 5 ; dividend

	push dword [ebp + 16]
	push dword [ebp + 12]
	push dword [img]
	call find_max
	add esp, 12

	xor ecx,ecx
	xor edx,edx
	xor edi,edi

	PRINT_STRING "P2"
	NEWLINE
	PRINT_DEC 4, [ebp + 12]
	PRINT_CHAR " "
	PRINT_DEC 4, [ebp + 16]
	NEWLINE
	PRINT_DEC 4, eax
	NEWLINE
;PRINTING THE BEGGINING OF THE OUTPUT
	xor eax,eax
	mov ebx, dword [ebp + 8] ; image

move:
	cmp edi, 0 ; if it's the first row we print it
	je iterate_print
	cmp edi, [ebp - 8] ; if it's the last row we print it and exit
	je iterate_print_final
	cmp edx, 0 ; if it's the first column we print it
	je iterate_print
	cmp edx, [ebp - 4] ; if it's the last column we print it
	je iterate_print

	mov eax, [ebx + 4 * ecx] ; the element 
	add eax, [ebx + 4 * (ecx + 1)] ; the element to the right
	add eax, [ebx + 4 * (ecx - 1)] ; -""-- left

	add ecx, [ebp + 12]
	add eax, [ebx + 4 * ecx] ;- "" up

	sub ecx, [ebp + 12]
	sub ecx, [ebp + 12]

	add eax, [ebx + 4 * ecx] ; -""" down
	add ecx, [ebp + 12]

	mov [ebp - 16], edx ; save the value of edx
                            ;because cdq erases it
	cdq
	idiv dword [ebp - 12] ;divide by 5 ( nr of elements)

	mov edx, [ebp - 16] ; reassign the value
	
	PRINT_DEC 4, eax ; print the value
	PRINT_CHAR " "

	xor eax,eax	

	inc ecx
	inc edx

	cmp edx, [ebp + 12]
	je nextline12

	jmp move

iterate_print:
	PRINT_DEC 4, [ebx + 4 * ecx] ; print the row/column
	PRINT_CHAR " "
	inc edx
	inc ecx

	cmp edx, [ebp + 12]
	je nextline12

	jmp move

iterate_print_final: ; print last row and exit
	PRINT_DEC 4, [ebx + 4 * ecx]
	PRINT_CHAR " "
	inc edx
	inc ecx
	cmp edx, [ebp + 12]
	je out_of_function
	jmp iterate_print_final

nextline12:
	NEWLINE
	inc edi
	mov edx,0
	jmp move

out_of_function:
	NEWLINE
	leave
	ret

main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    ; TODO Task1
    
    push dword [img_height]
    push dword [img_width]
    push dword [img]
    call bruteforce_singlebyte_xor
    add esp,12
    
    mov esi, eax ; esi contains a copy of the matrix 

    push edi ; edi has the xor value
    push eax ; eax has the line
    push dword [img_width]
    push dword [img]
    call print_text
    add esp,16

    mov eax, esi ; move back the matrix

	jmp done
solve_task2:
    ; TODO Task2
    
    push dword [img_height]
    push dword [img_width]
    push dword [img]
    call bruteforce_singlebyte_xor
    add esp,12

    ;edi contains xor
    ;eax contains the line on which we found the msg

    xchg edi,eax

    mov ebx, 2
    imul ebx
    add eax, 3
    mov ebx, 5
    idiv ebx
    sub eax, 4 ; calculate the new key

    xchg edi,eax

    inc eax ; write at the following line

   	mov ebx, dword [img_width]
   	mul ebx

   	mov ecx, eax

   	mov eax, dword [img]
                                    ;printing character by character
   	mov byte [eax + 4 * ecx], 'C'
   	inc ecx
   	mov byte [eax + 4 * ecx], 39
   	inc ecx
   	mov byte [eax + 4 * ecx], 'e'
   	inc ecx
   	mov byte [eax + 4 * ecx], 's'
   	inc ecx
   	mov byte [eax + 4 * ecx], 't'
   	inc ecx
   	mov byte [eax + 4 * ecx], ' '
   	inc ecx
   	mov byte [eax + 4 * ecx], 'u'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'n'
   	inc ecx
   	mov byte [eax + 4 * ecx], ' '
   	inc ecx
   	mov byte [eax + 4 * ecx], 'p'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'r'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'o'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'v'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'e'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'r'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'b'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'e'
   	inc ecx
   	mov byte [eax + 4 * ecx], ' '
   	inc ecx
   	mov byte [eax + 4 * ecx], 'f'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'r'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'a'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'n'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'c'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'a'
   	inc ecx
   	mov byte [eax + 4 * ecx], 'i'
   	inc ecx
   	mov byte [eax + 4 * ecx], 's'
   	inc ecx
   	mov byte [eax + 4 * ecx], '.'
   	inc ecx
   	mov byte [eax + 4 * ecx], 0

   	push edi
   	push dword [img_height]
   	push dword [img_width]
   	push dword [img]
   	call xor_image
   	add esp,16

   	push dword [img_height]
   	push dword [img_width]
   	push dword [img]
   	call print_image
   	add esp,12


    jmp done
solve_task3:
    ; TODO Task3

    mov eax, [ebp + 12]
    push dword [eax + 16]
    call atoi
    add esp, 4

    push eax
    mov eax, [ebp + 12]
    push dword [eax + 12]
    mov eax, dword [img]
    push eax
    call morse_encrypt
    add esp,12

   push dword [img_height]
   push dword [img_width]
   push dword [img]
   call print_image
   add esp,12

    jmp done
solve_task4:
    ; TODO Task4

    mov eax, [ebp + 12]
    push dword [eax + 16]
    call atoi
    add esp, 4

    push eax
    mov eax, [ebp + 12]
    push dword [eax + 12]
    mov eax, dword [img]
    push eax
    call lsb_encode
    add esp,12

    push dword [img_height]
    push dword [img_width]
    push dword [img]
    call print_image
    add esp,12

    jmp done
solve_task5:
    ; TODO Task5

    mov eax, [ebp + 12]
    push dword [eax + 12]
    call atoi
    add esp, 4

    push eax
    push dword [img]
    call lsb_decode
    add esp,8


    jmp done
solve_task6:
    ; TODO Task6

    push dword [img_height]
    push dword [img_width]
    push dword [img]
    call blur
    add esp,12

    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
