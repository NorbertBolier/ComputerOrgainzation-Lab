#ifdef MACOS
    .global _my_factorial
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_factorial
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
prompt:
    .asciz "Enter a number: "
input:
    .asciz "%lu"
output:
    .asciz "%lu! = %lu"


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
    popq    %r12
    
    movq    %r12, %rdi
    call    my_factorial

    leaq    output(%rip), %rdi
    movq    %r12, %rsi
    movq    %rax, %rdx
    movb    $0, %al
    call    printf

    movq    $0, %rax
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret

# uint64_t my_factorial(uint64_t n)
_my_factorial:
my_factorial:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    cmpq    $1, %rdi
    jg     else
    je      ifcode
    cmpq    $0, %rdi
    je      ifcode

ifcode:
    movq    $1, %rax
    jmp     end

else:
    movq    %rdi, %rsi
    decq    %rdi
    call    my_factorial            # n * n-1
    imul    %rsi, %rax
    incq    %rsi
    jmp     end

end:
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp  
    ret
