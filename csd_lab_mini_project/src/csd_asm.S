#include "uart_init.s"
#include "csd_zynq_peripherals.h"

// 1ms
#define	TIMER_INITIAL	0x2DC6C0

.align 8

csd_vector_table:
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b csd_IRQ_ISR
	b .

.extern task1_c
.extern task2_c
.extern task3_c

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

	cps #0x1F	             // sys mode

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

// Start per program setup
	ldr r0, =pc_stack_top

	ldr r1, =task1_c
	add r1, r1, #4
	ldr r2, =task2_c
	add r2, r2, #4
	ldr r3, =task3_c
	add r3, r3, #4

	stm r0, {r1-r3}
// End per program setup

	cps #0x10	             // user mode
// End inital settings

	b task1_c

// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------

csd_IRQ_ISR:

	stmfd sp!, {r0-r12, lr}

 	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r2, [r0]

 	// Clear Interrupt Status bit
  	ldr r0, =PRIVATE_STATUS
  	mov r1, #1
	str r1, [r0]

 	// End-of-Interrupt
  	ldr r0, =GICC_EOIR
	str r2, [r0]

	ldmfd sp!, {r0-r12, lr}

	ldr sp, =temp_stack_top
	stm sp, {r0-r12}^

	ldr r0, =rr_current
	ldr r0, [r0]			// r0: current running task number ( 0->t1, 1->t2, 2->t3 )

	mov r1, r0, LSL #2
	sub r1, r1, #4
	add pc, pc, r1			// goto prefer function for current task
	b task1_cs
	b task2_cs
	b task3_cs

task1_cs:
	ldm sp, {r0-r12}^
	ldr sp, =t1_stack_top
	stm	sp, {r0-r12}^		// store registers in task 1

	ldr r0, =rr_current
	mov r1, #1
	str r1, [r0]			// change current running task number

	ldr r0, =pc_stack_top
	ldm r0, {r1-r3}
	mov	r1, lr
	mov lr, r2				// change return register to next task
	stm r0, {r1-r3}

	ldr sp, =t2_stack_top
	ldm sp, {r0-r12}^		// load registers in task 2

	subs pc, lr, #4			// resume task 2

task2_cs:
	ldm sp, {r0-r12}^
	ldr sp, =t2_stack_top
	stm	sp, {r0-r12}^		// store registers in task 2

	ldr r0, =rr_current
	mov r1, #2
	str r1, [r0]			// change current running task number

	ldr r0, =pc_stack_top
	ldm r0, {r1-r3}
	mov	r2, lr
	mov lr, r3				// change return register to next task
	stm r0, {r1-r3}

	ldr sp, =t3_stack_top
	ldm sp, {r0-r12}^		// load registers in task 3

	subs pc, lr, #4			// resume task 3

task3_cs:
	ldm sp, {r0-r12}^
	ldr sp, =t3_stack_top
	stm	sp, {r0-r12}^		// store registers in task 3

	ldr r0, =rr_current
	mov r1, #0
	str r1, [r0]			// change current running task number

	ldr r0, =pc_stack_top
	ldm r0, {r1-r3}
	mov	r3, lr
	mov lr, r1				// change return register to next task
	stm r0, {r1-r3}

	ldr sp, =t1_stack_top
	ldm sp, {r0-r12}^		// load registers in task 1

	subs pc, lr, #4			// resume task 1

// ----------------------------
// Interrupt Service Routines (ISRs) - End
// ----------------------------

.data
.align 4

rr_current:
	.word 0

irq_stack:     .space 1024
irq_stack_top:
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:
t1_stack:		.space 1024
t1_stack_top:
t2_stack:		.space 1024
t2_stack_top:
t3_stack:		.space 1024
t3_stack_top:
temp_stack:		.space 1024
temp_stack_top:
pc_stack:		.space 512
pc_stack_top:
