#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Vaibhav Holani, 1006166177
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the project handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# Milestone 1, 2, 3 have been completed successfully ++ (ADDITIONAL FEATURES IMPLEMENTED)
#
# Which approved additional features have been implemented?
# (See the project handout for the list of additional features)
# 1. Better Graphics than what the basic running version of the game would look like
# 2. All centipede heads need to be shot separtaely (closer to the real game)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# I tried to comment almost every line of code that I have written in order to make marking easier for you!! :)
#
#####################################################################



.data
displayAddress: .word 0x10008000	# The base address of the display
bugColor: .word  0x15f4ee		# The bug color is white
Black: .word 0x000000			# The background color is white
Yellow: .word 0xFFFF00			# The color of the game over text is zero
			
mushroom: .word 0xff5722		# The mushroom color is orange
centipede: .word 0xf598fa		# The centipede color is light purple

OriginalBugLocation: .word 0x10008fc0 	# The starting location of the bug
BugLocation: .word 0x10008fc0		# The current location of the bug

BugLeftTop:.word 0x10008f80		# The left endpoint when the bug is in row 31
BugRightTop:.word 0x10008ffc		# The right endpoint when the bug is in row 31


MushroomHead: .word 0x10008000:8 	# Store 8 mushrooms with location at the base
MushroomTopColor: .word 0xFF0000	# the top mushroom color is red
MushroomBaseColor: .word 0x996600	# the base of the mushroom is organish brown


CentiepdeHead: .word 0x10008000:10 	# Store the 10 centipede heads in the array all of them set to the same intital location
CentipedeColors: .word 0x7CFC00, 0x7FFF00, 0x32CD32, 0x00FF00, 0x228B22, 0x008000, 0x006400, 0xADFF2F, 0x9ACD32, 0x556B2F	# Colors for each centipod
CentipedeDirections: .word 1:10		# The direction in which each centipede is headed
 

RenderCentipede: .word 1:10		# Indicates whether the a centipede has been hit 

BottomLeftEndpoint: .word 0x10008f80	# Indicates left end of the screen
BottomRightEndpoint: .word 0x10008ffc   # Indicates right end of the screen

DartLocation: .word 0x10008000		# Indicates the location of the word
DartRender: .word 0			# Check whether the render the dart or not
DartColor: .word 0xdf00fe		# The colour of the dart is purple

FleaLocation: .word 0x10008000			# The location of the flea is stored here
FleaColor: .word 0xFFA500		# The color of flea is orange
FleaRender: .word 0			# Check if the flea is supposed to rendered or not

# RenderMushroom consists 5 elements for each mushroom
# They are stored in the following order
# MUSHROOM_HEAD, MUSHROOM_MIDDLE_LEFT, MUSHROOM_MIDDLE, MUSHROOM_MIDDLE_RIGHT, MUSHROOM_BASE

RenderMushroom: .word 1:40		# Containts 5 elements for each mushroom

.text
MEMORY_LOADER:

jal COLOR_ALL_BLACK			# Setting everything to black

jal RANDOMIZE_MUSHROOMS			# give random location to the mushrooms

jal SET_INITIAL_CENTIPEDE		# set the correct values for the centipede

jal RENDER_TO_1				# set the render values to 1

main:

jal DISPLAY_BUG				# display the location of the bug on the screen
jal LOAD_MUSHROOM_DATA			# draw all the mushrooms on the screen
jal LOAD_CENTIPEDE_DATA			# draw each flea of the centipede

# Waiting for 50 miliseconds 
li $v0, 32				
li $a0, 50
syscall

lw $t8, 0xffff0000		
beq $t8, 1, INPUT_KEYBOARD

jal SET_CENTIPEDE_BLACK			# set all the centipede locations black
jal UPDATE_CENTIPEDE

jal CHECK_RANDOM_FLEA			# Drawing and updatting flea at random locations
jal CHECK_UPDATE_FLEA
jal CHECK_DRAW_FLEA

jal CHECK_ALL_HIT			# Checking if all the centipede heads have been hit

j main

Exit:
li $v0, 10 # terminate the program gracefully
syscall 

#------FUNCTIONS----------#


# --------------------#
#                     #
#   BUG FUNCTIONS     #
#                     #
# --------------------#

DISPLAY_BUG:

	lw $s0, BugLocation			# $s0 stores the current location of the bug
	lw $s1, bugColor			# $s1 stores the color of the bug

	sw $s1, 0($s0)				# Displaying the location of the bug

	jr $ra					# Going back to the calling function


INPUT_KEYBOARD:

	# Find the input key
	lw $t2, 0xffff0004

	beq $t2, 0x6A, CHECK_MOVE_LEFT	# When 'j' key is pressed

	beq $t2, 0x6B, CHECK_MOVE_RIGHT	# When 'k' key is pressed

	beq $t2, 0x78, SHOOT_DART		# When 'x' key is pressed

	jr $ra				# Going back to the calling function


CHECK_MOVE_LEFT:

	lw $s0, BugLocation			# $s0 stores the current location of the bug
		
	lw $t7, BugLeftTop	# Load the left endpoint when the bug is in row 30

	bne $s0, $t7, MOVE_LEFT	# Only move left if the bug is not at the left end point

	jr $ra

MOVE_LEFT:

	la $s0, BugLocation
	lw $t7, Black
	
	lw $a1, 0($s0)			# Loading the address of the bug
	
	sw $t7, 0($a1)			# Coloring the previous spot black

	addi $a1, $a1, -4  	# Moving the bug to the left
	
	sw $a1, 0($s0)

	jr $ra



MOVE_RIGHT:
	la $s0, BugLocation
	lw $t7, Black
	
	lw $a1, 0($s0)		# Loading the address of the bug
	sw $t7, 0($a1)			# Coloring the previous spot black	

	addi $a1, $a1, 4  	# Moving the bug to the right
	
	sw $a1, 0($s0)

	jr $ra


CHECK_MOVE_RIGHT:
	
	lw $s0, BugLocation			# $s0 stores the current location of the bug

	lw $t7, BugRightTop	# Load the right endpoint when the bug is in row 30
	bne $s0, $t7, MOVE_RIGHT	# Only move right if the bug is not at the right end point

	jr $ra


# ------------------------------------#
#                                     #
#   CENTIPEDE DISPLAY FUNCTIONS       #
#                                     #
# ------------------------------------#

LOAD_CENTIPEDE_DATA:
	
	la $t5, CentiepdeHead		# Holds the location of all the seperate centipods
	la $t6, CentipedeColors		# Holds the colors associated with every centipede
	la $s3, RenderCentipede		# Holds the information about whether or not a centipode is supposed to be drawn or not
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 10		# Set t1 to 10

DISPLAY_CENTIPEDE:

	bge $t0, $t1, CENTIPEDE_END	# Loop while t1 >= t0
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t5, $t2		# Make $t3 point at right offset for CentipedeHead
	add $t4, $t6, $t2		# Make $t2 point at right offset for CentipedeColor
	add $s4, $s3, $t2		# Make $s4 point at right offest for RenderCentipede
	
	lw $a0, 0($t3)			# Load the location of the centipede head in $a0
	lw $a1, 0($t4)			# Load the color of the respective head in $a1
	lw $a2, 0($s4)			# Load the render value of the respective head in $a2
	
	addi $t2, $zero, 1		# Setting $t2 to 1 for render comparison (VALUE AGAIN ALTERED IN LINE 211)
	
	bne $t2, $a2, UPDATE_LOOP	# Skipping to update if the current centipede head is not to be drawn
	
	sw $a1, 0($a0)			# Load the color stored in $a1 at the location pointed by $a0
	
	
UPDATE_LOOP:
	addi $t0, $t0, 1		# increase the value of $t0 by 1
	
	j DISPLAY_CENTIPEDE		# Go back to the function
	

CENTIPEDE_END:
	jr $ra				# jump back to main
	

# ------------------------------------#
#                                     #
#   CENTIPEDE UPDATE FUNCTIONS        #
#                                     #
# ------------------------------------#

UPDATE_CENTIPEDE:
	
# loop over all  the centipedes head and check if the next step in their direction is a mushroom or a endpoint set the values accordingly 
# make a function for each of them

	addi $sp, $sp, -4		# Increasing the stack pointer
	sw $ra, 0($sp)			# Storing the return address

	la $t5, CentiepdeHead		# Holds the location of all the seperate centipods
	la $t7, CentipedeDirections	# Holds the direction each centipede is headed in the next update
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 10		# Set t1 to 10

UPDATE_VALUES_CENTIPEDE:

	bge $t0, $t1, UPDATE_CENTIPEDE_END	# Loop while t1 >= t0
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t5, $t2		# Make $t3 point at right offset for CentipedeHead
	add $t4, $t7, $t2		# Make $t4 point at right offset for CentipedeDirection
	
	
	lw $a0, 0($t3)			# Load the location of the centipede head in $a0
	lw $a1, 0($t4)			# Load the direction of the respective head in $a1
	
	add $a3, $zero, $a0		# Setting the function parameter for FIND_ENDPOINTS_CENTIPEDE
	
	jal FIND_ENDPOINTS_CENTIPEDE		# Calling the function
	
	# At this point in the program $v0 should hold the value of the left endpoint and $v1 should be right endpoint
	
	beq $a1, $zero, MOVE_CENTIPEDE_LEFT 	# If the flea is moving left, jump to MOVE_CENTIPEDE_LEFT else execute MOVE_CENTIPEDE_RIGHT

	
MOVE_CENTIPEDE_RIGHT:
	
	lw $s7, BottomRightEndpoint	# Bottom right end of the screen
	
	beq $a3, $s7, MOVE_AT_BOTTOM_RIGHT		# If the head is at bottom right end of the row, change direction
	
	beq $a3, $v1, MOVE_CENTIPEDE_DOWN_RIGHT_ENDPOINT	# If the head is at right end of the row, skip to move down
	
	addi $a3, $a3, 4				# Else, incrementing the value of flea in that direction
	
	jal CHECK_MUSHROOM_COLLISION
	
	# Here $s6 would contain collision result
	
	addi $t2, $zero, 1				# Setting t2, for comparison
	
	beq $s6, $t2, MUSHROOM_COLLISION_DIR_1		# Branching If Collision is true
	
	jal BUG_BLASTER_COLLISION			# Checking for collision with the bug blaster
	
	sw $a3, 0($t3)					# Painting the head at the new value
	
	j UPDATE_LOOP_CENTIPEDE				# go to the loop updater
	

MOVE_CENTIPEDE_LEFT:

	lw $s6, BottomLeftEndpoint	# Bottom left end of the screen
	
	beq $a3, $s6, MOVE_AT_BOTTOM_LEFT		# If the head is at bottom left end of the row, change direction
	
	beq $a3, $v0, MOVE_CENTIPEDE_DOWN_LEFT_ENDPOINT	# If the head is at left end of the row, skip to move down
	
	addi $a3, $a3, -4				# Else, incrementing the value of head in that direction
	
	jal CHECK_MUSHROOM_COLLISION
	
	# Here $s6 would contain collision result
	
	addi $t2, $zero, 1				# Setting t2, for comparison
	
	beq $s6, $t2, MUSHROOM_COLLISION_DIR_0		# Branching If Collision is true
	
	jal BUG_BLASTER_COLLISION			# Checking for collision with the bug blaster
	
	sw $a3, 0($t3)					# Painting the head at the new value
	
	j UPDATE_LOOP_CENTIPEDE				# go to the loop updater

MUSHROOM_COLLISION_DIR_1:				# Updationg values of the head on collison in direction 1 (right)
	
	addi $a3, $a3, -4
	
	
	j MOVE_CENTIPEDE_DOWN_RIGHT_ENDPOINT
	

MUSHROOM_COLLISION_DIR_0:				# # Updationg values of the head on collison in direction 0 (right)
	
	addi $a3, $a3, 4
	
	j MOVE_CENTIPEDE_DOWN_LEFT_ENDPOINT


MOVE_CENTIPEDE_DOWN_LEFT_ENDPOINT:

	 addi $a3, $a3, 128				# Move the head to the same point in the next row
	 
	 jal BUG_BLASTER_COLLISION			# Checking for collision with the bug blaster
	 
	 sw $a3, 0($t3)					# Painting the head there
		
	 j UPDATE_DIRECTION_TO_1			# Change the direction to 1

MOVE_CENTIPEDE_DOWN_RIGHT_ENDPOINT:

	addi $a3, $a3, 128				# Move the head to the same point in the next row
	
	jal BUG_BLASTER_COLLISION			# Checking for collision with the bug blaster
	
	sw $a3, 0($t3)					# Painting the head there
		
	j UPDATE_DIRECTION_TO_0				# Change the direction to 0

MOVE_AT_BOTTOM_RIGHT:
	
	sw $a3, 0($t3)					# Painting the head there
		
	j UPDATE_DIRECTION_TO_0				# Change the direction to 0

MOVE_AT_BOTTOM_LEFT:
	
	sw $a3, 0($t3)					# Painting the head there
		
	 j UPDATE_DIRECTION_TO_1			# Change the direction to 1


UPDATE_DIRECTION_TO_1:
	
	addi $t8, $zero, 1				# load 1 in t8
	sw $t8, 0($t4)					# Update the list location
	
	j UPDATE_LOOP_CENTIPEDE				# go to the loop updater

UPDATE_DIRECTION_TO_0:
	
	add $t8, $zero, $zero				# load 0 in t8
	sw $t8, 0($t4)					# Update the list location
	
	j UPDATE_LOOP_CENTIPEDE				# go to the loop updater

	
UPDATE_LOOP_CENTIPEDE:
	addi $t0, $t0, 1		# increase the value of $t0 by 1
	
	j UPDATE_VALUES_CENTIPEDE
	
UPDATE_CENTIPEDE_END:
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	

	jr $ra
	
# ------------------------------------#
#                                     #
#   SHOOTER FUNCTION        	      #
#                                     #
# ------------------------------------#

SHOOT_DART:
	
	addi $sp, $sp, -4		# Increasing the stack pointer
	sw $ra, 0($sp)			# Storing the return address

	lw $t0, BugLocation		# Loading the bug location
	
	la $t1, DartLocation		# Loading the word location
	
	sw $t0, 0($t1)			# Bug Location become the location of the dart
	
	
DART_ITERATION:
	
	add $s1, $zero, $zero		# Setting $s1 to 0
	addi $s2, $zero, 31
	
	# Waiting for 50 miliseconds 
	li $v0, 32				
	li $a0, 25
	syscall
	
	
MOVE_DART:
	
	bge $s1, $s2, DART_END
	
	
	lw $t7, Black			# just black
	
	la $t1, DartLocation		# Loading the word location
	
	lw $t0, 0($t1)			# Load the current value of the dart
	
	sw $t7, 0($t0)			# Blacking out the old dart position
	sw $t7, -128($t0)			
	
	addi $t0, $t0, -128		# Moving the dart up by one row
	
	sw $t0, 0($t1)			# Changing the dart value
	
	add $a3, $zero, $t0		# Getting the argument to the collision function ready
	
	# Check for Collision with mushroom
	
	addi $a2, $zero, 1
	
	jal CHECK_MUSHROOM_COLLISION
	
	beq $a2, $s6, DART_COLLISION		# If there is collision, take care of it lmao by setting the render 0	
	
	# Check for Collision with Centipede
	jal CENTIPEDE_COLLISION
	
	beq $a2, $s6, DART_COLLISION		# If there is collision, take care of it lmao by setting the render 0
	
	j DRAW_DART

DART_COLLISION:
	
	sw $zero, 0($s7)			# Make the render for the object 0
	j DART_END
	
					
DRAW_DART:
	
	lw $t3, DartColor			# Loading purple into DartColor
		
	sw $t3, 0($a3)				# Drawing the new dart position
	sw $t3, -128($a3)				# Drawing the new dart position
	sw $t3, -256($a3)				# Drawing the new dart position
	

DRAW_TWO_LATER_ADDITIONAL:
	
	sw $t3, -256($a3)
	
UPDATE_DART_ITERATION:

	addi $s1, $s1, 1		# Updating the loop iterator
	
	j MOVE_DART
	
DART_END:
	
	lw $t7, Black			# just black
	sw $t7, 0($a3)			# Blacking the darts
	sw $t7, -128($a3)			
	sw $t7, -256($a3)		
	
	lw $t1, DartLocation		# Loading the word location
	
	sw $t7, 0($t1)			# Load the current value of the dart
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra				# returning to the calling function
	
	
	

# --------------------------#
#                           #
#   MUSHROOM FUNCTIONS      #
#                           #
# --------------------------#

LOAD_MUSHROOM_DATA:

	la $t8, MushroomHead		# Load the mushroom head in t8
	la $t4, RenderMushroom		# Load the render_mushroom in t5
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 8		# Set t1 to 8
			
	
DISPLAY_MUSHROOMS:

	bge $t0, $t1, MUSHROOM_END	# Loop while t1 >= t0
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t8, $t2		# Make $t3 point at right offset
	
	lw $a0, 0($t3)			# Load the location of the mushroom head in $a0
	
	
MUSHROOM_LOOP:

	# $a0 holds the value of the head of the mushroom
	
	# Loading the color of the mushrooms
	lw $t7, MushroomTopColor	
	lw $t6, MushroomBaseColor
	
	# setting a2 to 1 for comparison
	addi $a2, $zero, 1
	
	# Rendering the mushroom head
	
	lw $a1, 0($t4) 			# Loading the current value at render_mushroom into a1
	
		
DRAW_MUSHROOM_HEAD:

	bne $a1, $a2, DRAW_MUSHROOM_MIDDLE_LEFT		# Skipping to drawing middle left if current not be drawn
	
	sw $t7, 0($a0)			# Drawing the head of the mushroom

DRAW_MUSHROOM_MIDDLE_LEFT:

	add $t4, $t4, 4			# Increasing t4 by 4
	lw $a1, 0($t4) 			# Loading the current value at render_mushroom into a1
	
	
	bne $a1, $a2, DRAW_MUSHROOM_MIDDLE		# Skipping to drawing middle  if current not be drawn
	
	addi $a3, $a0, 124		# Pointing the left part of the middle row
	sw $t7, 0($a3)			# Drawing the left part of the middle row of the mushroom
	

DRAW_MUSHROOM_MIDDLE:
	
	add $t4, $t4, 4			# Increasing t4 by 4
	lw $a1, 0($t4) 			# Loading the current value at render_mushroom into a1
	
	bne $a1, $a2, DRAW_MUSHROOM_MIDDLE_RIGHT	# Skipping to drawing middle right if current not be drawn
	
	addi $a3, $a0, 128		# Pointing the middle part of the middle row
	sw $t7, 0($a3)			# Drawing the middle part of the middle row of the mushroom


DRAW_MUSHROOM_MIDDLE_RIGHT:
	
	add $t4, $t4, 4			# Increasing t4 by 4
	lw $a1, 0($t4) 			# Loading the current value at render_mushroom into a1

	bne $a1, $a2, DRAW_MUSHROOM_BASE		# Skipping to drawing base if current not be drawn
	
	addi $a3, $a0, 132		# Pointing the right part of the middle row
	sw $t7, 0($a3)			# Drawing the right part of the middle row of the mushroom

DRAW_MUSHROOM_BASE:
	
	add $t4, $t4, 4			# Increasing t4 by 4
	lw $a1, 0($t4) 			# Loading the current value at render_mushroom into a1
	
	bne $a1, $a2, UPDATE_MUSHROOM_LOOP		# Skipping to update if current not be drawn
	
	addi $a3, $a0, 256		# Pointing the base of the mushroom
	sw $t6, 0($a3)			# Drawing the base of the mushroom

UPDATE_MUSHROOM_LOOP:
	
	add $t4, $t4, 4			# Increasing t4 by 4
	
	addi $t0, $t0, 1 		# Incrementing the position in the array mushroom_head by 1
	
	j DISPLAY_MUSHROOMS 		# Hop back to display mushrooms


MUSHROOM_END:
	jr $ra				# Go back to main
	
	

#------Function to put the random mushroom values in the array Mushroom Head--------#

RANDOMIZE_MUSHROOMS:
	
	addi $sp, $sp, -4		# Increasing the stack pointer
	sw $ra, 0($sp)			# Storing the return address
	
	la $t8, MushroomHead		# Load the mushroom head array in t8
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 8		# Set t1 to 8

RANDOM_MUSHROOM_LOOP:

	bge $t0, $t1, RANDOM_MUSHROOM_END	# Loop while t1 >= t0

	jal GENERATE_RANDOM_MUSHROOM
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t8, $t2		# Make $t3 point at right offset
	
	lw $t4, displayAddress
	
	add $s2, $s2, $t4		# Add s2 to the base address value
	
	sw $s2, 0($t3)			# Set the value of the mushroom head 
	
	addi $t0, $t0, 1 		# Incrementing the position in the array by 1
	
	j RANDOM_MUSHROOM_LOOP		# go back to the start of the function
	


RANDOM_MUSHROOM_END:
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra				# returning to main


# --------------------------#
#                           #
#   FLEA FUNCTION           #
#                           #
# --------------------------#


CHECK_RANDOM_FLEA:
	
	lw $t1, FleaRender				# Checking if there already a flea on the screen
	
	beq $t1, $zero, MAKE_RANDOM_FLEA
	
	jr $ra
	
MAKE_RANDOM_FLEA:
	
	# Generate a random number between 0-3 and store in $a0
	li $v0, 42
	li $a0, 0
	li $a1, 3
	syscall
	
	beq $a0, $zero, RENDER_FLEA			# Drawing the flea at random times
	
	jr $ra
	
RENDER_FLEA:
	
	# Generate a random number between 0-30 and store in $a0
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	lw $t0, displayAddress		# Load the display address
	sll $a0, $a0, 2			# Multiply the address by 4
	add $a0, $a0, $t0		# This is the start value of the flea
	
	la $t1, FleaLocation		# Loading values for use
	la $t2, FleaRender						 
	
	sw $a0, 0($t1)			# Saving the start value of FLEA
	
	addi $a2, $zero, 1		# Setting $a2 to 1
	sw $a2, 0($t2)			# Setting the render value of flea to 1
	
	jr $ra
	

CHECK_UPDATE_FLEA:
	
	addi $sp, $sp, -4		# Increasing the stack pointer
	sw $ra, 0($sp)			# Storing the return address

	lw $t2, FleaRender
	addi $a2, $zero, 1		# Setting $a2 to 1
	
	beq $t2, $a2, UPDATE_FLEA	# If the flea is supposed to be rendered then, else do nothing
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra				# returning to the calling function		

UPDATE_FLEA:
	
	la $t1, FleaLocation 		# Loading the memory address where FleaLocation is Stored
	
	lw $t2, FleaLocation		# Loading the value of FleaLocation
	
	lw $t4, BottomLeftEndpoint	# Loading the value of the left bottom endpoint of the screen
	
	lw $t5, Black			# Loading the black color in $t5
	
	sw $t5, 0($t2)
	
	addi $a3, $t2, 128		# Moving the flea one row down
	
	jal BUG_BLASTER_COLLISION	# Checking for collision with the bugBlaster
	
	jal FIND_ENDPOINTS_CENTIPEDE	# Checking if the flea has got to the end of the screen
	
	beq $v0, $t4, STOP_FLEA_RENDER	# If the endpoint reached then flea render is set to 0
	
	sw $a3, 0($t1)
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra				# returning to the calling function


STOP_FLEA_RENDER:
	
	la $t1, FleaRender
	
	sw $zero, 0($t1)		# Set the Flea Render to 0
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra				# returning to the calling function


CHECK_DRAW_FLEA:

	lw $t2, FleaRender
	addi $a2, $zero, 1		# Setting $a2 to 1
	
	beq $t2, $a2, DRAW_FLEA 	# If the flea is supposed to be rendered then, else do nothing
	
	jr $ra

DRAW_FLEA:
	
	lw $t2, FleaLocation	
	lw $t3, FleaColor
	sw $t3, 0($t2)			# Drawing the flea at the appropriate location
	
	jr $ra


# --------------------------#
#                           #
#   RANDOM FUNCTION         #
#                           #
# --------------------------#

GENERATE_RANDOM_MUSHROOM:
	
	add $s2, $zero, $zero		# Setting the value of s2 used to zero
	add $s3, $zero, $zero		# Setting the value of s2 used to zero
	
	
	addi $sp, $sp, -4		# Increasing the stack pointer
	sw $ra, 0($sp)			# Storing the return address

	
	# Generate a random number and store it in $a0 which can be between 
	li $v0, 42
	li $a0, 0
	li $a1, 29
	syscall
	
	# storing the value of the random integer in $s2 for the x position of the mushroom
	add $s2, $s2, $a0
	
	addi $s2, $s2, 1		# Incrementing the value in x position by 1
	sll $s2, $s2, 2			# Muliplying the number by 4
	
	
	
	# Generate a random number and store it in $a0 which can be between 
	li $v0, 42
	li $a0, 0
	li $a1, 24
	syscall
	
	# storing the value of the random integer in $s3 for the y position of the mushroom
	add $s3, $s3, $a0
	
	addi $s3, $s3, 1		# Incrementing the value in y position by 1
	
	sll $s3, $s3, 7 		# Multiplying the number by 128
	
	add $s2, $s2, $s3 		# Adding both x and y values to get the position where to draw the head of the mushroom
	
	lw $ra, 0($sp)			# Loading the return address
	addi $sp, $sp, 4		# Lowering the stack pointer
	
	jr $ra
	

# --------------------------#
#                           #
#  EXTRA MEMORY FUNCTIONS   #
#                           #
# --------------------------#


#-------FUNCTION TO SET CENTIPEDE VALUES CORRECTLY---------#

SET_INITIAL_CENTIPEDE:

	la $t5, CentiepdeHead		# Holds the location of all the seperate centipods
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 10		# Set t1 to 10
	
CENTIPEDE_MEMSET_LOOP:

	bge $t0, $t1, CENTIPEDE_MEMSET_END	# Loop while t1 >= t0
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t5, $t2		# Make $t3 point at right offset
	
	lw $t4, displayAddress		# set t4 to 0x10008000
	
	add $t4, $t4, $t2		# Add 4 * val($t0) to the base address value
	
	sw $t4, 0($t3)			# Set the value of the centipede head 
	
	addi $t0, $t0, 1 		# Incrementing the position in the array by 1
	
	j CENTIPEDE_MEMSET_LOOP		# go back to the start of the function



CENTIPEDE_MEMSET_END:	
	jr $ra				# go back to MEMORY_LOADER
	


#-------FUNCTION TO SET ALL PREVIOUS CENITPEDE CENTIPEDE BLACK---------#

SET_CENTIPEDE_BLACK:

	la $t5, CentiepdeHead		# Holds the location of all the seperate centipods
	
	add $t0, $zero, $zero 		# Set t0 to 0
	addi $t1, $zero, 10		# Set t1 to 10
	
	lw $t7, Black 			# t7 is used to store black color
	
CENTIPEDE_BLACK_LOOP:

	bge $t0, $t1, CENTIPEDE_BLACK_END	# Loop while t1 >= t0
	
	sll $t2, $t0, 2			# Multiply by 4 to make $t2 have the right offset 
	add $t3, $t5, $t2		# Make $t3 point at right offset
	
	lw $t4, 0($t3)			# Load the current location of the centipod/flea
	
	sw $t7, 0($t4)			# Set the value of the cenitiepde flea 
	
	addi $t0, $t0, 1 		# Incrementing the position in the array by 1
	
	j CENTIPEDE_BLACK_LOOP		# go back to the start of the function



CENTIPEDE_BLACK_END:	
	jr $ra				# go back to MEMORY_LOADER


#-------FIND ENDPOINTS FOR A GIVEN CENTIPEDE CENTIPEDE------#

FIND_ENDPOINTS_CENTIPEDE:
	
	# Assuming $a3 points to the given element in the array
	
	add $s1, $zero, $a3			# Storing the current location of the centipede in  $s1
	lw $s0, displayAddress 		# Storing the display address in $s2
	
	addi $s1, $s1, -268468224		# Finding the values in as mulitple of 128
	
	addi $s2, $zero, 128		# Setting the value of $s2 to 128
	
	srl $s1, $s1, 7			# dividing to find the current row
	
	add $v0, $zero, $s1			# Storing the quotient in $v0
	
	sll $v0, $v0, 7			# Multiplying the row number * 128
	
	addi $v1, $v0, 124		# $v1 contains the right end point of the row
	
	
	# Adding the display address to make set v0 and v1 to the right respective points on the bitmap display
	add $v0, $v0, $s0	
		
	add $v1, $v1, $s0
	
	
	jr $ra
	
	
#-------FIND IF A PIXEL IS COLLIDING WITH A RENDER MUSHROOM------#	
# The value of the argument is stored in $a3

CHECK_MUSHROOM_COLLISION:
	
	la $t8, MushroomHead		# Load the mushroom head in t8
	la $t9, RenderMushroom		# Load the render_mushroom in t9
	
	add $s3, $zero, $zero 		# Set t0 to 0
	addi $s4, $zero, 8		# Set t1 to 8
			
	
MUSHROOMS_COLLIDE:

	bge $s3, $s4, CHECK_MUSHROOM_END	# Loop while t1 >= t0
	
	sll $t2, $s3, 2			# Multiply by 4 to make $t2 have the right offset 
	add $s5, $t8, $t2		# Make $t3 point at right offset
	
	lw $s7, 0($s5)			# Load the location of the mushroom head in $s7
	
	
MUSHROOM_COLLISION_LOOP:

	# $s7 holds the value of the head of the mushroom
	
	# setting a2 to 1 for comparison
	addi $a2, $zero, 1
	
	# Rendering the mushroom head
	
		
CHECK_MUSHROOM_HEAD:

	beq $s7, $a3, CHECK_RENDER	# checking if the mushroom part is rendered or not
	
	addi $s7, $s7, 124		# Pointing the left part of the middle row

CHECK_MUSHROOM_MIDDLE_LEFT:

	addi $t9, $t9, 4			# Increasing t9 by 4
	
	beq $s7, $a3, CHECK_RENDER		# Skipping to drawing middle  if current not be drawn
	
	addi $s7, $s7, 4			# Pointing the left part of the middle row
	

CHECK_MUSHROOM_MIDDLE:
	
	addi $t9, $t9, 4			# Increasing t9 by 4
	
	beq $s7, $a3, CHECK_RENDER		# Skipping to drawing middle  if current not be drawn
	
	addi $s7, $s7, 4			# Pointing the left part of the middle row

CHECK_MUSHROOM_MIDDLE_RIGHT:
	
	addi $t9, $t9, 4			# Increasing t9 by 4
	
	beq $s7, $a3, CHECK_RENDER		# Skipping to drawing middle  if current not be drawn
	
	addi $s7, $s7, 124			# Pointing the left part of the middle row

CHECK_MUSHROOM_BASE:
	
	addi $t9, $t9, 4			# Increasing t9 by 4
	
	beq $s7, $a3, CHECK_RENDER		# Skipping to drawing middle  if current not be drawn
	
	j UPDATE_CHECK_MUSHROOM_LOOP

CHECK_RENDER:
	
	lw $s6, 0($t9) 			# Loading the current value at render_mushroom into s6
	
	beq $s6, $a2, COLLISION_TRUE	# If the render value of  at t9 is 1, then jump to collision_true
	
UPDATE_CHECK_MUSHROOM_LOOP:
	
	addi $t9, $t9, 4			# Increasing t9 by 4
	
	addi $s3, $s3, 1 		# Incrementing the position in the array mushroom_head by 1
	
	j MUSHROOMS_COLLIDE 		# Hop back to display mushrooms


COLLISION_TRUE: 

	addi $s6, $zero, 1		# Setting s6 to 1 as collision is true
	
	add $s7, $zero, $t9		# Setting the memory address of the render value of the object there was a collision with
	
	jr $ra

CHECK_MUSHROOM_END:
	add $s6, $zero, $zero
	
	jr $ra				# Go back to main


#-------FIND IF A PIXEL IS COLLIDING BUG BLASTER------#
# The value of the argument is stored in $a3

BUG_BLASTER_COLLISION:
	
	lw $t8, BugLocation			# loading the bug location is $t8
	
	bne $a3, $t8, BUG_COLLISION_FALSE	# checking if the pixel has collided with the bug	
	
BUG_COLLISION_TRUE:
	
	jal COLOR_ALL_BLACK			# coloring everything back
	jal GAME_OVER_TEXT			# displaying the game over text
	
	j RETRY					# waiting for the user to retry

BUG_COLLISION_FALSE:
	
	jr $ra

#------FIND IF A PIXEL IS COLLIDING THE WITH THE CENTIPEDE-------#
# The value of the argument is stored in $a3

CENTIPEDE_COLLISION:

	la $t8, CentiepdeHead		# Load the centipede head in t8
	la $t9, RenderCentipede		# Load the render_centipede in t9
	
	add $s3, $zero, $zero 		# Set s3 to 0
	addi $s4, $zero, 10		# Set s4 to 10
	

CENTIPEDE_COLLIDE:

	bge $s3, $s4, CHECK_CENTIPEDE_END	# Loop while s4 >= s4
	
	sll $t2, $s3, 2			# Multiply by 4 to make $t2 have the right offset 
	add $s5, $t8, $t2		# Make $s5 point at right offset
	
	lw $s7, 0($s5)			# Load the location of the centipede head in $s7
	
	
	# setting a2 to 1 for comparison
	addi $a2, $zero, 1


CHECK_COLLISION_CENTIPEDE:
	
	beq $s7, $a3, CHECK_CENTIPEDE_RENDER		# if there is collision check if the object is rendered for "actual collison"
	
	j UPDATE_CHECK_CENTIPEDE
	
CHECK_CENTIPEDE_RENDER:

	add $s7, $t9, $t2		# s7 now points to the location where the render value is stored
	
	lw $s5, 0($s7)			# Loading the render value in s5
	
	beq $s5, $a2, CENTIPEDE_COLLISION_TRUE	# if render is 1 then, there is an actual collision
	
		
UPDATE_CHECK_CENTIPEDE:

	addi $s3, $s3, 1 		# Incrementing the loop counter
	
	j CENTIPEDE_COLLIDE 		# Hop back to centipede_collide
	
CENTIPEDE_COLLISION_TRUE:
	
	addi $s6, $zero, 1		# Setting the return value to 1 in case of a true collision
	
	jr $ra		

CHECK_CENTIPEDE_END:
	add $s6, $zero, $zero		# Setting the return value to 0 in case of a false collision
	
	jr $ra

#------CHECKING IF ALL THE CENITPEDE HEADS HAVE BEEN HIT-------#

CHECK_ALL_HIT:
	la $t9, RenderCentipede		# Load the render_centipede in t9
	
	add $s3, $zero, $zero 		# Set s3 to 0
	addi $s4, $zero, 10		# Set s4 to 10

CHECK_HIT_LOOP:
	
	bge $s3, $s4, ALL_HIT		# Loop while s4 >= s3
	
	sll $t2, $s3, 2			# Multiply by 4 to make $t2 have the right offset 
	add $s5, $t9, $t2		# Make $s5 point at right offset
	
	lw $s7, 0($s5)			# Load the location of the centipede head in $s7
	
	
	# setting a2 to 1 for comparison
	addi $a2, $zero, 1
	
CHECK_HIT:
	
	beq $a2, $s7, NOT_HIT
	
	j HIT_UPDATE			# keep checking if all of them have been hit		

NOT_HIT:			
	
	jr $ra				# go back if even one of the centipede head is not hit
	
HIT_UPDATE:
	addi $s3, $s3, 1 		# Incrementing the position in the array render_centipede by 1
	
	j CHECK_HIT_LOOP		# Hop back to display check_hit

ALL_HIT:
	j MEMORY_LOADER			# Start the execution again


#------SETTING THE RENDER FOR EVERYTHING T0 1-------#

RENDER_TO_1:

	# setting a2 to 1 to set memory correctly
	addi $a2, $zero, 1

RENDER_CENTIPEDE_TO_1:
	la $t9, RenderCentipede		# Load the render_centipede in t9
	la $t8, CentipedeDirections 	
	
	add $s3, $zero, $zero 		# Set s3 to 0
	addi $s4, $zero, 10		# Set s4 to 10
	
C_LOOP:

	bge $s3, $s4, RENDER_MUSHROOMS_TO_1	# Loop while s3 >= s4
	
	sll $t2, $s3, 2			# Multiply by 4 to make $t2 have the right offset 
	add $s5, $t9, $t2		# Make $s5 point at right offset in RenderCentipede
	add $s6, $t8, $t2		# Make $s6 point at right offset in CentipedeDirections
	
	sw $a2, 0($s5)			# Load the location of the centipede head in $s7
	sw $a2, 0($s6)		

C_UPDATE:
	
	addi $s3, $s3, 1		# updating loop counter
	
	j C_LOOP

RENDER_MUSHROOMS_TO_1:
	la $t9, RenderMushroom	# Load the render_mushroom in t9
	
	add $s3, $zero, $zero 		# Set s3 to 0
	addi $s4, $zero, 40		# Set s4 to 10
	
R_LOOP:

	bge $s3, $s4, RENDER_TO_1_END	# Loop while s3 >= s4
	
	sll $t2, $s3, 2			# Multiply by 4 to make $t2 have the right offset 
	add $s5, $t9, $t2		# Make $t3 point at right offset
	
	sw $a2, 0($s5)			# Load the location of the centipede head in $s7

R_UPDATE:
	
	addi $s3, $s3, 1
	
	j R_LOOP


RENDER_TO_1_END:
	
	jr $ra


#------COLOR EVERYTHING BLACK-------#

COLOR_ALL_BLACK:
	
	lw $t2, displayAddress
	lw $t3, Black			
	
	add $t0, $zero, $zero
	
	addi $t1, $zero, 1024			# iterating on all the pixels
	
ALL_BLACK_LOOP:
	
	bge $t0, $t1, ALL_BLACK_END
	
	sw $t3, 0($t2)				# Setting the current pixed to black

ALL_BLACK_UPDATE:
	
	addi $t0, $t0, 1
	addi $t2, $t2, 4

	j ALL_BLACK_LOOP

ALL_BLACK_END:
	
	la $t1, FleaRender
	
	sw $zero, 0($t1)		# Set the Flea Render to 0
	
	jr $ra

#------GAME OVER TEXT-------#

GAME_OVER_TEXT:

	lw $t0, Yellow
	lw $t1, displayAddress
	
	# Hard Coding each letter
	
	
	# LETTER GAME -------------
	# Letter G
	sw $t0, 792($t1)
	sw $t0, 796($t1)
	sw $t0, 800($t1)
	sw $t0, 804($t1)
	sw $t0, 920($t1)
	sw $t0, 1048($t1)
	sw $t0, 1056($t1)
	sw $t0, 1060($t1)
	sw $t0, 1176($t1)
	sw $t0, 1188($t1)
	sw $t0, 1304($t1)
	sw $t0, 1308($t1)
	sw $t0, 1312($t1)
	sw $t0, 1316($t1)
	
	# Letter A
	sw $t0, 812($t1)
	sw $t0, 816($t1)
	sw $t0, 820($t1)
	sw $t0, 940($t1)
	sw $t0, 1068($t1)
	sw $t0, 1072($t1)
	sw $t0, 1076($t1)
	sw $t0, 1196($t1)
	sw $t0, 1324($t1)
	sw $t0, 824($t1)
	sw $t0, 952($t1)
	sw $t0, 1080($t1)
	sw $t0, 1208($t1)
	sw $t0, 1336($t1)
	
	# Letter M
	sw $t0, 832($t1)
	sw $t0, 836($t1)
	sw $t0, 960($t1)
	sw $t0, 1088($t1)
	sw $t0, 1216($t1)
	sw $t0, 1344($t1)
	sw $t0, 840($t1)
	sw $t0, 844($t1)
	sw $t0, 968($t1)
	sw $t0, 1096($t1)
	sw $t0, 848($t1)
	sw $t0, 976($t1)
	sw $t0, 1104($t1)
	sw $t0, 1232($t1)
	sw $t0, 1360($t1)
	
	# Letter E
	sw $t0, 856($t1)
	sw $t0, 860($t1)
	sw $t0, 864($t1)
	sw $t0, 984($t1)
	sw $t0, 1112($t1)
	sw $t0, 1116($t1)
	sw $t0, 1120($t1)
	sw $t0, 1240($t1)
	sw $t0, 1368($t1)
	sw $t0, 1372($t1)
	sw $t0, 1376($t1)
	
	
	# LETTER OVER --------------
	
	# Letter O 
	sw $t0, 1560($t1)
	sw $t0, 1564($t1)
	sw $t0, 1568($t1)
	sw $t0, 1572($t1)
	sw $t0, 1688($t1)
	sw $t0, 1816($t1)
	sw $t0, 1700($t1)
	sw $t0, 1828($t1)
	sw $t0, 1944($t1)
	sw $t0, 1956($t1)
	sw $t0, 2072($t1)
	sw $t0, 2076($t1)
	sw $t0, 2080($t1)
	sw $t0, 2084($t1)
	
	# Letter V
	sw $t0, 1580($t1)
	sw $t0, 1708($t1)
	sw $t0, 1836($t1)
	sw $t0, 1840($t1)
	sw $t0, 1968($t1)
	sw $t0, 1972($t1)
	sw $t0, 1976($t1)
	sw $t0, 2100($t1)
	sw $t0, 1848($t1)
	sw $t0, 1852($t1)
	sw $t0, 1596($t1)
	sw $t0, 1724($t1)
	
	# Letter E
	sw $t0, 1604($t1)
	sw $t0, 1608($t1)
	sw $t0, 1612($t1)
	sw $t0, 1732($t1)
	sw $t0, 1860($t1)
	sw $t0, 1864($t1)
	sw $t0, 1868($t1)
	sw $t0, 1988($t1)
	sw $t0, 2116($t1)
	sw $t0, 2120($t1)
	sw $t0, 2124($t1)
	
	# Letter R
	sw $t0, 1620($t1)
	sw $t0, 1624($t1)
	sw $t0, 1628($t1)
	sw $t0, 1632($t1)
	sw $t0, 1748($t1)
	sw $t0, 1760($t1)
	sw $t0, 1876($t1)
	sw $t0, 1880($t1)
	sw $t0, 1884($t1)
	sw $t0, 1888($t1)
	sw $t0, 2004($t1)
	sw $t0, 2012($t1)
	sw $t0, 2132($t1)
	sw $t0, 2140($t1)
	sw $t0, 2144($t1)

	jr $ra



#------RETRY LOGIC------#
# PRESS ANY KEY TO START THE GAME AGAIN
RETRY:
	
lw $t8, 0xffff0000		
beq $t8, 1, CHECK_RETRY			# branching if a key is pressed

j RETRY

CHECK_RETRY:
	j MEMORY_LOADER			# Starting the execution again












