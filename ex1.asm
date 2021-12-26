.data 0x10000000 ##!
  display: 		.space 65536
  			.align 2
  redPrompt:		.asciiz "Enter a RED color value for the background (integer in range 0-255):\n"
  greenPrompt:		.asciiz "Enter a GREEN color value for the background (integer in range 0-255):\n"
  bluePrompt:		.asciiz "Enter a BLUE color value for the background (integer in range 0-255):\n"
  redSquarePrompt:	.asciiz "Enter a RED color value for the squares (integer in range 0-255):\n"
  greenSquarePrompt:	.asciiz "Enter a GREEN color value for the squares (integer in range 0-255):\n"
  blueSquarePrompt:	.asciiz "Enter a BLUE color value for the squares (integer in range 0-255):\n"
  sizePrompt:		.asciiz "Enter the width in pixels of the first square (Integer power of 2 in the set {1, 2, 4, 8, 16, 32, 64):\n"
  


.text 0x00400000 ##!
main:

	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, redPrompt 			# address of redPrompt is in $a0
	syscall           			# print the string
	# read in the R value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s0, $0, $v0			# copy N into $s0
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, greenPrompt 		# address of greenPrompt is in $a0
	syscall           			# print the string
	# read in the G value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s1, $0, $v0			# copy N into $s1
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, bluePrompt 		# address of bluePrompt is in $a0
	syscall           			# print the string
	# read in the B value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s2, $0, $v0			# copy N into $s2
 	
 	
 	
 	
 	#############################################
	## Calculate square color and put in       ##
	## appropriate register                    ##
	#############################################
	li $t0, 0
	li $s3, 16384
	sll $s0, $s0, 16
	sll $s1, $s1, 8
	add $t1, $s0, $0
	add $t1, $s1, $t1
	add $t1, $s2, $t1
	j drawDisplay
	
# Exit from the program
exit:
  ori $v0, $0, 10       		# system call code 10 for exit
  syscall               		# exit the program
	
drawDisplay:
	mul $t3, $t0, 4
	sw $t1, display($t3)
	addi $t0, $t0, 1
	bne $t0, $s3, drawDisplay
	
	
readSquareColors:
	addi	$v0, $0, 4  	
	la 	$a0, redSquarePrompt 
	syscall           	
	# read in the R value
	addi	$v0, $0, 5	
	syscall 		
 	add	$s0, $0, $v0	
 	
 	
 	
 	addi	$v0, $0, 4  			
	la 	$a0, greenSquarePrompt 		
	syscall           			
	# read in the G value
	addi	$v0, $0, 5			
	syscall 				
 	add	$s1, $0, $v0			
 	
 	
 	
 	addi	$v0, $0, 4  		
	la 	$a0, blueSquarePrompt 	
	syscall           		
	# read in the B value
	addi	$v0, $0, 5		
	syscall 			
 	add	$s2, $0, $v0	
 	
 	#############################################
	## Calculate square color and put in       ##
	## appropriate register                    ##
	#############################################
	# store color in a3
	sll $s0, $s0, 16
	sll $s1, $s1, 8
	add $a3, $s0, $0
	add $a3, $s1, $a3
	add $a3, $s2, $a3
	
readSize:
	addi	$v0, $0, 4  	
	la 	$a0, sizePrompt
	syscall           	
	addi	$v0, $0, 5	
	syscall 		
 	add	$s0, $0, $v0	
 	
 	# set up arguments 
 	
 	# put the color on the stack 
 	addi $sp, $sp, -4
 	sw $a3, 0($sp)
 
 	# the size is in $s0 
	# the top left x is 63 - (size / 2) 
	# the top left y is 63 - (size / 2) 
	div $t0, $s0, 2
	addi $a0, $0, 64
	sub $a0, $a0, $t0
	add $a1, $a0, $0 
	add $a2, $s0, $0
	add $a3, $s0, $0 
	
	# edge case: width is 1 
	beq $a2, 1, edgeCase 
 	
	# draw the square 
	jal drawSquare
	
	
	j exit
	
edgeCase: 

	# get the color off the stack 
	lw $t7, 0($sp) 

	# the address of the pixel is 128 * 63 + 63
	addi $t3, $0, 63
	mul $t3, $t3, 128
	addi $t3, $t3, 63
	mul $t3, $t3, 4
	
	# color the pixel 
	sw $t7, display($t3)
	
	# ur done 
	j exit 
	
drawMoreSquares: 
 	
	# first, we need to save our current $ra on the stack 
	addi $sp, $sp, -4 
	sw $ra 0($sp) 
		
 	# then, we want to save our current arguments in saved registers 
 	# but we must first put the current saved registers on the stack so we can put them back when we're done 
 	addi $sp, $sp, -4
 	sw $s0, 0($sp)
 	addi $sp, $sp, -4
 	sw $s1, 0($sp)
 	addi $sp, $sp, -4
 	sw $s2, 0($sp)
 	addi $sp, $sp, -4
 	sw $s3, 0($sp)
 	
 	# then transfer our arguments to saved registers 
 	add $s0, $a0, $0
 	add $s1, $a1, $0
 	add $s2, $a2, $0
 	add $s3, $a3, $0 
 	
 	# put the color on the stack as $a4 
 	addi $sp, $sp, -4
 	sw $t7, 0($sp) 
 	
 	# then let's set up the arguments for the top left square 
 	# new width = current width / 2 
 	# top left x = current top left x 
 	# top left y = current left y - (new width / 2)
 	# new height = new width 
 	div $a2, $s2, 2
 	div $t5, $a2, 2
 	add $a0, $s0, $0
 	sub $a1, $s1, $t5
 	add $a3, $a2, $0
 	jal drawSquare 
 	
 	# then let's set up the arguments for the top right square 
 	# new width = current width / 2 
 	# top left x = current top left x + current width - (new width / 2)
 	# top left y = current top left y 
 	# new height = new width 
 	div $a2, $s2, 2
 	div $t5, $a2, 2
 	add $a0, $s0, $s2
 	sub $a0, $a0, $t5
 	add $a1, $s1, $0 
 	add $a3, $a2, $0 
 	jal drawSquare 
 	
 	# then let's set up the arguments for the bottom left square 
 	# new width = current width / 2 
 	# top left x = current top left x - (new width / 2)
 	# top left y = current top left y + current width - new width
 	# new height = new width 
 	div $a2, $s2, 2
 	div $t5, $a2, 2
 	add $a1, $s1, $s2
 	sub $a0, $s0, $t5
 	sub $a1, $a1, $a2
 	add $a3, $a2, $0 
 	jal drawSquare 
 	
 	# then let's set up the arguments for the bottom right square 
 	# new width = current width / 2 
 	# top left x = current top left x + current width - new width 
 	# top left y = current top left y + current width - (new width / 2)
 	# new height = new width 
 	div $a2, $s2, 2
 	div $t5, $a2, 2
 	add $a0, $s0, $s2
 	add $a1, $s1, $s2
 	sub $a0, $a0, $a2
 	sub $a1, $a1, $t5
 	add $a3, $a2, $0 
 	jal drawSquare 
 	
 	# pop the color off the stack 
 	addi $sp, $sp, 4
 	
 	# now we need to put back our original saved registers 
 	lw $s3, 0($sp)
 	addi $sp, $sp, 4
 	lw $s2, 0($sp)
 	addi $sp, $sp, 4
 	lw $s1, 0($sp)
 	addi $sp, $sp, 4
 	lw $s0, 0($sp)
 	addi $sp, $sp, 4
 	
 	# put back our original return address 
 	lw $ra, 0($sp)
 	addi $sp, $sp, 4 
 	
 	# if you make it here, you've drawn the four outside squares of this square, 
 	# so you can return to the original square 
 	jr $ra 

	
drawSquare: # Do not change this label
  	# a0 - upper left x
 	# a1 - upper left y
 	# a2 - width
 	# a3 - height (stays the same) 
 	# a4 - color (on the stack)
 	
 	# pop our color off the stack into $t7
 	lw $t7, 0($sp)
 	
 	# update how many more columns we need 
 	addi $a2, $a2, -1 
 	
 	# update current column (x-value)
 	add $t0, $a0, $a2 
 	# reset y-value to the bottom-most 
 	add $t1, $a1, $a3 
 	
 	# color the column if we still need to color a column 
 	bgez $a2, colorCol
 	
 	# put the x width back 
 	add $a2, $a3, $0
 	
 	# if you make it here, you've drawn the first square. BUT 
 	# if the next square's width is > 1, you need to draw more squares first 
 	# the next square's width = current width / 2 
 	div $t9, $a3, 2
 	bgt $t9, 1, drawMoreSquares
 
 	# if the width is <= 2, you don't need to draw any more squares, so you can just return 
 	jr $ra 
 	
colorCol: 

	# update y-value 
	addi $t1, $t1, -1
	# go to the next row if y < topmost y 
	blt $t1, $a1, drawSquare
	
	# otherwise, color the pixel 
	# the address of the pixel is the word in memory of 128y + x 
	mul $t4, $t1, 128
	add $t4, $t4, $t0
	mul $t4, $t4, 4
	# store the color in that address 
	sw $t7, display($t4)
	
	# go to the next pixel 
	j colorCol 

	
	
	