#David Kim
.data
wid: .word 10 #Length of one row, must be 4n-1
hgt: .word 10 #Number of rows
cx: .word 0
cy: .word 0
seed: .word 31415
numLeft: .word 0
board: .space 1600 #Max 38x38 maze
array: .space 20
array2: .space 20
askwid: .asciiz "Enter the width of the maze: "
askhgt: .asciiz "Enter the height of the maze: "
opendoorh: .asciiz "+  "
closedoorh: .asciiz "+--"
endrowh: .asciiz "+"
verticalwall: .asciiz "|  "
openvwall: .asciiz "   "
newline: .asciiz "\n" #newline
askseed: .asciiz "Please enter a random seed: "
printstep: .asciiz "this is a step"
.text
.globl main
main:
	li $v0, 4
	la $a0, askseed #print prompt
	syscall
	li $v0, 5 #receive user input
	syscall
	move $a0, $v0 #move input to $a0
	jal seedrand #jump and link to seedrand function
	jal getSize #jump and link to getSize function
	jal initBoard #jump and link to initBoard function
	jal pickExit #jump and link to pickExit function
	jal pickEntrance #jump and link to #pickEntrance function
	lw $t0, wid #load wid to t0
	lw $t1, hgt #load hgt to t1
	mult $t0, $t1 #mult to find # of boxes
	mflo $t3 # store into t3
	addi $s7, $t3, -1 #subtract for entrance box. s7 stores amount of open boxes
loop: #loop for if num of remainding squares is greater than 0, loop
	jal greaterThanZero #jump and link to greaterThanZero function which is part of the takeMove function
	beqz $s7, print #if s7 reaches 0, go to print
	j loop #loop j
print: #point for loop to go to in order to go to print and finish the program
	jal printBoard #jump and link to printBoard function
	li $v0, 10 #end program
	syscall

greaterThanZero: #beginning of function for takeMove
	move $s1, $ra #store ra to s1 for future use
	
takeMove: # function to inpupt board in a straightline
	la $t0, board #load in board
	la $t9, array #load in array
	li $s2, 0 #set counter to 0 of neighbors that are empty
	lw $t1, cx #load cx
	lw $t2, cy #load cy
	lw $t3, wid #load width
	lw $t4, hgt #load height
	addi $t3, $t3, 2 #incrase width by 2 to match # of squares in a row
	mult $t3, $t2 #multiply row by cy
	mflo $t5 #store into t5
	li $t6, -1
	mult $t3, $t6 #multiply to get negative row squares
	mflo $t7 #store into t7 
	add $s0, $t5, $t1 #find how many boxes from 0,0 the current box is at
	add $s6, $s0, $t3 #south neighbor
	jal checkNums #jump and link to checkNums function
	add $s6, $s0, $t7 #north neighbor
	jal checkNums #jump and link to checkNums function
	addi $s6, $s0, -1 #west neighbor
	jal checkNums #jump and link to checkNums function
	addi $s6, $s0, 1 #east neighbor
	jal checkNums #jump and link to checkNums function
	li $t5, 0 #load 0 to t5
	addi $t9, $t9, -12 #take array back to beginning
	bgt $s2, 0, roll #if there is at least 1 open neighbor go to the roll function
endloop:
	li $s7, 0
	move $ra, $s1 #move the $ra to $s1 for future use
	jr $ra #jump to return address
	
checkNums: #check to see if there are open neighbors
	lb $t8, board($s6) #load the value of the position to t8
	addi $t8, $t8, -48 #find the value of position in ascii
	beqz $t8, openNeighbor #if number is open/0 go to openneighbor
	addi $t9, $t9, 4 #add 4 bytes to the array for next position
	jr $ra #jump to return address
openNeighbor: #store value of openneighbors into array
	addi $s2, $s2, 1 #add 1 to the counter of open neighbors
	sw $s6, 0($t9) #store the value to the array 
	addi $t9, $t9, 4 #add 4 bytes to the array for next position
	jr $ra #jump to return address
roll:#roll a number to pick which neighbor
	jal rand #get a random number
	div $v0, $s2 #divide random numbe
	mfhi $t7 #store remainder into t7
	addi $t7, $t7, 1 #add 1
	
insertNums: #find the number/box
	lw $t6, array($t5) #load value to t6
	li $t8, 0 #make t8 0
	sw $t8, array($t5) #store 0 to array to reset value
	beqz $t6, skipNum #if value is 0, skip
	addi $t7, $t7, -1 #subtract roll by 1
	beqz $t7, foundNums #when roll =0, or the roll is found go to foundNums
	addi $t5, $t5, 4 #add 4 bytes for the next number in the array
	j insertNums #loop
skipNum: #skip if not the correct neighbor
	addi $t5, $t5, 4 #add 4 bytes for the next number in the array
	j insertNums #jump to insertNums
foundNums:#find the cx, cy and the ascii value to put in box
	div $t6, $t3 #divide value by total width
	mfhi $t1 #store remainder to t1
	mflo $t2 #store quotient to t2
	sw $t1, cx #store t1 to cx
	sw $t2, cy #store t2 to cx
	li $t8, 4 # load 4 into t8
	div $t5, $t8 # divide t5 by 4 to find the equivalent number 1-4
	mflo $t5 #find the number to put into the box
	addi $t5, $t5, 49 #convert to ascii
	move $a0, $t5 #move to a0
	addi $s7, $s7, -1 #decrease count by 1
	j placeInSquare #jump to placeinsquare
getSize: #get dimensions for maze
	move $s1, $ra #store ra to s1 for later use
	li $v0, 4
	la $a0, askwid #print prompt
	syscall
	li $v0, 5 #receive user input
	syscall
	move $t0, $v0 #move number to t0
	jal getSizeChecker #jump and link to getSizeChecker function
	sw $t0, wid #store t0 to wid
	li $v0, 4
	la $a0, askhgt #print prompt
	syscall
	li $v0, 5 #receive user input
	syscall
	move $t0, $v0 #move number to t0
	jal getSizeChecker #jump and link to getSizeChecker function
	sw $t0, hgt #store t0 to hgt
	move $ra, $s1 #restore ra
	j done #jump to done function
	
getSizeChecker:#make sure size is at least 5x5 and max of 38x38
	li $t6, 38 #load 38 to t6
	sgt $t3, $t0, $t6 #check if value is more than 38
	li $t5, 5
	slt $t4, $t0, $t5 #check if value is less than 5
	beq $t3, 1, decreaseSize #if value is higher than go to decreaseSize function
	beq $t4, 1, increaseSize #if value is lower than go to increaseSize function
	jr $ra
		
increaseSize: #increase the size t0 5
	li $t0, 5
	j done #jump to done
decreaseSize: #decrease the size to 38
	li $t0, 38
done:
	jr $ra #jump to return address

initBoard: #initialize the board
	li $t7, 53 #ascii value for 5
	li $t8, 48 #ascii value for 0
	lw $t1, wid #load wid to t1
	add $t1, $t1, 1 #increase it by 1
	lw $t2, hgt #load hgt to t2
	add $t2, $t2, 1 #increase by 1
	li $t3, 0 #start counter1 for width
	li $t4, 0 #start counter2 for height
	la $t0, board #load the board
initBoardloop: #loop of finding what to put into initial numbers
	beq $t3, 0, putFive #go to putFive function if on 0 axis
	beq $t4, 0, putFive #go to putFive function if on 0 axis
	beq $t3, $t1, putFive ##go to putFive function if on max  axis
	beq $t5, $t2, putFive #go to putFive function if on max axis
	sb $t8, 0($t0) #put ascii value 0 into box/board
	addi $t3, $t3, 1 #add 1 to counter for width
	bgt $t3, $t1, nextRow #if counter higher than width than go to nextRow function
	addi $t0, $t0, 1 #go to next value in the board
	j initBoardloop #loop
putFive: #put the ascii value 5 into the box
	sb $t7, 0($t0) #store ascii 5 into the box
	addi $t3, $t3, 1 #add 1 to counter for width
	bgt $t3, $t1, nextRow #if counter higher than width than go to nextRow function
	addi $t0, $t0, 1 #go to next value in the board
	j initBoardloop #jump to initBoardLoop
nextRow:#come here after end of row
	addi $t4, $t4, 1 #add 1 to counter for height
	beq $t4, $t2, temporaryExit #if counter reaches max height go to temporaryExit function
	li $t3, 0 #reset counter for width
	addi $t0, $t0, 1 #go to next value in the board
	j initBoardloop #jump to initbBoardLoop
temporaryExit:#exit function
	jr $ra #jump to return address

placeInSquare: #put value into square
	move $t0, $a0 #move a0 to t0
	la $t6, board #load board
	lw $t1, cx #load cx to t1
	lw $t2, cy #load cy to t2
	lw $t3, wid #load width to t3
	addi $t3, $t3, 2 #increase width to total width
	mult $t2, $t3 # multiply 
	mflo $t4
	add $t5, $t4, $t1 #find the position of cx, cy
	add $t6, $t6, $t5 #go to the position of cx, cy
	sb $t0, 0($t6) #load value to board
	move $ra, $s1 #recall back the ra
	jr $ra #jump to return address
	
pickExit: #pick an exit
	move $s1, $ra #store ra into s1 for later use
	lw $t1, wid #load wid to t1
	lw $t4, hgt #load hgt to t4
	jal rand #get random number 
	div $v0, $t1 #divide number by wid
	mfhi $t2 #store number
	addi $t2, $t2, 1 #add by 1 to be inside the dimensions
	addi $t4, $t4, 1 #go to last row
	sw $t2, cx #store cx
	sw $t4, cy #store cy
	li $a0, 49 #load ascii value of 1
	j placeInSquare #jump to placeInSquare

pickEntrance:
	move $s1, $ra #store ra into s1 for later use
	lw $t1, wid #load wid to t1
	jal rand #get random number 
	div $v0, $t1 #divide number by wid
	mfhi $t2 #store number
	addi $t2, $t2, 1 #add by 1 to be inside the dimensions
	li $t3, 1 #make the y variable 1 for the entrance
	sw $t2, cx #store cx
	sw $t3, cy #store cy
	li $a0, 49 #load ascci value of 1
	j placeInSquare #jump to placeInSquare
	

rand: #pick random number
	lw $v0, seed   	 # Fetch the seed value
	sll $t0, $v0, 13    # Compute $v0 ^= $v0 << 13
	xor $v0, $v0, $t0
	srl $t0, $v0, 17    # Compute $v0 ^= $v0 >> 17
	xor $v0, $v0, $t0
	sll $t0, $v0, 5   	 # Compute $v0 ^= $v0 << 5
	xor $v0, $v0, $t0
	sw $v0, seed   	 # Save result as next seed
	andi $v0, $v0, 0xFFFF    # Mask the number (so we know its positive)
	div $v0, $a0   	 # divide by N.  The reminder will be
	mfhi $v0   			 # in the special register, HI.  Move to $v0.
	jr $ra   			 # Return the number in $v0
	
seedrand: #store seed value
	sw $a0, seed #store seed value
	jr $ra
	
printBoard: #print the board
	la $t0, board #load in the board
	la $t4, board #load the board again
	lw $t1, wid #load in width
	lw $t2, hgt #load in hgt
	addi $s1, $t1, 2 #value of total hgt
	li $t9, 0 #counter for rows
	li $t5, 1 #counter for columns
	add $t4, $t4, $s1 #start position for south square
	addi $s2, $t1, 1 #get value of width +1
	li $s3, -1
	mult $s2, $s3
	mflo $s4 #get negative value of s2
checkupanddown:#check north and south values
	addi $t0, $t0, 1 #start at 1 because no value in a 5 to 5 and add value of 1 for each loop
	addi $t4, $t4, 1 #start under t0
	lb $t3, 0($t0)#load value of board
	addi $t7, $t3, -48 #convert from ASCII to # and put the north cell value in t7
	sb $t3, 0($t0) #store value back to board
	lb $t8, 0($t4) #load value of board
	addi $t6, $t8, -48 #convert from ASCII to # and put south cell value in t6
	sb $t8, 0($t4) #store value back to board
	beq $t7, 2, opendoor #if value is 2, go to opendoor function
	beq $t6, 1, opendoor #if value is 1, go to opendoor function
	li $v0, 4
	la $a0, closedoorh #print wall
	syscall
	addi $t5, $t5, 1 #add 1 to counter
	bgt $t5, $t1, endofrow1 #if counter goes over width, go to endofrow1 function
	j checkupanddown #loop
	
checkside:#check east and west values
	lb $t3, 0($t0) #load value of board
	addi $t7, $t3, -48 #convert to ascii
	sb $t3, 0($t0) #store value back to board
	addi $t0, $t0, 1 #go to next position
	lb $t8, 0($t0) #load value of board
	addi $t6, $t8, -48 #convert to ascii
	sb $t8, 0($t0) #store value back to board
	beq $t7, 3, openwall #if 3, go to openwall function
	beq $t6, 4, openwall #if 4, go to openwall function
	addi $t5, $t5, 1 #add 1 to counter
	li $v0, 4
	la $a0, verticalwall #print wall
	syscall
	beq $t5, $s2, endofrow2 #if counter reaches width+1, go to endofrow2 function
	j checkside #loop
	
openwall: #print an open wall
	addi $t5, $t5, 1 #add 1 to counter
	li $v0, 4
	la $a0, openvwall #print openwall
	syscall
	beq $t5, $s2, endofrow2 #if counter reaches width+1, go to endofrow2 function
	j checkside #jump to checkside function
	
opendoor: #print an open wall
	addi $t5, $t5, 1 #add 1 to counter
	li $v0, 4
	la $a0, opendoorh #print open wall
	syscall
	bgt $t5, $t1, endofrow1 #if counter goes over width, go to endofrow1 function
	j checkupanddown #jump to checkupanddown function
endofrow1:
	li $v0, 4
	la $a0, endrowh #print endwall
	syscall
	li $v0, 4
	la $a0, newline #go to next line
	syscall
	beq $t9, $t2, temporaryExit #if counter reaches height, end function
	li $t5, 0 #reset counter
	addi $t0, $t0, 2 #add 2 to go to starting position for checkside
	j checkside #jump to checkside function
	
endofrow2:
	addi $t4, $t4, 2 #go to position for checkupanddown
	add $t0, $t0, $s4 #go to position for checkupanddown
	li $v0, 4
	la $a0, newline #print new line
	syscall
	addi $t9, $t9, 1 #add 1 to height counter
	li $t5, 1 #reset counter
	j checkupanddown #jump to checkupanddown function
