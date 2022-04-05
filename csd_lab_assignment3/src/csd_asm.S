#define csd_LED_ADDR 	0x41200000
#define csd_SW_ADDR 	0x41210000
#define waitTimer		0x00101000

.extern csd_main

.global main
main:
	// init registers
	ldr r7, =csd_LED_ADDR	// r7: address of led gpio
	ldr r1, =waitTimer		// r1: address of wait time
	mov r5, #1				// r5: current position of led
	str r5, [r7]

forever:
	bl csd_main

	ldr r6, [r1]			// r6: wait timer
	bl wait

	bl rotate_led

	str r5, [r7]

	b forever

wait:
	subs r6, r6, #1
	bne wait

	movs pc, lr

rotate_led:
	lsl r5, r5, #1

	ands r10, r5, #0x100
	bne reset_led

	movs pc, lr

reset_led:
	mov r5, #1

	movs pc, lr

.data
.align 4
