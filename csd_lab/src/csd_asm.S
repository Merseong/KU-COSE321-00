#define csd_LED_ADDR 0x41200000

.extern csd_main

.global main
main:
	// load inital points
	ldr r0, =Input_data		// r0: input address
	ldr r1, =Output_data	// r1: output address
	mov r2, #32				// r2: count of input data
	mov r3, r2				// r3: left seat of output
	mvn r10, #0x80000000	// r10: constant for 0x7FFF_FFFF(max signed integer)

sort_loop:
	mov r4, r2				// r4: left numbers on find minimum
	mov r5, r10				// r5: minimum number on find_min_loop
	mov r6, r0				// r6: address of minimum number
	mov r7, r0				// r7: address of checking point
	bl find_min_loop		// goto find_min_loop

	str r5, [r1], #4		// store the word to memory[r1] and update r1 (= r1 + 4)
	str r10, [r6]			// store 0x7FFF_FFFF into minimum number

 	subs r3, r3, #1			// r3 = r3 - 1 and update NZCV
 	bne sort_loop			// if (r3 != 0) goto sort_loop

 	b after_loop			// if (r3 == 0) goto after_loop (end calc)

find_min_loop:
	ldr r8, [r7], #4		// load the word in [r7] to r8, update r7 = r7 + 4
	cmp r8, r5				// r8 - r5 => refresh NZCV
	blt	find_min_loop_min_found		// N set means r5 > r8

	b find_min_loop_after	// if (r5 <= r8) not doing min_found action

find_min_loop_min_found:
	mov r5, r8				// r5 (min value) = r8
	sub r6, r7, #4			// r6 (min address) = r7 - 4

	b find_min_loop_after	// do ++j action

find_min_loop_after:
	subs r4, r4, #1			// r4 = r4 - 1 and update NZCV
	bne find_min_loop		// if (r4 != 0) do find_min_loop again

	movs pc, lr				// if (r4 == 0) go back to sort_loop

after_loop:
 	ldr r0, =csd_LED_ADDR
 	mov r1, #0x5
 	str r1, [r0]

 	bl csd_main

forever:
	nop
 	b forever

.data
.align 4

Input_data:
	.word 2, 0, -7, -1, 3, 8, -4, 10
 	.word -9, -16, 15, 13, 1, 4, -3, 14
 	.word -8, -10, -15, 6, -13, -5, 9, 12
 	.word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:
	.word 0, 0, 0, 0, 0, 0, 0, 0
 	.word 0, 0, 0, 0, 0, 0, 0, 0
 	.word 0, 0, 0, 0, 0, 0, 0, 0
 	.word 0, 0, 0, 0, 0, 0, 0, 0
