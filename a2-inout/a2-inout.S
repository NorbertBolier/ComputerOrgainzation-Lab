#ifdef MACOS
    .global _my_inc
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_inc
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
# [constants/strings]
prompt:
    .asciz "Enter a number: "
incremented_number:
    .asciz "The incremented number is: %ld"

input:
    .asciz "%ld"

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
    popq    %rdi
    
    call my_inc
    movq    %rax, %rsi

    leaq    incremented_number(%rip), %rdi
    movb    $0, %al
    call    printf

    movq    $0, %rax  
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret

# int64_t my_inc(int64_t n)
_my_inc:
my_inc:
    # Implement me!
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    incq    %rdi 
    movq    %rdi, %rax

    movq    %rbp, %rsp              # Epilogue
    popq    %rbp 
    ret
    
# make a2-inout/a2-inout && ./a2-inout/a2-inout