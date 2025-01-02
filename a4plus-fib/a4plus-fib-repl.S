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
    jg      give_result

first_allocation:
    incq    %rdi
    movq    %rdi, %r14
    imulq   sizeof_uint64(%rip), %rdi
    call    malloc
    jmp     allocation_success

allocate_increase:
    movq    array_ptr(%rip), %rdi
    movq    %rbx, %rsi
    incq    %rsi
    movq    %rsi, %r14
    imulq   sizeof_uint64(%rip), %rsi
    call    realloc

allocation_success:
    movq    %rax, %r12
    cmpq    $2, %r13
    jge     calculate_increase
    
    movq    $0, (%r12)
    movq    $1, 8(%r12)
    movq    $2, %r13

calculate_increase:
    movq    %r14, current_size(%rip)
    movq    %r13, %rcx
    cmpq    %rcx, %rbx
    jl      give_result

calculate_fib:
    cmpq    %rcx, %rbx           
    jl      give_result               
    
    movq    %rcx, %r15
    
    decq    %r15
    movq    (%r12,%r15,8), %rax
    
    decq    %r15
    addq    (%r12,%r15,8), %rax
    
    movq    %rcx, %r15
    movq    %rax, (%r12,%r15,8)
    
    incq    %rcx
    jmp     calculate_fib

give_result:
    movq    (%r12,%rbx,8), %rax
    movq    %r12, array_ptr(%rip)
    movq    %r14, current_size(%rip)
    
    popq    %r13
    movq    %rbp, %rsp
    popq    %rbp
    ret