.extern csd_main

.global main
main:
	blx csd_main

endloop:
	nop
	b endloop

.data
.align 4
