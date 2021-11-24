.global brainfuck

output:       .asciz "%c"
intput:       .asciz "%ld %c\n"
endline:      .asciz "\n"

.section .bss
usablespace:  .space 131072
input:        .space 16
.section .text
# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to ex

# Takes in parameters:
brainfuck:
	pushq %rbp
	movq %rsp, %rbp
  
  # Push used registers on stack
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  # r12 : address of current executing code
  # r13 : pointer to current memory being used
  # r14 : register used for comparing characters
  
  movq $0, %r15
  movq $0, %r14
  
  # Move the pointer to the code in %r12
  movq %rdi, %r12
  # Move the pointer to the space of the program in r13
  movq $usablespace, %r13

  loop:
    # Testing if we finished the program
    cmpq $0, (%r12)
    je endloop
  
      
    cmpb $91, (%r12)    #[
    je caseleftp

    cmpb $93, (%r12)    #]
    je caserightp
    
    cmpq $0, %r14       # the parethesis thing
    jne fincase

    cmpb $62, (%r12)    #>
    je casegreater
  
    cmpb $60, (%r12)    #<
    je caseless
  
    cmpb $43, (%r12)    #+
    je caseplus
    
    cmpb $45, (%r12)    #-
    je caseminus
  
    cmpb $46, (%r12)    #.
    je casedot
    
    cmpb $44, (%r12)    #,
    je casecomma

    jmp fincase

    caseleftp:
      # Test if we need to start the loop
      cmpq $0, (%r13)
      jne startloop
      
      # Increasing the number of open parathesis that are not executed 
      incq %r14
      jmp fincase
      
      # The loop starts so we push the current program index on the stack
      startloop:
      pushq %r12
      jmp fincase

    caserightp:
      # Test if we need to continue the loop
      cmpq $0, (%r13)
      jne continueloop
      
      cmpq $0, %r14
      je popparant
      decq %r14
      jmp fincase
      
      # The loop ends so we need to pop the parenthesis were it started off the
      # stack
      popparant:
      addq $8, %rsp   #pop the parathesis off the stack
      jmp fincase
      
      # If we continue the loop we need to jump to the beginning of it
      continueloop:
      movq (%rsp), %r12
      jmp fincase

    casegreater:
      # Move right by one byte (add 8 to the pointer that points to the memory)
      addq $8, %r13
      jmp fincase

    caseless:
      # Move left by one byte (subtract 8 from the pointer that points to the
      # memory)
      subq $8, %r13
      jmp fincase

    caseplus:
      # Increase the current point in memory
      addq $1, (%r13)
      jmp fincase

    caseminus:
      # Decrease the current point in memory
      subq $1, (%r13)
      jmp fincase

    casedot:
      # Print the current point in memory to screen
      movq $0, %rax
      movq $0, %rsi
      movb (%r13), %sil
      movq $output, %rdi
      call printf
      jmp fincase

    casecomma:
      # Read one character from input
      movq $0, %rax
      movq $0, %rdi
      leaq (%r13), %rsi
      movq $1, %rdx
      syscall
    fincase:
    
    incq %r12
    jmp loop

  endloop:
  
  # Print endline
  movq $0, %rax
  movq $endline, %rdi
  call printf
 
  # Popping used registers off stack
  popq %r14
  popq %r13
  popq %r12
  popq %r15

	movq %rbp, %rsp
	popq %rbp
	ret
