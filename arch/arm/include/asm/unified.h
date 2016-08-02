#ifndef __ASM_UNIFIED_H_
#define __ASM_UNIFIED_H_

#ifdef CONFIG_CPU_V7M
#define AR_CLASS(x...)
#else
#define AR_CLASS(x...) x
#endif

#ifdef CONFIG_THUMB2_KERNEL
/* The CPSR bit describing the instruction set (Thumb) */

#define ARM(x...)
#define THUMB(x...)

#else  /* !CONFIG_THUMB2_KERNEL */

#define ARM(x...)   x
#define THUMB(x...)

#endif
#endif
