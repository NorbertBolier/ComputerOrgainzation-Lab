#ifdef MACOS
    .global _my_pow
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_pow
    _printf: jmp printf
    _scanf: jmp scanf
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
base:
    .asciz "Enter a base: "
exponent:
    .asciz "Enter an exponent: "
output:
    .asciz "%ld^%ld = %ld"
input:
    .asciz "%ld"

_main:
main:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    leaq    base(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input(%rip), %rdi
    subq    $8, %rsp 
    movq    %rsp, %rsi 
    movb    $0, %al
    subq    $8, %rsp 
    call    scanf
    addq    $8, %rsp  
    popq    %r12


    leaq    exponent(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input(%rip), %rdi
    subq    $8, %rsp 
    movq    %rsp, %rsi
    movb    $0, %al  
    subq    $8, %rsp 
    call    scanf
    addq    $8, %rsp  
    popq    %r13

    movq    %r12, %rdi
    movq    %r13, %rsi
    call my_pow
    movq    %rax, %rcx

    leaq    output(%rip), %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    movb    $0, %al
    call    printf

    movq    $0, %rax  
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret

# int64_t my_pow(int64_t base, uint64_t exponent)
_my_pow:
my_pow:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 
    # Implement me! need a loop to loop to times base as many times as exponent

    movq    $300, %rax

    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret