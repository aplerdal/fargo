	include	"kernelEqu.h"
	include	"kernel.h"
	include	"tios.h"
	xdef	hook2@0000
	xdef	hook1@0001
	xdef	hook1@0002

;----------------------------------------------------------------------------

hook2@0000:
module_setup_compat:

	move.w	18(a2),d0		; pointer to import table
	lea	0(a2,d0.w),a3		; relative -> absolute

	move.l	#0,d1
	move.w	(a3),d1			; number of libraries
	lsl.l	#1,d1			; we need one word for each library
	add.l	#2,d1			; and a place to store the usage count
	move.w	16(a2),d0		; get pointer to bss table
	add.l	0(a2,d0.w),d1		; add size of bss to be allocated
	move.l	d1,-(sp)		; amount of memory to allocate
	jsr	tios::HeapAlloc		; allocate memory
	add.l	#4,sp
	move.w	#EXEC_NO_MEM,d7
	move.w	d0,12(a2)		; store the handle
	beq	setup_rts		; if allocation was unsuccessful, then fail
	tios::DEREF d0,a4		; this is where we'll store linking data

	move.w	(a3)+,d0		; get number of libraries
	move.l	a4,a0
init_linkinfo:				; this loop will clear (number of libraries)+1 words,
	clr.w	(a0)+			;  and that's what we want, because the first word
	dbf.w	d0,init_linkinfo	;  is the usage count

	add.l	#2,a4			; first word is usage count

find_lib_loop:
	move.w	(a3)+,d0		; pointer to library name
	beq	setup_done		; if it's zero, then we're done
	lea	0(a2,d0.w),a5		; relative -> absolute

	move.w	#EXEC_LIB_NOT_FOUND,d7
	bsr	find_library
	move.w	d2,(a4)+		; store library handle
	beq	setup_rts		; if it is zero, library was not found, so fail
	move.w	#EXEC_LIB_RANGE_ERR,d7
check_link_loop:
	clr.w	d0
	move.w	(a3)+,d0		; get library symbol index
	beq	check_link_done		; branch out if we've hit the null terminator
	cmp.w	d1,d0			; check if it's within range
	bhi	setup_rts		; if not, then fail
skip_link_offsets:
	tst.w	(a3)+			; have we reached the null terminator yet?
	bne	skip_link_offsets	; if not, then keep looping
	bra	check_link_loop
check_link_done:

	move.w	d2,d0			; get library handle
	bmi	find_lib_loop		; if it's a pseudohandle, skip this
	movem.l	a2-a4,-(sp)
	bsr	module_setup		; setup library (recursive)
	movem.l	(sp)+,a2-a4
	tst.w	d7			; relocation successful?
	bne	setup_rts		; if not, then fail

	bra	find_lib_loop

setup_done:
	move.l	#0,d7
setup_rts:
	rts

;----------------------------------------------------------------------------

hook1@0001:
module_reloc_compat:

	move.l	a1,-(sp)
	lea	module_reloc,a5		; callback - recursive
	bsr	recurse_libs		; after this, "a1" points at bss memory
	lea	do_reloc,a5		; callback - add addresses
	bsr	do_all_reloc
	move.l	(sp)+,a1
	bsr	do_imports

	rts

;----------------------------------------------------------------------------

hook1@0002:
module_unload_compat:

	move.l	a1,-(sp)
	lea	do_unreloc,a5		; callback - subtract addresses
	bsr	do_imports		; after this, "a1" points at bss memory
	bsr	do_all_reloc
	move.l	(sp)+,a1
	lea	module_unload,a5	; callback - recursive
	bsr	recurse_libs

	rts

;----------------------------------------------------------------------------
; do_reloc(): parse compressed relocation table
;
; Input:
;  a0 = base address of module being relocated
;  a2 = pointer to relocation table
;  d1 = number to add to each address
;----------------------------------------------------------------------------

do_unreloc:
	neg.l	d1
do_reloc:
	move.w	(a2)+,d0
	beq	do_reloc_rts
	add.l	d1,0(a0,d0.w)
	bra	do_reloc
do_reloc_rts:
	rts

;----------------------------------------------------------------------------
; do_all_reloc()
;
; Input:
;  a0 = base address of module to relocate
;  a1 = base address of bss memory
;  a5 = callback function, do_reloc() or do_unreloc()
;----------------------------------------------------------------------------
do_all_reloc:
	move.w	14(a0),d0		; get pointer to relocation table
	lea	0(a0,d0.w),a2		; relative -> absolute
	move.l	a0,d1
	jsr	(a5)			; call relocation handler

	move.w	16(a0),d0		; get pointer to bss table
	lea	4(a0,d0.w),a2		; relative -> absolute + skip first longword
	move.l	a1,d1
	jsr	(a5)			; call relocation handler

	rts

;----------------------------------------------------------------------------
; recurse_libs()
;
; Input:
;  a0 = base address of module
;  a1 = pointer to library handle list
;  a5 = callback handler to call for each library
;----------------------------------------------------------------------------
recurse_libs:
	move.w	18(a0),d0		; get pointer to import table
	move.w	0(a0,d0.w),d1		; get number of libraries
	beq	recurse_rts		; skip this if there are no libraries
lib_reloc_loop:
	move.w	(a1)+,d0		; get library handle
	bmi	lib_reloc_next		; if it is a pseudohandle, skip it
	movem.l	d1/a0-a1/a5,-(sp)
	jsr	(a5)
	movem.l	(sp)+,d1/a0-a1/a5
lib_reloc_next:
	sub.w	#1,d1			; decrement library count
	bne	lib_reloc_loop		; loop if there are still libraries left
recurse_rts:
	rts

;----------------------------------------------------------------------------
; do_imports()
;
; Input:
;  a0 = base address of module
;  a1 = pointer to library handle list
;----------------------------------------------------------------------------

import_rts:
	rts

do_imports:
	move.w	18(a0),d0		; get pointer to import table
	lea	2(a0,d0.w),a2		; relative -> absolute + skip first word
import_loop:
	tst.w	(a2)+			; check if library name pointer is null
	beq	import_rts		; branch out if we've hit the null terminator
	move.w	(a1)+,d0		; get library handle
	bmi	import_pseudo		; branch if it is a pseudohandle
import_real_lib:
	tios::DEREF d0,a3		; get address of library
	move.w	20(a3),d0		; get pointer to library's export table
	lea	2(a3,d0.w),a4		; relative -> absolute + skip first word
	lea	rel_import(pc),a6	; callback - relative import table
import_lib:
import_lib_loop:
	move.w	(a2)+,d5		; get symbol number
	beq	import_loop		; branch out if we've hit the null terminator
	jsr	(a6)			; call import handler
	bra	import_lib_loop
import_pseudo:
	cmp.w	#KERNEL_PSEUDOHANDLE,d0
	beq	import_kernel
import_tios:
	lea	_tios_table,a4
	lea	abs_import(pc),a6
	bra	import_lib
import_kernel:
	lea	kernel_base,a3
	lea	kernel_table,a4
	lea	rel_import(pc),a6
	bra	import_lib

;----------------------------------------------------------------------------
; rel_import()
;----------------------------------------------------------------------------
rel_import:
	move.l	#0,d0
	lsl.w	#1,d5			; convert to table index
	move.w	-2(a4,d5.w),d0		; get export table entry
	move.l	a3,d1
	add.l	d0,d1
	jmp	(a5)			; call relocation handler

;----------------------------------------------------------------------------
; abs_import()
;----------------------------------------------------------------------------
abs_import:
	lsl.w	#2,d5			; convert to table index
	move.l	-4(a4,d5.w),d1		; get export table entry
	jmp	(a5)			; call relocation handler

;----------------------------------------------------------------------------

	end
