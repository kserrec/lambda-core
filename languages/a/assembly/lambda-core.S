# x86-64 System V / GNU assembler implementation of the Lambda Core.
#
# A term is a three-word closure:
#   0: code pointer with signature Term *(Term *self, Term *argument)
#   8: first captured term/value
#  16: second captured term/value

        .text

        .type   make_term, @function
make_term:
        pushq   %r12
        pushq   %r13
        pushq   %r14
        movq    %rdi, %r12
        movq    %rsi, %r13
        movq    %rdx, %r14
        movl    $24, %edi
        call    malloc@PLT
        testq   %rax, %rax
        je      .Lallocation_failed
        movq    %r12, 0(%rax)
        movq    %r13, 8(%rax)
        movq    %r14, 16(%rax)
        popq    %r14
        popq    %r13
        popq    %r12
        ret
.Lallocation_failed:
        call    abort@PLT
        ud2

        .type   apply, @function
apply:
        movq    0(%rdi), %rax
        jmp     *%rax

# TRUE = lambda x. lambda y. x
        .type   true_first, @function
true_first:
        movq    %rsi, %r8
        leaq    true_second(%rip), %rdi
        movq    %r8, %rsi
        xorl    %edx, %edx
        jmp     make_term

        .type   true_second, @function
true_second:
        movq    8(%rdi), %rax
        ret

# FALSE = lambda x. lambda y. y
        .type   false_first, @function
false_first:
        leaq    false_second(%rip), %rdi
        xorl    %esi, %esi
        xorl    %edx, %edx
        jmp     make_term

        .type   false_second, @function
false_second:
        movq    %rsi, %rax
        ret

# NOT = lambda b. b FALSE TRUE
        .type   not_term_code, @function
not_term_code:
        pushq   %r12
        movq    %rsi, %r12
        movq    %r12, %rdi
        leaq    FALSE_TERM(%rip), %rsi
        call    apply
        movq    %rax, %rdi
        leaq    TRUE_TERM(%rip), %rsi
        call    apply
        popq    %r12
        ret

# AND = lambda p. lambda q. p q FALSE
        .type   and_first, @function
and_first:
        movq    %rsi, %r8
        leaq    and_second(%rip), %rdi
        movq    %r8, %rsi
        xorl    %edx, %edx
        jmp     make_term

        .type   and_second, @function
and_second:
        subq    $8, %rsp
        movq    8(%rdi), %rdi
        call    apply
        movq    %rax, %rdi
        leaq    FALSE_TERM(%rip), %rsi
        call    apply
        addq    $8, %rsp
        ret

# OR = lambda p. lambda q. p TRUE q
        .type   or_first, @function
or_first:
        movq    %rsi, %r8
        leaq    or_second(%rip), %rdi
        movq    %r8, %rsi
        xorl    %edx, %edx
        jmp     make_term

        .type   or_second, @function
or_second:
        pushq   %r12
        movq    %rsi, %r12
        movq    8(%rdi), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        call    apply
        movq    %rax, %rdi
        movq    %r12, %rsi
        call    apply
        popq    %r12
        ret

# ZERO = lambda f. lambda x. x
        .type   zero_first, @function
zero_first:
        leaq    zero_second(%rip), %rdi
        xorl    %esi, %esi
        xorl    %edx, %edx
        jmp     make_term

        .type   zero_second, @function
zero_second:
        movq    %rsi, %rax
        ret

# SUCC = lambda n. lambda f. lambda x. f (n f x)
        .type   successor_first, @function
successor_first:
        movq    %rsi, %r8
        leaq    successor_second(%rip), %rdi
        movq    %r8, %rsi
        xorl    %edx, %edx
        jmp     make_term

        .type   successor_second, @function
successor_second:
        movq    8(%rdi), %r8
        movq    %rsi, %r9
        leaq    successor_third(%rip), %rdi
        movq    %r8, %rsi
        movq    %r9, %rdx
        jmp     make_term

        .type   successor_third, @function
successor_third:
        pushq   %r12
        pushq   %r13
        subq    $8, %rsp
        movq    16(%rdi), %r12
        movq    %rsi, %r13
        movq    8(%rdi), %rdi
        movq    %r12, %rsi
        call    apply
        movq    %rax, %rdi
        movq    %r13, %rsi
        call    apply
        movq    %r12, %rdi
        movq    %rax, %rsi
        call    apply
        addq    $8, %rsp
        popq    %r13
        popq    %r12
        ret

# PRED = lambda n. lambda f. lambda x.
#          n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda a. a)
        .type   predecessor_first, @function
predecessor_first:
        movq    %rsi, %r8
        leaq    predecessor_second(%rip), %rdi
        movq    %r8, %rsi
        xorl    %edx, %edx
        jmp     make_term

        .type   predecessor_second, @function
predecessor_second:
        movq    8(%rdi), %r8
        movq    %rsi, %r9
        leaq    predecessor_third(%rip), %rdi
        movq    %r8, %rsi
        movq    %r9, %rdx
        jmp     make_term

        .type   predecessor_third, @function
predecessor_third:
        pushq   %r12
        pushq   %r13
        pushq   %r14
        pushq   %r15
        subq    $8, %rsp
        movq    8(%rdi), %r12
        movq    16(%rdi), %r13
        movq    %rsi, %r14

        leaq    predecessor_step_first(%rip), %rdi
        movq    %r13, %rsi
        xorl    %edx, %edx
        call    make_term
        movq    %rax, %r15

        leaq    predecessor_seed(%rip), %rdi
        movq    %r14, %rsi
        xorl    %edx, %edx
        call    make_term
        movq    %rax, %r14

        movq    %r12, %rdi
        movq    %r15, %rsi
        call    apply
        movq    %rax, %rdi
        movq    %r14, %rsi
        call    apply
        movq    %rax, %rdi
        leaq    IDENTITY_TERM(%rip), %rsi
        call    apply

        addq    $8, %rsp
        popq    %r15
        popq    %r14
        popq    %r13
        popq    %r12
        ret

        .type   predecessor_step_first, @function
predecessor_step_first:
        movq    %rsi, %r8
        movq    8(%rdi), %r9
        leaq    predecessor_step_second(%rip), %rdi
        movq    %r8, %rsi
        movq    %r9, %rdx
        jmp     make_term

        .type   predecessor_step_second, @function
predecessor_step_second:
        pushq   %r12
        movq    %rsi, %r12
        movq    8(%rdi), %rax
        movq    16(%rdi), %rsi
        movq    %rax, %rdi
        call    apply
        movq    %r12, %rdi
        movq    %rax, %rsi
        call    apply
        popq    %r12
        ret

        .type   predecessor_seed, @function
predecessor_seed:
        movq    8(%rdi), %rax
        ret

        .type   identity_code, @function
identity_code:
        movq    %rsi, %rax
        ret

        .type   one_term, @function
one_term:
        subq    $8, %rsp
        leaq    SUCCESSOR_TERM(%rip), %rdi
        leaq    ZERO_TERM(%rip), %rsi
        call    apply
        addq    $8, %rsp
        ret

        .type   two_term, @function
two_term:
        subq    $8, %rsp
        call    one_term
        leaq    SUCCESSOR_TERM(%rip), %rdi
        movq    %rax, %rsi
        call    apply
        addq    $8, %rsp
        ret

        .type   three_term, @function
three_term:
        subq    $8, %rsp
        call    two_term
        leaq    SUCCESSOR_TERM(%rip), %rdi
        movq    %rax, %rsi
        call    apply
        addq    $8, %rsp
        ret

        .type   apply_binary, @function
apply_binary:
        pushq   %r12
        movq    %rdx, %r12
        call    apply
        movq    %rax, %rdi
        movq    %r12, %rsi
        call    apply
        popq    %r12
        ret

        .type   predecessor_of, @function
predecessor_of:
        movq    %rdi, %rsi
        leaq    PREDECESSOR_TERM(%rip), %rdi
        jmp     apply

# Observers below this point are the only code that converts terms to native
# booleans or integers.
        .type   church_to_bool, @function
church_to_bool:
        subq    $8, %rsp
        leaq    TRUE_MARKER(%rip), %rsi
        call    apply
        movq    %rax, %rdi
        leaq    FALSE_MARKER(%rip), %rsi
        call    apply
        leaq    TRUE_MARKER(%rip), %rcx
        cmpq    %rcx, %rax
        je      .Lobserved_true
        leaq    FALSE_MARKER(%rip), %rcx
        cmpq    %rcx, %rax
        je      .Lobserved_false
        movl    $-1, %eax
        jmp     .Lobserved_boolean_done
.Lobserved_true:
        movl    $1, %eax
        jmp     .Lobserved_boolean_done
.Lobserved_false:
        xorl    %eax, %eax
.Lobserved_boolean_done:
        addq    $8, %rsp
        ret

        .type   counter_code, @function
counter_code:
        movq    8(%rdi), %rax
        addq    $1, 0(%rax)
        movq    %rsi, %rax
        ret

        .type   church_to_int, @function
church_to_int:
        subq    $40, %rsp
        movq    %rdi, 32(%rsp)
        movq    $0, 0(%rsp)
        leaq    counter_code(%rip), %rax
        movq    %rax, 8(%rsp)
        leaq    0(%rsp), %rax
        movq    %rax, 16(%rsp)
        movq    $0, 24(%rsp)
        movq    32(%rsp), %rdi
        leaq    8(%rsp), %rsi
        call    apply
        movq    %rax, %rdi
        leaq    IDENTITY_TERM(%rip), %rsi
        call    apply
        movl    0(%rsp), %eax
        addq    $40, %rsp
        ret

        .type   check_boolean, @function
check_boolean:
        pushq   %r12
        pushq   %r13
        subq    $8, %rsp
        movq    %rdi, %r12
        movl    %edx, %r13d
        movq    %rsi, %rdi
        call    church_to_bool
        cmpl    %r13d, %eax
        jne     .Lcheck_failed
        leaq    false_text(%rip), %rdx
        testl   %eax, %eax
        je      .Lprint_boolean
        leaq    true_text(%rip), %rdx
.Lprint_boolean:
        leaq    boolean_format(%rip), %rdi
        movq    %r12, %rsi
        xorl    %eax, %eax
        call    printf@PLT
        addq    $8, %rsp
        popq    %r13
        popq    %r12
        ret

        .type   check_numeral, @function
check_numeral:
        pushq   %r12
        pushq   %r13
        subq    $8, %rsp
        movq    %rdi, %r12
        movl    %edx, %r13d
        movq    %rsi, %rdi
        call    church_to_int
        cmpl    %r13d, %eax
        jne     .Lcheck_failed
        leaq    numeral_format(%rip), %rdi
        movq    %r12, %rsi
        movl    %eax, %edx
        xorl    %eax, %eax
        call    printf@PLT
        addq    $8, %rsp
        popq    %r13
        popq    %r12
        ret

.Lcheck_failed:
        call    abort@PLT
        ud2

        .globl  main
        .type   main, @function
main:
        subq    $8, %rsp
        leaq    booleans_heading(%rip), %rdi
        call    puts@PLT

        leaq    label_true(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        movl    $1, %edx
        call    check_boolean
        leaq    label_false(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        xorl    %edx, %edx
        call    check_boolean

        leaq    NOT_TERM(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        call    apply
        leaq    label_not_true(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_boolean
        leaq    NOT_TERM(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        call    apply
        leaq    label_not_false(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_boolean

        leaq    AND_TERM(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        leaq    FALSE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_false_and_false(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_boolean
        leaq    AND_TERM(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        leaq    TRUE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_false_and_true(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_boolean
        leaq    AND_TERM(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        leaq    FALSE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_true_and_false(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_boolean
        leaq    AND_TERM(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        leaq    TRUE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_true_and_true(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_boolean

        leaq    OR_TERM(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        leaq    FALSE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_false_or_false(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_boolean
        leaq    OR_TERM(%rip), %rdi
        leaq    FALSE_TERM(%rip), %rsi
        leaq    TRUE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_false_or_true(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_boolean
        leaq    OR_TERM(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        leaq    FALSE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_true_or_false(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_boolean
        leaq    OR_TERM(%rip), %rdi
        leaq    TRUE_TERM(%rip), %rsi
        leaq    TRUE_TERM(%rip), %rdx
        call    apply_binary
        leaq    label_true_or_true(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_boolean

        leaq    numerals_heading(%rip), %rdi
        call    puts@PLT
        leaq    label_zero(%rip), %rdi
        leaq    ZERO_TERM(%rip), %rsi
        xorl    %edx, %edx
        call    check_numeral
        call    one_term
        leaq    label_one(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_numeral
        call    two_term
        leaq    label_two(%rip), %rdi
        movq    %rax, %rsi
        movl    $2, %edx
        call    check_numeral
        call    three_term
        leaq    label_three(%rip), %rdi
        movq    %rax, %rsi
        movl    $3, %edx
        call    check_numeral

        leaq    ZERO_TERM(%rip), %rdi
        call    predecessor_of
        leaq    label_pred_zero(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_numeral
        call    one_term
        movq    %rax, %rdi
        call    predecessor_of
        leaq    label_pred_one(%rip), %rdi
        movq    %rax, %rsi
        xorl    %edx, %edx
        call    check_numeral
        call    two_term
        movq    %rax, %rdi
        call    predecessor_of
        leaq    label_pred_two(%rip), %rdi
        movq    %rax, %rsi
        movl    $1, %edx
        call    check_numeral
        call    three_term
        movq    %rax, %rdi
        call    predecessor_of
        leaq    label_pred_three(%rip), %rdi
        movq    %rax, %rsi
        movl    $2, %edx
        call    check_numeral

        xorl    %eax, %eax
        addq    $8, %rsp
        ret

        .section .data.rel.ro.local,"aw"
        .p2align 3
TRUE_TERM:
        .quad   true_first, 0, 0
FALSE_TERM:
        .quad   false_first, 0, 0
NOT_TERM:
        .quad   not_term_code, 0, 0
AND_TERM:
        .quad   and_first, 0, 0
OR_TERM:
        .quad   or_first, 0, 0
ZERO_TERM:
        .quad   zero_first, 0, 0
SUCCESSOR_TERM:
        .quad   successor_first, 0, 0
PREDECESSOR_TERM:
        .quad   predecessor_first, 0, 0
IDENTITY_TERM:
        .quad   identity_code, 0, 0
TRUE_MARKER:
        .quad   identity_code, 0, 0
FALSE_MARKER:
        .quad   identity_code, 0, 0

        .section .rodata
booleans_heading:       .asciz  "CHURCH BOOLEANS"
numerals_heading:       .asciz  "CHURCH NUMERALS"
boolean_format:         .asciz  "%s: %s\n"
numeral_format:         .asciz  "%s: %d\n"
true_text:              .asciz  "true"
false_text:             .asciz  "false"
label_true:             .asciz  "TRUE"
label_false:            .asciz  "FALSE"
label_not_true:         .asciz  "NOT TRUE"
label_not_false:        .asciz  "NOT FALSE"
label_false_and_false:  .asciz  "FALSE AND FALSE"
label_false_and_true:   .asciz  "FALSE AND TRUE"
label_true_and_false:   .asciz  "TRUE AND FALSE"
label_true_and_true:    .asciz  "TRUE AND TRUE"
label_false_or_false:   .asciz  "FALSE OR FALSE"
label_false_or_true:    .asciz  "FALSE OR TRUE"
label_true_or_false:    .asciz  "TRUE OR FALSE"
label_true_or_true:     .asciz  "TRUE OR TRUE"
label_zero:             .asciz  "ZERO"
label_one:              .asciz  "ONE"
label_two:              .asciz  "SUCC ONE"
label_three:            .asciz  "SUCC (SUCC ONE)"
label_pred_zero:        .asciz  "PRED ZERO"
label_pred_one:         .asciz  "PRED ONE"
label_pred_two:         .asciz  "PRED (SUCC ONE)"
label_pred_three:       .asciz  "PRED (SUCC (SUCC ONE))"

        .section .note.GNU-stack,"",@progbits
