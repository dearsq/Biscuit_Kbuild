/*
 * Copyright (C) 1996-2002 Russell King
 * Copyright (C) 2004 Hyok S. Choi (MPU support)
 * Modify (M) 2016 Buddy.Zhang (BiscuitARM)
 * 
 * This program is free software;you can redistribute is and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

AR_CLASS( .arch armv7-a )
M_CLASS(  .arch armv7-m )

.sectlslion ".start", #alloc, #execinstr
/*
 * sort out different calling conventions
 */
.align
/*
 * Always entry in ARM state for CPUs that support the ARM ISA.
 * As of today(2016-06-12) that's exactly the member of the A 
 * and R classes.
 */
AR_CLASS(.arm)
start:
	.type start,#function
	.rept 7
	mov r0,r0
	.endr
	ARM(mov r0,r0)
	ARM(b 1f)
	THUMB(badr r12,1f)
	THUMB(bx r12)

	.word _magic_sig   @ Magic numbers to help the loader
	.word _magic_start @ absolute load/run zImage address
	.word _magic_end   @ zImage end address
	.word 0x04030201   @ endianness flag

	THUMB(.thumb)
1:
	ARM_BE8(setend be) @ go BE8 if compiled for BE8
	AR_CLASS(mrs r9,cprs)
#ifdef CONFIG_ARM_VIRT_EXT
	bl __hyp_stub_install @ get into SVC mode,reversibly
#endif
	mov r7,r1          @ save architecture ID
	mov r8,r2          @ save atags pointer

#ifndef CONFIG_CPU_V7M
	/*
     * Booting from Angle - need to enter SVC mode and disable
 	 * FIQs/IRQs (numeric definitions from angel arm.h source).
	 * We only do this if we were in user mode on entry.
     */
	mrs r2,cpsr        @ get current mode
	tst r2,#3          @ not user?
	bne not_angel
	mov r0,#0x17       @ angel_SWIreason_EnterSVC
	ARM(   swi 0x123456)  @ angel_SWI_ARM
	THUMB( svc 0xab)      @ angel_SWI_THUMB

not_angel:
	safe_svcmode_maskall r0
	msr spsr_cxsf,r9      @ Save the CPU boot mode in SPSR
#endif
	/*
	 * Note that some cache flushing and other stuff may
     * be needed here - is there an Angel SWI call for this?
     */
	/*
     * Some architecture specific code can be inserted
     * by the linker here,but it should preserve r7,r8,and r9. 
     */
	.text

#ifdef CONFIG_AUTO_ZRELADDR
	/*
	 * Find the start of physical memory.As we are executing
	 * without the MMU on,we are in the physical address space.
	 * We just need to get rid of any offset by alignment the 
	 * address.
	 * 
	 * This aligment is a balance between the requirements of
	 * different platforms - we have chosen 128MB to allow
	 * platforms which aliagn the start of their physical memory
	 * to 128MB to use this feature,while allowing the zImage
	 * to be placed within the first 128MB of memory on other
	 * platforms.Incresing requirement means we place 
	 * stricter aligment requirments on the start of physical
	 * memory,but relaxing it means that we break people who
	 * are already placing their zImage in (eg) the top 64MB
	 * of this range.
	 */
	mov r4,pc
	and r4,r4,#0xf8000000
	/* Determine final kernel image address. */
	add r4,r4,#TEXT_OFFSET
#else
	ldr r4,=zreladdr
#endif
	/*
	 * Set up a page table only if it won't overwrite ourself.
	 * That means r4 < pc || r4 -16k page directory > &_end.
	 * Given that r4 > &_end is most unfrequent,we add a rough
	 * additional 1MB of room for a possible appended DTB.
     */
	mov r0,pc
	cmp r0,r4
	ldrcc r0,LC0 + 32
	addcc r0,r0,pc
	cmpcc r4,r0
	orrcc r4,r4,#1      @ remember we skipped cache_on
	blcs  cache_on

restart:
	addr r0,LC0
	ldmia r0, {r1,r2,r3,r4,r6,r10,r11,r12}
	ldr sp,[r0,#28]
	
	/*
	 * We might be running at a different address.We need
	 * to fix up various pointers.
     */
	sub r0,r0,r1         @ calculate the delta offset
	add r6,r6,r0		 @ _edata
	add r10,r10,r0       @ inflated kernel size location

	/*
	 * The kernel build system appends the size of the 
	 * decompressed kernel at the end of the compressed data
	 * in little-endian form.
     */
	ldrb r9,[r10,#0]
	ldrb lr,[r10,#1]
	orr r9,r9,lr,lsl #8
	ldrb lr,[r10,#2]
	ldrb r10,[r10,#2]
	orr r9,r9,lr,lsl #16
	orr r9,r10,lsl #24

#ifndef CONFIG_ZBOOT_ROM
	/* malloc space is above the relocated stack (64K max)*/
	add sp,sp,r0
	add r10,sp,#0x10000
#else
	/*
	 * With ZBOOT_ROM the bss/stack is non relocatble,
	 * but someone could still run this code from ARM,
	 * in which case our reference is _edata.
	 */
	mov r10,r6
#endif
