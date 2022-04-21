#define csd_LED_ADDR 0x41200000

#include "uart_regs.h"
#include "uart_init.s"

.macro print_temp_register reg
	ldr r9, =print_temp
	strb \reg, [r9]
	bl UART_print_r9
.endm

.macro print_by_hex empty_reg empty_reg2 data_reg table_reg
	ldr \table_reg, =hex_to_ascii
	and \empty_reg, \data_reg, #0xF0000000
	mov \empty_reg, \empty_reg, LSR #26
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x0F000000
	mov \empty_reg, \empty_reg, LSR #22
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x00F00000
	mov \empty_reg, \empty_reg, LSR #18
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x000F0000
	mov \empty_reg, \empty_reg, LSR #14
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x0000F000
	mov \empty_reg, \empty_reg, LSR #10
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x00000F00
	mov \empty_reg, \empty_reg, LSR #6
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0x000000F0
	mov \empty_reg, \empty_reg, LSR #2
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg

	and \empty_reg, \data_reg, #0xF
	mov \empty_reg, \empty_reg, LSL #2
	add \empty_reg, \empty_reg, \table_reg
	ldr \empty_reg, [\empty_reg]
	print_temp_register \empty_reg
.endm

.macro my_debugger
	// save previous data into stack
	stmfd sp!, {sp}
	stmfd sp!, {pc}
	stmfd sp!, {r0-r12, lr}
	mrs r0, CPSR_all
	stmfd sp!, {r0}	// save CPSR
	// 17 data saved
	// (sp)/ CPSR / 0 ~ 12 / lr / pc / sp /(10c030)

	// do anything from here
		// print start dash
	ldr r9, =start_end_dash
	bl UART_print_r9

	// print r0~r12
	mov r0, #1		// r0: current reading register index, 1 based
	add r1, sp, #4	// r1: address of r0
	ldr r3, =int_to_str	// r3: address in int_to_str

	sub r2, pc, #8		// r2: iterate point is here

		// print "r"
	mov r4,	#114
	print_temp_register r4

		// print "##" (index of register)
	ldr r4, [r3], #4
	cmp r4, #0
	addne r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4

	ldr r4, [r3], #4
	add r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4

		// print " = 0x"
	ldr r9, =reg_prefix
	bl UART_print_r9

		// print value of *r1
	ldr r9, =print_temp
	ldr r4, [r1]		// r4: *r1

	print_by_hex r5 r6 r4 r10

		// print ", " of "(CR)(LF)"
	ands r4, r0, #3
	ldrne r9, =suffix
	ldreq r9, =enter_only
	bl UART_print_r9

	cmp r0, #13
	addne r0, r0, #1
	addne r1, r1, #4
	movne pc, r2			// go back to iterate point (r2)

	// print r13=sp, r14=lr, r15=pc (stack has lr / pc / sp order)
	mov r0, r3			// r0: address in int_to_str (used before)
	add r1, r1, #4		// r1: address of 'lr' in stack

		// print r13 = sp
		// print "r13 = 0x"
	mov r4,	#114
	print_temp_register r4
	ldr r4, [r0], #4
	cmp r4, #0
	addne r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r4, [r0], #4
	add r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r9, =reg_prefix
	bl UART_print_r9

		// print sp value
	add r2, r1, #8
	ldr r2, [r2]
	print_by_hex r3 r4 r2 r10

		// print ", "
	ldr r9, =suffix
	bl UART_print_r9

			// print r14 = lr
		// print "r14 = 0x"
	mov r4,	#114
	print_temp_register r4
	ldr r4, [r0], #4
	cmp r4, #0
	addne r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r4, [r0], #4
	add r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r9, =reg_prefix
	bl UART_print_r9

		// print lr value
	mov r2, r1
	ldr r2, [r2]
	print_by_hex r3 r4 r2 r10

		// print ", "
	ldr r9, =suffix
	bl UART_print_r9

			// print r15 = pc
		// print "r15 = 0x"
	mov r4,	#114
	print_temp_register r4
	ldr r4, [r0], #4
	cmp r4, #0
	addne r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r4, [r0], #4
	add r4, r4, #48	// change r4(int) to ascii
	print_temp_register r4
	ldr r9, =reg_prefix
	bl UART_print_r9

		// print pc value
	add r2, r1, #4
	ldr r2, [r2]
	print_by_hex r3 r4 r2 r10

		// print "(CR)(LF)"
	ldr r9, =enter_only
	bl UART_print_r9

	// print cpsr, current mode
	mov r0, sp		// r0: location of cpsr
	ldr r1, [r0]	// r1: value of cpsr
		// print "cpsr = "
	ldr r9, =cpsr_prefix
	bl UART_print_r9
		// print n or N
	mov r2, #1
	mov r2, r2, LSL #31
	ands r2, r1, r2
	moveq r2, #110	// "n" on clear
	movne r2, #78	// "N" on set
	print_temp_register r2
		// print z or Z
	mov r2, #1
	mov r2, r2, LSL #30
	ands r2, r1, r2
	moveq r2, #122	// "z" on clear
	movne r2, #90	// "Z" on set
	print_temp_register r2
		// print c or C
	mov r2, #1
	mov r2, r2, LSL #29
	ands r2, r1, r2
	moveq r2, #99	// "c" on clear
	movne r2, #67	// "C" on set
	print_temp_register r2
		// print v or V
	mov r2, #1
	mov r2, r2, LSL #28
	ands r2, r1, r2
	moveq r2, #118	// "v" on clear
	movne r2, #86	// "V" on set
	print_temp_register r2

		// print ", "
	ldr r9, =suffix
	bl UART_print_r9

		// print "IF, ARM mode, current mode = "
	ldr r9, =mode_prefix
	bl UART_print_r9

		// print current mode
	ldr r9, =mode_ascii
	and r2, r1, #0xF	// get last 4 to find out mode
	sub r3, pc, #8		// start loop
	cmp r2, #0
	subne r2, r2, #1
	add r9, r9, #4
	movne pc, r3		//	end loop
	bl UART_print_r9

		// print " ("
	mov r4,	#32
	print_temp_register r4
	mov r4,	#40
	print_temp_register r4

		// print full cpsr
	print_by_hex r3 r4 r1 r10

		// print ")(CR)(LF)"
	mov r4,	#41
	print_temp_register r4
	ldr r9, =enter_only
	bl UART_print_r9

	// print end dash and (CR)(LF)
	ldr r9, =start_end_dash
	bl UART_print_r9
	ldr r9, =enter_only
	bl UART_print_r9

	// load data from stack, restore data
	ldmfd sp!, {r0}	// load CPSR
	msr CPSR_all, r0
	ldmfd sp!, {r0-r12, lr}
	sub sp, sp, #-8
.ltorg
.endm

.global main
main:
	UART_init
	my_debugger

	// load inital points
	ldr r0, =Input_data		// r0: input address
	ldr r1, =Output_data	// r1: output address
	my_debugger
	mov r2, #32				// r2: count of input data
	mov r3, r2				// r3: left seat of output
	mvn r9, #0x80000000	// r9: constant for 0x7FFF_FFFF(max signed integer)
	my_debugger

sort_loop:
	mov r4, r2				// r4: left numbers on find minimum
	mov r5, r9				// r5: minimum number on find_min_loop
	mov r6, r0				// r6: address of minimum number
	mov r7, r0				// r7: address of checking point
	bl find_min_loop		// goto find_min_loop
	my_debugger

	str r5, [r1], #4		// store the word to memory[r1] and update r1 (= r1 + 4)
	str r9, [r6]			// store 0x7FFF_FFFF into minimum number

 	subs r3, r3, #1			// r3 = r3 - 1 and update NZCV
 	my_debugger
 	bne sort_loop			// if (r3 != 0) goto sort_loop

 	b after_loop			// if (r3 == 0) goto after_loop (end calc)

find_min_loop:
	my_debugger
	ldr r8, [r7], #4		// load the word in [r7] to r8, update r7 = r7 + 4
	my_debugger
	cmp r5, r8				// r5 - r8 => refresh NZCV
	my_debugger
	bge	find_min_loop_min_found		// N set means r5 >= r8

	b find_min_loop_after	// if (r5 <= r8) not doing min_found action

find_min_loop_min_found:
	mov r5, r8				// r5 (min value) = r8
	sub r6, r7, #4			// r6 (min address) = r7 - 4
	my_debugger

	b find_min_loop_after	// do ++j action
find_min_loop_after:
	subs r4, r4, #1			// r4 = r4 - 1 and update NZCV
	my_debugger
	bne find_min_loop		// if (r4 != 0) do find_min_loop again

	movs pc, lr				// if (r4 == 0) go back to sort_loop

after_loop:
 	ldr r0, =csd_LED_ADDR
 	mov r1, #0x5
 	str r1, [r0]
 	my_debugger

forever:
	nop
 	b forever

// --------------------------------------------------------
// UART_print_r9: A simple function to transmit data in [r9]
// use r5 6 7 8 9
UART_print_r9:

	ldr	r5, =uart_Channel_sts_reg0

TX_loop:
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r6, [r5]		// read Channel Status Register
	and	r6, r6, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r6, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	TX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb r7, [r9], #1
	ldr  r8, =uart_TX_RX_FIFO0
	strb r7, [r8]	// fill the TxFIFO with 0x48
	cmp  r7, #0x00
	bne  TX_loop

	mov  pc, lr		// return to the caller
//
// end UART_print_r2
// --------------------------------------------------------


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

// add #48 to change to hex
int_to_str:
	.word 0, 0, 0, 1, 0, 2, 0, 3
	.word 0, 4, 0, 5, 0, 6, 0, 7
	.word 0, 8, 0, 9, 1, 0, 1, 1
	.word 1, 2, 1, 3, 1, 4, 1, 5

hex_to_ascii:
	.word 48, 49, 50, 51, 52, 53, 54, 55
	.word 56, 57, 65, 66, 67, 68, 69 ,70

mode_ascii:
	.ascii "USR"
	.byte 0x00
	.ascii "FLQ"
	.byte 0x00
	.ascii "IRQ"
	.byte 0x00
	.ascii "SVC"
	.byte 0x00
	.ascii "ABT"
	.byte 0x00
	.ascii "UND"
	.byte 0x00
	.ascii "SYS"
	.byte 0x00

cpsr_prefix:
	.ascii "cpsr = "
	.byte 0x00

reg_prefix:
	.ascii " = 0x"
	.byte 0x00

mode_prefix:
	.ascii "IF, ARM mode, current mode = "
	.byte 0x00

suffix:
	.ascii ", "
	.byte 0x00

enter_only:
	.byte 0x0D
	.byte 0x0A
	.byte 0x00

start_end_dash:
	.ascii "---------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00

print_temp:
	.byte 0x00
	.byte 0x00
