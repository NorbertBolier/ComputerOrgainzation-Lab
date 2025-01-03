#ifdef MACOS
    .global _my_diff
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    fopen: jmp _fopen
    fclose: jmp _fclose
    fgets: jmp _fgets
    fread: jmp _fread
    fprintf: jmp _fprintf
    fscanf: jmp _fscanf
    strcasecmp: jmp _strcasecmp
    strcmp: jmp _strcmp
    strcpy: jmp _strcpy
    strlen: jmp _strlen
    strncasecmp: jmp _strncasecmp
    strncmp: jmp _strncmp
    strncpy: jmp _strncpy
    strnlen: jmp _strnlen
    memset: jmp _memset
#else 
    .global my_diff
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _fopen: jmp fopen
    _fclose: jmp fclose
    _fgets: jmp fgets
    _fread: jmp fread
    _fprintf: jmp fprintf
    _fscanf: jmp fscanf
    _strcasecmp: jmp strcasecmp
    _strcmp: jmp strcmp
    _strcpy: jmp strcpy
    _strlen: jmp strlen
    _strncasecmp: jmp strncasecmp
    _strncmp: jmp strncmp
    _strncpy: jmp strncpy
    _strnlen: jmp strnlen
    _memset: jmp memset
#endif

.bss
# [unitialized static variables]

.data
read_mode:
    .asciz "r"

.LC0:
    .asciz "Debug - Pointer A: %p, Pointer B: %p\n"

.text
changestring:
    .ascii "%dc%d\n"
    .ascii "< %s\n"
    .ascii "---\n"
    .asciz "> %s\n"
matching_lines:
    .ascii "%dc%d\n"
text_line:
    .ascii "< %s\n"
seperator:
    .ascii "---\n"
tests:
    .asciz "Sucessful Open\n"
# [constants/strings]
file_opened_successfully: # file_opened_successfully
    .asciz "Debug: File opened successfully, FILE* = %p\n"
buffers_allocated_at_A_B: # buffers_allocated_at_A_B
    .asciz "Buffers allocated at: A=%p, B=%p\n"
using_buffer_at: # using_buffer_at
    .asciz "Using buffer at: %p\n"
fgets_result: # fgets_result
    .asciz "fgets result = %p\n"    
read_content: # read_content
    .asciz "Read content: '%s'\n"
strcmp_result_is:
    .asciz "strcmp result is: %d\n"
line_number:
    .asciz "Line number: %d\n"

# int my_diff(const char *a, const char *b, bool flag_i, bool flag_B)
_my_diff:
my_diff:
    pushq   %rbp
    movq    %rsp, %rbp
    
    # Align stack and make space for buffers
    subq    $2064, %rsp          # Space for two 1024-byte buffers
    movq    %rsi, %r12
    
    # Open first file
    # rdi already has first filename
    leaq    read_mode(%rip), %rsi # "r"
    call    fopen
    movq    %rax, %rbx           # Save FILE* A
    
    # Print debug for first file
    leaq    file_opened_successfully(%rip), %rdi
    movq    %rax, %rsi
    xorb    %al, %al
    call    printf
    
    # Open second file
    movq    %r12, %rdi
    leaq    read_mode(%rip), %rsi
    call    fopen
    movq    %rax, %r12
    
    # Print debug for second file
    leaq    file_opened_successfully(%rip), %rdi
    movq    %rax, %rsi
    xorb    %al, %al
    call    printf

    # Initialize buffers and print their addresses
    movq    %rsp, %r13            # buffer A
    leaq    1024(%rsp), %r14      # buffer B
    
    # Print buffer addresses
    leaq    buffers_allocated_at_A_B(%rip), %rdi
    movq    %r13, %rsi
    movq    %r14, %rdx
    xorb    %al, %al
    call    printf

    movq    $0, %r15            # line counter

compare_loop:
    # Debug print file handle
    leaq    using_buffer_at(%rip), %rdi  # r12 is pointer to second file rbx is to first
    movq    %r13, %rsi
    xorb    %al, %al
    call    printf

    incq    %r15
    leaq    line_number(%rip), %rdi
    movq    %r15, %rsi
    xorb    %al, %al
    call    printf

    # Try to read from file A
    movq    %rbx, %rdx           # FILE* A
    movq    %r13, %rdi            # buffer A
    movq    $1024, %rsi          # size
    call    fgets
    movq    %rax, 2048(%rsp) 
    
    # Debug print result
    leaq    fgets_result(%rip), %rdi
    movq    2048(%rsp), %rsi
    xorb    %al, %al
    call    printf
    leaq    read_content(%rip), %rdi
    movq    %r13, %rsi
    xorb    %al, %al
    call    printf

    movq    %r12, %rdx
    movq    %r14, %rdi
    movq    $1024, %rsi
    call    fgets
    movq    %rax, 2056(%rsp)

    leaq    fgets_result(%rip), %rdi
    movq    2056(%rsp), %rsi           # pass fgets result as argument
    xorb    %al, %al
    call    printf
    leaq    read_content(%rip), %rdi
    movq    %r14, %rsi
    xorb    %al, %al
    call    printf

    cmpq    $0, 2048(%rsp) # compare 
    je      compare_second
    jmp     compare 
compare_second:
    cmpq    $0, 2056(%rsp) #
    je      end

compare:
    # Compare the lines
    movq    %r13, %rdi            # line from file A
    movq    %r14, %rsi            # line from file B
    call    strcmp

    leaq    strcmp_result_is(%rip), %rdi
    movq    %rax, %rsi
    xorb    %al, %al
    call    printf


    cmpq    $0, %rax
    jne     print_sentences
    jmp     compare_loop

print_sentences:
    jmp     compare_loop

end:
    movq    %rbx, %rdi           # FILE* A
    call    fclose
    
    movq    %r12, %rdi           # FILE* B
    call    fclose 

    addq    $2064, %rsp
    movq    %rbp, %rsp           # Restore stack pointer
    popq    %rbp   
    ret     

# make a5-diff/a5-diff && ./a5-diff/a5-diff  ./a5-diff/a5-diff a5-diff/test1/a.txt a5-diff/test1/b.txt