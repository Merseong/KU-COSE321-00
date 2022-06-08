.globl  csd_MMUTable_lv2
.section .csd_mmu_tbl_lv2,"a"

csd_MMUTable_lv2:
// Figure 2
	/*
	 *     1st 4KB: 0x0020_0000 (VA) -> 0x0040_0000 (PA)
	 *     2nd 4KB: 0x0020_1000 (VA) -> 0x0040_1000 (PA)
	 *     3rd 4KB: 0x0020_2000 (VA) -> 0x0040_2000 (PA)
	 */
/*
.set PAGE, 0x400000
.word	PAGE + 0x2
.set PAGE, PAGE + 0x1000
.word	PAGE + 0x2
.set PAGE, PAGE + 0x1000
.word	PAGE + 0x2
*/

// Figure 3
	/*
	 *     1st 4KB: 0x0020_0000 (VA) -> 0x0040_0000 (PA)
	 *     2nd 4KB: 0x0020_1000 (VA) -> 0x0040_2000 (PA)
	 *     3rd 4KB: 0x0020_2000 (VA) -> 0x0040_0000 (PA)
	 */
///*
.set PAGE, 0x400000
.word	PAGE + 0x2
.set PAGE, PAGE + 0x2000
.word	PAGE + 0x2
.set PAGE, PAGE - 0x2000
.word	PAGE + 0x2
//*/
// end table lv2

.globl  csd_MMUTable
.section .csd_mmu_tbl,"a"

csd_MMUTable:
	/* A 32-bit is required for each PTE (Page Table Entry).
	 * Each PTE covers a 1MB section.
	 * There are 4096 PTEs, so 16KB is required for the page table.
	 *
	 *  First 6 PTEs with the following translations
	 *     1st 1MB: 0x0000_0000 (VA) -> 0x0000_0000 (PA)
	 *     2nd 1MB: 0x0010_0000 (VA) -> 0x0010_0000 (PA)
	 *     3rd 1MB: 0x0020_0000 (VA) -> csd_MMUTable_lv2 -> 0x0040_0000 (PA)
	 *     4th 1MB: 0x0030_0000 (VA) -> 0x0030_0000 (PA)
	 *     5th 1MB: 0x0040_0000 (VA) -> 0x0040_0000 (PA)
	 */

.set SECT, 0
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.set	SECT, SECT + 0x100000
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.word	csd_MMUTable_lv2 + 0x1e1
.set	SECT, SECT + 0x200000
.word	SECT + 0x15de6
.set	SECT, SECT + 0x100000
.word	SECT + 0x15de6

.rept (0x200 - 5)
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.endr

.end
