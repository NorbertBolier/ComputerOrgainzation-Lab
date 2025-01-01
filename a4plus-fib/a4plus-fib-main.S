#ifdef MACOS
    my_fib: jmp _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
    .global _main
#else
    _my_fib: jmp my_fib
    _printf: jmp printf
    _scanf: jmp scanf
    .global main
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
prompt:
    .asciz "Enter an index: "
input:
    .asciz "%ld"
output:
    .asciz "F_%ld = %ld"

_main:
main:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    leaq    prompt(%rip), %rdi
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
    movq    %r13, %rdi

    call my_fib

    movq    %rax, %rdx
    movq    %r13, %rsi

    leaq    output(%rip), %rdi
    movb    $0, %al
    call    printf

    movq    $0, %rax   
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret

    # make a4plus-fib
