section .data
    msg1 db 'Digite um numero: ',0
    msg2 db 'Digite outro numero: ',0
    msg3 db 'Escolha uma operacao (+, -, *, /): ',0
    msg4 db 'Deseja resultado com ponto flutuante? (s/n): ',0
    resultado_msg db 'Resultado: ',0
    newline db 10, 0
    error_msg db 'Erro: divisao por zero',0

section .bss
    num1 resb 20
    num2 resb 20
    op resb 2
    ponto resb 2
    result resb 64

section .text
    global _start

_start:
    ; Exibe msg1
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, 18
    syscall

    ; Lê num1
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 20
    syscall

    ; Exibe msg2
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, 22
    syscall

    ; Lê num2
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 20
    syscall

    ; Exibe msg3
    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, 34
    syscall

    ; Lê op
    mov rax, 0
    mov rdi, 0
    mov rsi, op
    mov rdx, 2
    syscall

    ; Exibe msg4
    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, 46
    syscall

    ; Lê ponto flutuante (s/n)
    mov rax, 0
    mov rdi, 0
    mov rsi, ponto
    mov rdx, 2
    syscall

    ; Converte num1 e num2 para inteiros
    mov rsi, num1
    call str_to_int
    mov rbx, rax

    mov rsi, num2
    call str_to_int
    mov rcx, rax

    movzx rdx, byte [op]
    cmp rdx, '+'
    je add_op
    cmp rdx, '-'
    je sub_op
    cmp rdx, '*'
    je mul_op
    cmp rdx, '/'
    je div_op
    jmp fim

add_op:
    add rbx, rcx
    mov rax, rbx
    call int_to_str
    jmp print_result

sub_op:
    sub rbx, rcx
    mov rax, rbx
    call int_to_str
    jmp print_result

mul_op:
    imul rbx, rcx
    mov rax, rbx
    call int_to_str
    jmp print_result

div_op:
    cmp rcx, 0
    je erro
    movzx rdx, byte [ponto]
    cmp dl, 's'
    je float_div
    ; Inteira
    mov rax, rbx
    cqo
    idiv rcx
    call int_to_str
    jmp print_result

float_div:
    ; Inteiros para double
    mov rax, rbx
    cvtsi2sd xmm0, rax
    mov rax, rcx
    cvtsi2sd xmm1, rax
    divsd xmm0, xmm1
    ; Converter para string
    sub rsp, 64
    mov rdi, rsp
    call float_to_str
    mov rsi, rsp
    mov rdx, 64
    call print_direct
    add rsp, 64
    jmp fim

erro:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, 22
    syscall
    jmp fim

print_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, resultado_msg
    mov rdx, 10
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 64
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    jmp fim

; Converte string para inteiro (assume \n no final)
str_to_int:
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov bl, byte [rsi]
    cmp bl, '-'
    jne .loop
    mov cl, 1
    inc rsi
.loop:
    movzx rdx, byte [rsi]
    cmp rdx, 10
    je .done
    sub rdx, '0'
    imul rax, 10
    add rax, rdx
    inc rsi
    jmp .loop
.done:
    cmp cl, 1
    jne .ret
    neg rax
.ret:
    ret

; Converte inteiro para string
int_to_str:
    mov rsi, result + 63
    mov byte [rsi], 0
    dec rsi
    mov rcx, 10
    xor rdx, rdx
    test rax, rax
    jns .loop
    neg rax
    mov rbx, 1
.loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    test rax, rax
    jnz .loop
    cmp rbx, 1
    jne .done
    mov byte [rsi], '-'
    dec rsi
.done:
    lea rsi, [rsi + 1]
    mov rdi, result
    mov rcx, 0
.copy:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    cmp al, 0
    je .end
    inc rcx
    jmp .copy
.end:
    ret

; Converte double de xmm0 para string usando syscalls (limitado, simulado)
float_to_str:
    ; simulação apenas: mostra aviso
    mov rsi, resultado_msg
    mov rdx, 10
    syscall
    mov rsi, newline
    mov rdx, 1
    syscall
    ; precisa de printf real para ser preciso
    ret

print_direct:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

fim:
    mov rax, 60
    xor rdi, rdi
    syscall
