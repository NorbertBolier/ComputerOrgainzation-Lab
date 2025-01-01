#ifdef MACOS
    .global _main
    printf: jmp _printf
#else 
    .global main
    _printf: jmp printf
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
hello_world:
    .asciz "Computer Organization 2024\nAssignment 1 - hello\nby Norbert Bolier\n"

_main:
main:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    leaq    hello_world(%rip), %rdi
    movb    $0, %al
    call    printf

    movq    $0, %rax  
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp    
    ret

# make a1-hello/a1-hello && ./a1-hello/a1-hello