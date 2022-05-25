#define csd_LED_ADDR 	0x41200000
#define csd_SW_ADDR 	0x41210000

#include "csd_zynq_peripherals.h"

.extern csd_main

.global main
main:
	cps #0x13	// use supervised mode

	mov r10, #0	// r10: current cache status (off/on)
	ldr r0, =csd_SW_ADDR
	ldr r0, [r0]
	and r10, r0, #1 << 7	// check if 0b10000000 status (use bit masking)

	cmp r10, #0
	bleq disable_cache
	cmp r10, #0
	blne enable_cache

forever:
	ldr r0, =csd_SW_ADDR
	ldr r0, [r0]
	ands r0, r0, #1 << 7
	cmp r10, r0
	beq forever_main
	mov r10, r0

	cmp r10, #0
	bleq disable_cache
	cmp r10, #0
	blne enable_cache

forever_main:
	bl  csd_main

	b forever

disable_cache:
	// Read Cache Type Register (CTR)
	mrc p15, 0, r1, c0, c0, 1

	// Read Cache Level ID Register (CLIDR)
	mrc p15, 1, r2, c0, c0, 1

	@------------------------
	@ Disable Caches (L2)
	@------------------------
	ldr r0, =L2_reg1_ctrl
	mov r1, #0x0
	str r1, [r0]
	@------------------------
	@ Disable Caches (IL1, DL1)
	@------------------------
	mrc		p15, 0, r0, c1, c0, 0	@ read control register (CP15 register1)
	bic		r0, r0, #4096		    @ disable I bit (Instruction Cache)
	bic		r0, r0, #4		        @ disable C bit (Data and Unified Caches)
	mcr		p15, 0, r0, c1, c0, 0	@ write control register (CP15 register2)

	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	movs pc, lr

enable_cache:
	// Read Cache Type Register (CTR)
	mrc p15, 0, r1, c0, c0, 1

	// Read Cache Level ID Register (CLIDR)
	mrc p15, 1, r2, c0, c0, 1

	@------------------------
	@ Enable Caches (L2)
	@------------------------
	ldr r0, =L2_reg1_ctrl
    mov r1, #0x1
    str r1, [r0]

	@------------------------
	@ Enable Caches (IL1, DL1)
	@------------------------
	mrc		p15, 0, r0, c1, c0, 0	@ read control register (CP15 register1)
	orr		r0, r0, #(1<<12)	    @ Enable I bit (Instruction Cache)
	orr		r0, r0, #(1<<2)         @ Enable C bit (Data and Unified Caches)
	mcr		p15, 0, r0, c1, c0, 0	@ write control register (CP15 register2)

	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	movs pc, lr
