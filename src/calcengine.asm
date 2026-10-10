default rel
extern strtod ; C lib string to decimal :<

global calcStrExpr

section .rodata
    align 16
    sign_mask dq 0x8000000000000000, 0

section .bss
    parse_cursor resq 1

section .text
calcStrExpr: ; rdi *Buf, xmm0 float return
    mov [parse_cursor], rdi

    sub rsp, 8
    xor edi, edi
    call .ParseExpression
    add rsp, 8
    ret

    .PeekToken: ; returns current character to rax
        mov rax, [parse_cursor]
        movzx eax, byte [rax]
        ret

    .ConsumeToken: ; return current character and advance cursor
        ; store current character result from peektoken

        ; if character isnt \0
        ; move parse_cursor 1 byte

        ; return current character
        mov rax, [parse_cursor]
        movzx eax, byte [rax]

        test al, al
        jz .done

        inc qword [parse_cursor]

        .done:
            ret

    .ParseNumber: ; from current cursor position, find an operator or EOF, parse current pos to operator pos to strtod, return float
        ; old_cursor = parse_cursor
        push rbx

        mov rbx, [parse_cursor]

        mov rdi, rbx 
        lea rsi, [rel parse_cursor]
        call strtod

        cmp [parse_cursor], rbx
        je .invalid

        pop rbx
        ret

        .invalid:
            pop rbx

            ret

    .GetPrecedence: ; parse_cursor, returns rax precedence
        mov rax, [parse_cursor]
        movzx eax, byte [rax]
        
        cmp al, "+"
        je .Precedence_10
        cmp al, "-"
        je .Precedence_10
        cmp al, "*"
        je .Precedence_20
        cmp al, "/"
        je .Precedence_20

        mov rax, -1
        ret        

        .Precedence_10:
            mov rax, 10
            ret

        .Precedence_20:
            mov rax, 20
            ret

    .ParsePrimary: ; parse_cursor, xmm0 output (garbage garbage thing thing pratt eww)
        sub rsp, 8

        mov rax, [parse_cursor]
        movzx eax, byte [rax]
        
        cmp al, "("
        je .EvaluateContents
        cmp al, "-"
        je .EvaluateSubtraction
        cmp al, "+"
        je .EvaluateAddition
        cmp al, '.'
        je .ValidExpression
        cmp al, '0'
        jb .InvalidExpression
        cmp al, '9'
        ja .InvalidExpression

        .ValidExpression:
            call .ParseNumber
            jmp .PrimaryDone

        .InvalidExpression:
            ; error("INVALID_EXPRESSION") or something
            xorpd xmm0, xmm0
            jmp .PrimaryDone
        
        .EvaluateAddition:
            call .ConsumeToken
            call .ParsePrimary
            jmp .PrimaryDone

        .EvaluateSubtraction:
            call .ConsumeToken
            call .ParsePrimary
            xorpd xmm0, [rel sign_mask]
            jmp .PrimaryDone

        .EvaluateContents:
            call .ConsumeToken

            xor edi, edi
            call .ParseExpression

            mov rax, [parse_cursor]
            cmp byte [rax], ")"
            jne .InvalidExpression

            call .ConsumeToken
            jmp .PrimaryDone

        .PrimaryDone:
            add rsp, 8
            ret

    .ParseExpression: ; rdi min precedence, xmm0 calculated double
        push rbx
        push r12
        sub rsp, 24

        mov r12, rdi
        call .ParsePrimary ; left = xmm0
        movsd [rsp], xmm0

        ; while true
        .ParseLoop:
            mov rbx, [parse_cursor]
            movzx ebx, byte [rbx]
            call .GetPrecedence ; rax = precedence

            cmp rax, r12
            jl .ParseDone

            mov [rsp+8], rax
            call .ConsumeToken

            mov rdi, [rsp+8]
            inc rdi
            call .ParseExpression

            movsd xmm1, [rsp] ; left

            cmp bl, "+"
            je .ParseAdd
            cmp bl, "-"
            je .ParseSub
            cmp bl, "*"
            je .ParseMul
            cmp bl, "/"
            je .ParseDiv

            .ParseAdd:
                addsd xmm1, xmm0
                movsd [rsp], xmm1
                jmp .ParseLoop

            .ParseSub:
                subsd xmm1, xmm0
                movsd [rsp], xmm1
                jmp .ParseLoop

            .ParseMul:
                mulsd xmm1, xmm0
                movsd [rsp], xmm1
                jmp .ParseLoop

            .ParseDiv:
                divsd xmm1, xmm0
                movsd [rsp], xmm1
                jmp .ParseLoop

        .ParseDone:
            movsd xmm0, [rsp]
            add rsp, 24
            pop r12
            pop rbx
            ret

    ret