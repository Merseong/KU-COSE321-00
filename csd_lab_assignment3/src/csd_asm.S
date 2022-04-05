#define csd_LED_ADDR 	0x41200000
#define csd_SW_ADDR 	0x41210000

.extern csd_main

.global main
main:
 	ldr r0, =csd_LED_ADDR
 	mov r1, #0xFF
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
