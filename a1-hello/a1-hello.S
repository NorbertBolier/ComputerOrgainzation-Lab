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
    pushq   %rbp                    # save previous base pointer
    movq    %rsp, %rbp  
    subq    $8, %rsp


    popq    %rbp 
    ret