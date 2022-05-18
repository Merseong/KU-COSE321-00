#include "uart_init.s"
#include "csd_zynq_peripherals.h"

#define	TIMER_INITIAL	0x1C9C380

.align 5

csd_vector_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b csd_IRQ_ISR
	b .

.extern time_convert

.global main
main:

// start inital settings

	// Disable interrupt: CPSR'I = 1
	cpsID i

	cps #0x12	   	       // IRQ mode 
	ldr	r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps #0x13		          // supervisor mode
	ldr	r13,=svc_stack_top // Stack pointer setup for SVC mode

	cps #0x11		          // FIQ mode
	ldr	r13,=fiq_stack_top // Stack pointer setup for FIQ mode

	cps #0x1F	             // SYS mode 

	// Set VBAR (Vector Base Address Register) to my vector table
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	// Enable interrupt: CPSR'I = 0
	cpsIE i

// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
// ---------------------------

	// CPU Interface ID Register
	ldr r0, =GICC_IIDR
	ldr r3, [r0]

	// CPU Controller Type Register
	ldr r0, =GICD_TYPER
	ldr r3, [r0]

	// CPU Binary Pointer Register
	ldr r0, =GICC_BPR
	ldr r3, [r0]

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   // Enable #29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// According to specifications, 
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)

	// Interrupt Priority Register #7
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8    // Priority 16 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// CPU Interface Interrupt Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // Lowest
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

// ---------------------------
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------


// ---------------------------
// Private Timer setup - Begin
// ---------------------------

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =TIMER_INITIAL
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #10 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

// ----------------------------
// Private Timer setup - End
// ----------------------------

	UART_init     // UART Initialization

// End inital settings

// Start custom codes
	ldr r1, =string
	bl UART_print_r1

 	// Check out the counter value to make sure the counter is decrementing
	ldr r0, =PRIVATE_COUNTER
	ldr r1, [r0]
	ldr r2, [r0]
	ldr r3, [r0]
	ldr r4, [r0]
	ldr r5, [r0]
	ldr r6, [r0]
	ldr r7, [r0]
	ldr r8, [r0]

	ldr r0, =PRIVATE_COUNTER
	ldr r1, =PRIVATE_STATUS
	ldr r2, =GICD_ISPENDR0

forever:
	ldr r5, [r0]
	ldr r6, [r1]
	ldr r7, [r2]
	b forever


//
// UART_print_r1: print r0 data to UART
//

UART_print_r1:

	stmfd sp!, {r0-r12, lr}
	ldr	r0, =uart_Channel_sts_reg0

TX_loop:
	// ---------  Check to see if the Tx FIFO is empty ------------------------------
	ldr r2, [r0]		// read Channel Status Register
	and	r2, r2, #0x8	// read Transmit Buffer Empty bit(bit[3])
	cmp	r2, #0x8		// check if TxFIFO is empty and ready to receive new data
	bne	TX_loop			// if TxFIFO is NOT empty, keep checking until it is empty
	//------------------------------------------------------------------------------

	ldrb r3, [r1], #1
	ldr  r4, =uart_TX_RX_FIFO0
	strb r3, [r4]	// fill the TxFIFO with 0x48
	cmp  r3, #0x00
	bne  TX_loop

	ldmfd sp!, {r0-r12, lr}
	mov  pc, lr		// return to the caller



// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------

csd_IRQ_ISR:

	stmfd sp!, {r0-r12, lr}

 	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r2, [r0]

	// Add 1 sec to elapsed
	ldr r0, =elapsed
	ldr r3, [r0]
	add r3, r3, #1
	str r3, [r0]

	// convert elapsed time to string
	mov r1, r3		// r1 <- elapsed-value (r3)
	ldr r0, =string
	stmfd sp!, {r0-r12, lr}
	bl time_convert
	ldmfd sp!, {r0-r12, lr}

	// print to UART
	mov r1, r0		// r1 <- string-address (r0)
	bl UART_print_r1

 	// Clear Interrupt Status bit
  	ldr r0, =PRIVATE_STATUS
  	mov r1, #1
	str r1, [r0]

 	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r2, [r0]

	ldmfd sp!, {r0-r12, lr}
	subs pc, lr, #4

// ----------------------------
// Interrupt Service Routines (ISRs) - End
// ----------------------------

.data
.align 4

irq_stack:     .space 1024
irq_stack_top:
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:

string:
	.ascii "00:00:00"
	.byte 0x0D
	.byte 0x00

elapsed:
	.word 0
