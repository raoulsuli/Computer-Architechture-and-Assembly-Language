%include "includes/io.inc"

extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

atoi:
    push ebp
    mov ebp,esp
    mov edx, dword [ebp + 8]
    mov ebx, [edx]
    xor ecx,ecx
    xor eax,eax

loop:
    movzx ecx, byte [ebx]
    cmp ecx,0
    je test_neg

    mov ecx, 10
    mul ecx

    movzx ecx, byte [ebx]
    
    cmp ecx, '-'
    je iterate
    
    sub ecx, 48
    add eax,ecx

iterate:
    inc ebx
    jmp loop

test_neg:
    mov edx, dword [ebp +8]
    mov ebx, [edx]
    movzx ecx, byte [ebx]
    cmp ecx, '-'
    jne end
    not eax
    inc eax
end:
    leave
    ret

evaluate:
    push ebp
    mov ebp,esp

    sub esp,16

    mov eax, dword [ebp + 8]
    mov ebx, [eax]
    mov ecx, [ebx]

    cmp ecx, 48
    jge trans
    cmp ecx, 42
    jl trans

operator:  
    mov [ebp - 4], eax ; radacina salvata
    
    mov [ebp - 16], ecx ;operator parinte salvat

    mov eax, [ebp - 4]
    push dword [eax + 4]
    call evaluate
    mov [ebp - 8], eax ;valoare subarbore stang
    add esp,4

    mov eax, [ebp - 4]
    push dword [eax + 8]
    call evaluate
    mov [ebp - 12], eax ; valoare subarbore drept
    add esp, 4

calculate:
    mov eax, [ebp - 16]
    
    cmp eax, '+'
    je plus
    
    cmp eax, '-'
    je minus

    cmp eax, '*'
    je multiply

    cmp eax, '/'
    je divide

    jmp exit

plus:
    xor eax,eax
    mov eax, [ebp - 8]
    add eax, [ebp - 12]
    jmp exit
        
minus:
    xor eax,eax
    mov eax, [ebp -8]
    sub eax, [ebp -12]
    jmp exit

multiply:
    xor eax,eax
    xor edx,edx
    mov eax, [ebp - 8]
    mov edx, [ebp - 12]
    imul edx
    jmp exit

divide:
    xor eax,eax
    ;xor edx,edx
    xor ecx,ecx
    ;mov edx, [ebp -8]
    mov eax, [ebp -8]
    mov ecx, [ebp -12]
    cdq
    idiv ecx
    jmp exit

trans:
    push eax
    call atoi
    add esp,4
    jmp exit
    
exit:
    leave
    ret

main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    

    push eax
    call evaluate
    add esp,4
    PRINT_DEC 4, eax
    ; Implementati rezolvarea aici:
    
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret