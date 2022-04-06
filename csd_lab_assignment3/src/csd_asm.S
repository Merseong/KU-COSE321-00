#define csd_LED_ADDR 	0x41200000
#define csd_SW_ADDR 	0x41210000
#define waitTimer		0x00101000

.extern csd_main

.global main
main:
	// init registers
	ldr r7, =csd_LED_ADDR	// r7: address of led gpio
	ldr r1, =waitTimer		// r1: address of wait time (shared with C function)
	mov r5, #1				// r5: current position of led
	str r5, [r7]			// set inital state of led

forever:
	bl csd_main				// use C function to get led duration

	ldr r6, [r1]			// r6: wait timer
	bl wait					// goto wait

	bl rotate_led			// goto rotate_led

	str r5, [r7]			// apply led state to GPIO led

	b forever				// go back to forever

wait:
	subs r6, r6, #1			// sub 1 for each clock until r6 run out
	bne wait

	movs pc, lr				// end wait

rotate_led:
	lsl r5, r5, #1			// shift led state to left

	ands r10, r5, #0x100	// check led state is over 8 leds
	bne reset_led			// if then, reset led to 1

	movs pc, lr

reset_led:
	mov r5, #1				// reset led state to 0000_0001

	movs pc, lr

.data
.align 4
