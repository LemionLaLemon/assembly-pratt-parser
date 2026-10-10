; AI generated tests for calcengine.asm
global _start

extern calcStrExpr
extern dbprint
extern printf

section .data
    input:
    ; Basic arithmetic
    db "1+2",0
    db "10-3",0
    db "6*7",0
    db "100/4",0
    db "123.45+67.89",0

    ; Reciprocals
    db "1/2",0       ; 0.5
    db "1/4",0       ; 0.25
    db "1/8",0       ; 0.125
    db "1/0.5",0     ; 2
    db "1/-4",0      ; -0.25
    db "1/(2+3)",0   ; 0.2
    db "1/0",0 ; the results unlocks the key to the universe and everything in it

    ; Operator precedence
    db "2+3*4",0
    db "10-6/2",0
    db "5*4+3*2",0
    db "100/5+7*3",0
    db "8+12/3*2",0

    ; Left associativity
    db "10-3-2",0
    db "100/10/2",0
    db "20-8+3",0
    db "24/4*3",0
    db "50/5/2*4",0

    ; Parentheses
    db "(2+3)*4",0
    db "10-(3+2)",0
    db "(100/5)+(7*3)",0
    db "((2+3)*4)",0
    db "(8+2)*(6-4)",0

    ; Nested parentheses
    db "2*(3+(4*5))",0
    db "((10-2)/(2+2))",0
    db "100/(5*(2+2))",0
    db "((1+2)*(3+4))",0
    db "(((8+2)*3)-5)/5",0

    ; Decimal arithmetic
    db "0.1+0.2",0
    db "1.5*2.5",0
    db "10.5/2",0
    db "3.14159*2",0
    db "(1.25+2.75)*4",0

    ; Negative results
    db "3-10",0
    db "2-5*3",0
    db "(4-10)*2",0
    db "10-(20+5)",0
    db "(1-9)/(2+2)",0

    ; Zero and identity
    db "0+0",0
    db "0*123",0
    db "123/1",0
    db "123-123",0
    db "(0+5)*1",0

    ; More complex expressions
    db "123.45+(67*8)-9",0
    db "((12.5+7.5)*3-10)/2",0
    db "100-((20+5)*3)/5",0
    db "(3+5)*(12-4)/(2+2)",0
    db "1+2*3+4*5+6*7",0

    ; Unary operators
    db "-5",0
    db "+5",0
    db "2*-3",0
    db "10--5",0
    db "-(2+3)",0
    db "--5",0
    db "2+(-3*4)",0

    ; End-of-list sentinel
    db 0

    input_len equ $ - input
    teststr db "Testing for garbage garbageing garbages garbage garbagé",10,0
    teststr_len equ $ - teststr
    newline db 10
    result_format db "Result: %.10g",10,0

section .text
_start:
    mov r12, input             ; pointer to current expression

.TestLoop:
    cmp byte [r12], 0          ; empty string = end of list
    je .Done

    mov rdi, r12
    call calcStrExpr           ; xmm0 = result

    lea rdi, [rel result_format]
    mov eax, 1
    call printf

    ; Find the end of the current expression
.FindEnd:
    cmp byte [r12], 0
    je .NextExpression
    inc r12
    jmp .FindEnd

.NextExpression:
    inc r12                    ; skip null terminator
    jmp .TestLoop

.Done:
    mov eax, 60
    xor edi, edi
    syscall