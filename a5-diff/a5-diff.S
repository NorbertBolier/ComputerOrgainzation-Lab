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

.text
changestring:
    .ascii "%dc%d\n"
    .ascii "< %s\n"
    .ascii "---\n"
    .asciz "> %s\n"
tests:
    .asciz "Sucessful Open"
# [constants/strings]
debug_open:
    .asciz "Debug: File opened successfully, FILE* = %p\n"
debug_line:
    .asciz "fgets result = %p\n"    # Show the pointer returned by fgets
debug_handle:
    .asciz "Using FILE* = %p\n"
debug_content:
    .asciz "Read content: '%s'\n"

# int my_diff(const char *a, const char *b, bool flag_i, bool flag_B)
_my_diff:
my_diff:
    pushq   %rbp
    movq    %rsp, %rbp
    
    subq    $1024, %rsp
    
    movq    %rdi, %r12
    movq    %rsi, %r13
    movq    %rdx, %r14
    movq    %rcx, %r15
    
    movq    %r12, %rdi 
    leaq    read_mode(%rip), %rsi
    call    fopen
    
    movq    %r13, %rdi
    leaq    read_mode(%rip), %rsi
    call    fopen

continue_program:
    # Allocate space for line buffers
    subq    $2048, %rsp
    movq    %rsp, %r8
    leaq    1024(%rsp), %r9
    
    # Initialize line counter
    movq    $1, %r11

compare_loop:
    movq    %rbx, %rdi           # FILE* handle
    movq    %r8, %rsi            # buffer
    movq    $1024, %rdx          # max length
    call    fgets
    
    # Debug print fgets result
    movq    %rax, %r12           # save fgets result
    leaq    debug_line(%rip), %rdi
    movq    %rax, %rsi           # pass fgets result as argument
    xorb    %al, %al
    call    printf

    leaq    debug_content(%rip), %rdi
    movq    %r8, %rsi            # buffer content
    xorb    %al, %al
    call    printf

    movq    %r13, %rdi
    movq    %r9, %rsi
    movq    $1024, %rdx
    call    fgets
    movq    %rax, %r15           # holds line from B

    # Simple debug print with no arguments
    movq    %rax, %r12           # save fgets result
    leaq    debug_line(%rip), %rdi
    movq    %rax, %rsi           # pass fgets result as argument
    xorb    %al, %al
    call    printf

    # Check if either file is at the end of the file
    cmpq    $0, %r12
    je      check_b_eof
    cmpq    $0, %r15
    je      files_different

    # Compare the lines
    movq    %r8, %rdi            # line from file A
    movq    %r9, %rsi            # line from file B
    call    strcmp
    
    testq   %rax, %rax
    jz      lines_match          # if equal, continue to next line

    # Lines are different - print diff output
    leaq    changestring(%rip), %rdi
    movq    %r11, %rsi           # current line number
    movq    %r11, %rdx           # same for both in this case
    xorb    %al, %al
    call    printf
    
    # Print line from file A
    leaq    changestring+8(%rip), %rdi
    movq    %r8, %rsi
    xorb    %al, %al
    call    printf
    
    # Print separator
    leaq    changestring+16(%rip), %rdi
    xorb    %al, %al
    call    printf
    
    # Print line from file B
    leaq    changestring+24(%rip), %rdi
    movq    %r9, %rsi
    xorb    %al, %al
    call    printf

lines_match:
    incq    %r11                 # increment line counter
    jmp     compare_loop

check_b_eof:
    cmpq    $0, %r15             # check if B is also at EOF
    je      files_same           # if both at EOF, files are same
    
files_different:
    movq    $1, %rax             # return 1 if files are different
    jmp     cleanup

files_same:
    movq    %r13, %rdi
    call    fclose
    movq    %rbx, %rdi
    call    fclose
    
cleanup:
    # Restore stack and registers
    movq    %rbp, %rsp
    popq    %rbp
    ret

# make a5-diff/a5-diff && ./a5-diff/a5-diff