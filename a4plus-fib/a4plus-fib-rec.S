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
# [constants/strings]

# uint64_t my_fib(uint64_t n)
_my_fib:
my_fib:
    pushq   %rbp                   # Save base pointer
    movq    %rsp, %rbp             # Set new base pointer

    cmpq    $0, %rdi                # If n == 0
    je      return_zero            # Return 0
    cmpq    $1, %rdi                # If n == 1
    je      return_one             # Return 1

    pushq   %rdi                   # Save n on the stack
    decq    %rdi                   # n = n - 1
    call    my_fib                 # Call my_fib(n-1)
    movq    %rax, %rdx             # Store fib(n-1) in rdx
    popq    %rdi  
    pushq   %rdx                   # Restore n

    decq    %rdi                   # n = n - 1 (for call to fib(n-2))
    decq    %rdi                   # n = n - 2
    call    my_fib                 # Call my_fib(n-2)

    popq    %rdx
    addq    %rdx, %rax             # fib(n) = fib(n-1) + fib(n-2)
    jmp     end

return_zero:
    movq    $0, %rax               # Return 0
    jmp     end

return_one:
    movq    $1, %rax               # Return 1
    jmp     end

end:
    movq    %rbp, %rsp             # Restore stack frame
    popq    %rbp                   # Restore base pointer
    ret