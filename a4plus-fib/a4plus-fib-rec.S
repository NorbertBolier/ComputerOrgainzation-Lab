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
    pushq   %rbp                  
    movq    %rsp, %rbp             

    cmpq    $0, %rdi               
    je      zero         
    cmpq    $1, %rdi                
    je      one             

    pushq   %rdi                  
    decq    %rdi               
    call    my_fib              
    movq    %rax, %rdx           
    popq    %rdi  
    pushq   %rdx                  

    decq    %rdi                
    decq    %rdi             
    call    my_fib            

    popq    %rdx
    addq    %rdx, %rax        
    jmp     end

zero:
    movq    $0, %rax               
    jmp     end

one:
    movq    $1, %rax               
    jmp     end

end:
    movq    %rbp, %rsp             # Restore stack frame
    popq    %rbp                   # Restore base pointer
    ret