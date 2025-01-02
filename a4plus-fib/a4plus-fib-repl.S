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
current_size:
    .quad 0
array_ptr:
    .quad 0

.data
sizeof_uint64:
    .quad 8
malloc_fail_msg:
    .asciz "Memory allocation failed!\n"
malloc_sucess_msg:
    .asciz "Memory allocation Succeeded!\n"

.text
prompt:
    .asciz "Enter an index: "
input:
    .asciz "%ld"
output:
    .asciz "F_%ld = %ld\n" 
exit:
    .asciz "Exiting..."
tests:
    .asciz "are you there?? "

_main:
main:
    pushq   %rbp                    
    movq    %rsp, %rbp      
    subq    $16, %rsp

loop_start:
    leaq    prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input(%rip), %rdi
    movq    %rsp, %rsi
    movb    $0, %al
    call    scanf
    cmpq    $1, %rax
    jl      exit_program
    
    movq    (%rsp), %rdi
    movq    array_ptr(%rip), %rsi
    movq    current_size(%rip), %rdx
    movq    %rdi, %r13
    call    my_fib

    movq    %rax, %rdx
    movq    %r13, %rsi

    leaq    output(%rip), %rdi
    movb    $0, %al
    call    printf

    jmp     loop_start

exit_program:
    leaq    exit(%rip), %rdi
    movb    $0, %al
    call    printf

    movq    array_ptr(%rip), %rdi
    call    free

    movb    $0, %al
    movq    %rbp, %rsp
    popq    %rbp
    ret

    # make make a4plus-repl

# uint64_t *my_fib(uint64_t n, uint64_t *arr, uint64_t size)
_my_fib:
my_fib:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r13

    movq    %rdi, %rbx
    movq    %rsi, %r12
    movq    %rdx, %r13

    cmpq    $0, %r12
    je      first_allocation
    cmpq    %rbx, %r13
    jle     allocate_increase
    cmpq    %rbx, %r13
    jg      return_existing

first_allocation:
    movq    %rbx, %rdi
    incq    %rdi
    movq    %rdi, %r14
    imulq   sizeof_uint64(%rip), %rdi
    call    malloc
    jmp     check_alloc

allocate_increase:
    movq    %rbx, %rdi
    incq    %rdi
    movq    %rdi, %r14
    imulq   sizeof_uint64(%rip), %rdi
    call    realloc
    jmp     check_alloc

check_alloc:
    cmpq    $0, %rax
    jne     alloc_success
    # Print error message if allocation failed
    pushq   %rax
    leaq    malloc_fail_msg(%rip), %rdi
    movb    $0, %al
    call    printf
    popq    %rax
    jmp     cleanup

alloc_success:
# chekcing if allocation worked
    pushq   %rax
    leaq    malloc_sucess_msg(%rip), %rdi
    movb    $0, %al
    call    printf
    popq    %rax


    movq    %rax, %r12             # Store new array pointer
    movq    %rax, array_ptr(%rip)  # Update global array_ptr immediately
    
    # If old array was NULL, initialize F(0) and F(1)
    cmpq    $2, %r13               # Check if we need to initialize
    jge     fill_remaining
    
    # Initialize F(0) = 0, F(1) = 1
    movq    $0, (%r12)             # F(0) = 0
    movq    $1, 8(%r12)            # F(1) = 1
    movq    $2, %r13               # Start with size 2

fill_remaining:
    # Update current_size before filling
    movq    %r14, current_size(%rip)  # Update current_size before filling
    
    # Start filling from current size to i
    movq    %r13, %rcx             # Counter = current size
    cmpq    %rcx, %rbx             # Compare target index with counter
    jl      get_result             # If target index < counter, get existing result

fill_loop:
    cmpq    %rcx, %rbx           
    jl      finish               
    
    # Calculate F(n) = F(n-1) + F(n-2)
    movq    %rcx, %r15            # Current index
    
    # Get F(n-1)
    decq    %r15                  # n-1
    movq    (%r12,%r15,8), %rax   # Load F(n-1)
    
    # Get F(n-2)
    decq    %r15                  # n-2
    addq    (%r12,%r15,8), %rax   # Add F(n-2)
    
    # Store F(n)
    movq    %rcx, %r15            # Restore current index
    movq    %rax, (%r12,%r15,8)   # Store result at F(n)
    
    incq    %rcx                  # Increment counter
    jmp     fill_loop            # Continue filling

finish:
    movq    (%r12,%rbx,8), %rax   # Load F(n) for return value
    jmp     cleanup              # Jump to cleanup

get_result:
    movq    (%r12,%rbx,8), %rax   # Load F(n) for return value
    jmp     cleanup

return_existing:
    movq    (%r12,%rbx,8), %rax   # Load the actual Fibonacci number at index
    jmp     cleanup

cleanup:
    # Update globals before returning
    movq    %r12, array_ptr(%rip)  # Save array pointer
    movq    %r14, current_size(%rip) # Save new size
    
    popq    %r13
    movq    %rbp, %rsp
    popq    %rbp
    ret

# uint64_t *my_fib(uint64_t n, uint64_t *arr, uint64_t size)
_my_test:
test:
    pushq   %rax #debug
    pushq   %rdi
    leaq    tests(%rip), %rdi
    movb    $0, %al
    call    printf
    popq    %rdi
    popq    %rax