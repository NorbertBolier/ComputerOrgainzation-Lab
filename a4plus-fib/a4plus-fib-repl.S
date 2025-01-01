#ifdef MACOS
    .global _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_fib
    _printf: jmp printf
    _scanf: jmp scanf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
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
    .asciz "Enter an index: "
input:
    .asciz "%c"
output:
    .asciz "F_%ld = %ld\n" 
exit:
    .asciz "Exiting..."

_main:
main:
    pushq   %rbp                    
    movq    %rsp, %rbp      # Prologue
    subq    $16, %rsp       # Align stack to 16 bytes

loop_start:
    leaq    prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input(%rip), %rdi
    movq    %rsp, %rsi      # Use the pre-allocated stack space
    movb    $0, %al
    call    scanf

    # Check scanf return value
    cmpq    $1, %rax
    jne     exit_program    # Exit if scanf didn't read 1 item

    movzbl  (%rsp), %eax    # Load the character into eax

    cmpb    $'q', %al       # Compare with 'q' (or any character you want to use for exit)
    je      exit_program

    # Convert ASCII to integer (assuming digits)
    subb    $'0', %al
    movzbq  %al, %rdi       # Zero-extend to 64-bit for function call



    call    my_fib

    movq    %rax, %rdx      # Fibonacci result
    movq    %rdi, %rsi      # Input number

    leaq    output(%rip), %rdi
    movb    $0, %al
    call    printf

    jmp     loop_start

exit_program:
    leaq    exit(%rip), %rdi
    movb    $0, %al
    call    printf

    movb    $0, %al
    movq    %rbp, %rsp          # Epilogue
    popq    %rbp   
    ret

    # make make a4plus-repl

# uint64_t *my_fib(uint64_t n, uint64_t *arr, uint64_t size)
_my_fib:
my_fib:
    pushq   %rbp                  
    movq    %rsp, %rbp             
    # wrong implementation
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
    movq    %rbp, %rsp          
    popq    %rbp                   
    ret
