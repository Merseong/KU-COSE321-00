#include "uart_regs.h"
#include "uart_init.s"

#define csd_LED_ADDR 	0x41200000
#define csd_main_input		0x00101020
#define csd_main_output		0x00101000

.extern csd_main

.global main

main:

	UART_init     // UART Initialization

	mov r10, #1		// r10: current status of led
	ldr r11, =csd_LED_ADDR	// r11: address of led GPIO
	str r10, [r11]		// set inital led
	ldr r12, =0x00800000		// r12: timer, show left time to go next led
	ldr r0, =csd_main_output	// store time value to output of C code
	str r12, [r0]

	ldr r2, =string		// r2: address of data to print (use before UART_print_r2)
	bl UART_print_r2	// Print out string for duration table

	ldr r2, =select_string
	bl UART_print_r2	// Print out "Select: "

forever:
	subs r12, r12, #1			// sub 1 for each clock until r12 run out
	bleq rotate_led

	b recvloop

rotate_led:
	lsl r10, r10, #1			// shift led state to left

	ands r0, r10, #0x100	// check led state is over 8 leds
	movne r10, #1

	str r10, [r11]		// set led

	ldr r12, =csd_main_output
	ldr r12, [r12]		// load timer

	movs pc, lr

// --------------------------------------------------------
// UART_print_r2: A simple function to transmit data in [r2]
// use r0~r4
UART_print_r2:

	ldr	r0, =uart_Channel_sts_reg0

TX_loop:
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r1, [r0]		// read Channel Status Register
	and	r1, r1, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r1, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	TX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb r3, [r2], #1
	ldr  r4, =uart_TX_RX_FIFO0
	strb r3, [r4]	// fill the TxFIFO with 0x48
	cmp  r3, #0x00
	bne  TX_loop

	mov  pc, lr		// return to the caller
//
// end UART_print_r2
// --------------------------------------------------------

// --------------------------------------------------------
// recvloop : echo RX to TX, do return action(change time) when 'Enter' received
// use r0~r6
recvloop:
	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0

	// check empty: bit#1 is Rx FIFO empty or not (1: empty, 0: not empty)
	ldr r3, [r1]
	and r3, r3, #1<<1
	cmp r3, #0b10

	beq forever 	// return to the caller when empty

	// read data and transmit it back to sender
	ldr r4, [r0]
	str r4, [r0]

	// if you type "return" (it seems like
	// only 13 is stored in the buffer, which is "carriage return")
	// so, send "line feed" as well
	cmp r4, #13   // 0xD (13) is carriage return in ASCII
	moveq r5, #10 // 0xA (10) is linefeed in ASCII
	streq r5, [r0]
	beq return_action

	ldr r6, =csd_main_input
	str r4, [r6]		// store last input to csd_main_input address
	b forever

return_action:
	bl csd_main

	ldr r2, =select_string
	bl UART_print_r2	// Print out "Select: "
	
	ldr r6, =csd_main_input
	ldr r5, #0
	str r5, [r6]		// reset csd_main_input

	b forever
//
// end recvloop
// --------------------------------------------------------

	.data

string:
	.ascii "----------------- LED On Duration ----------------"
	.byte 0x0D
	.byte 0x0A
	.ascii "1. 100ms 2. 200ms 3. 300ms 4. 400 ms"
	.byte 0x0D
	.byte 0x0A
	.ascii "5. 500ms 6. 600ms 7. 700ms 8. 1 sec"
	.byte 0x0D
	.byte 0x0A
	.ascii "---------------------------------------------------"
	.byte 0x00

select_string:
	.byte 0x0D
	.byte 0x0A
	.ascii "Select: "
	.byte 0x00
