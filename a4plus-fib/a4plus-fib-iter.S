#ifdef MACOS
    .global _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
#else 
    .global my_fib
    _printf: jmp printf
    _scanf: jmp scanf
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text

# uint64_t my_fib(uint64_t n)
_my_fib:
my_fib:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue 

    movq    $1, %rsi
    movq    $0, %rdx

    cmpq    $0, %rdi
    je      equal0
    jmp     else
equal0:
    movq    $0, %rax
    jmp     end
else:
    cmpq    $1, %rdi
    je      equal1
    jmp     loop1
equal1:
    movq    $1, %rax
    jmp     end
loop1:
    cmpq    $1, %rdi
    je      end
    addq    %rsi, %rdx
    decq    %rdi
    movq    %rdx, %rax
    jmp     loop2
loop2:
    cmpq    $1, %rdi
    je      end
    addq    %rdx, %rsi
    decq    %rdi
    movq    %rsi, %rax
    jmp     loop1
end:
    movq    %rbp, %rsp              # Epilogue
    popq    %rbp   
    ret


    # make a4plus-iter