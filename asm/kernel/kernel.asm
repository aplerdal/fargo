	include	"kernel.h"
	include	"tios.h"
	include	"kernelEqu.h"
	include	"0_1_x.h"
	xdef	_hook1
	xdef	_hook2
	xdef	main_folder
	xdef	tios_pseudolib
	xdef	kernel_pseudolib
	xdef	kernel_table
	xdef	kernel_base
	xdef	module_setup
	xdef	module_reloc
	xdef	module_unload
	xdef	find_library

;----------------------------------------------------------------------------
; initialization code (triggered after backup)
;----------------------------------------------------------------------------
	code	_boot

	clr.l	(tios::EV_handler).w

copy_kernel:
	lea	_copy_source(pc),a2
	lea	_copy_target,a3
	move.w	#_copy_length,d0
copy_loop:
	move.l	-(a2),-(a3)
	dbf.w	d0,copy_loop

boot_init:
	move.l	tios::ROM_base+$70,a0;
;	move.w	-$01BC(a0),trap_0_idle
;	move.w	-$01AC(a0),trap_0_OSCheckBreak

	pea	main_folder_name(pc)
	move.w	(FOLDER_LIST_HANDLE).w,-(sp)
	jsr	tios::FindSymEntry
	add.l	#6,sp
	move.l	a0,d0			; test if the symbol was found
	beq	boot_fail		; if not, don't install the kernel
	move.w	10(a0),main_folder	; save symbol entry's handle

install_fargo:
	move.l	a3,(tios::globals+$18F6).w
	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	#int_1_hook,$64
	move.l	#int_6_hook,$78
	move.l	#trap_0_hook,$80
	bset.b	#2,$600001
	trap	#1
	rts

boot_fail:
	pea	boot_error(pc)
	jsr	tios::ST_helpMsg
	add.l	#4,sp
	rts

main_folder_name	dc.b	"main",0

boot_error		dc.b	"ERROR BOOTING FARGO",0

;----------------------------------------------------------------------------
; beginning of kernel
;----------------------------------------------------------------------------
	code

kernel_base:

_hook1:
	move.l	#EXEC_INCOMPATIBLE,d0
	rts

kernel@0000:
exec:
	move.w	4(sp),d0
	tios::DEREF d0,a2

	move.l	#EXEC_UNKNOWN_FORMAT,d0
	move.w	(a2),d6
	cmp.b	#$DC,2-1(a2,d6.w)
	bne	exec_rts
	cmp.l	#PROGRAM_SIG,2(a2)
	beq	hook1@0000
	cmp.w	#FARGO_SIG,2(a2)
	bne	exec_rts
	cmp.l	#EXE_TYPE,4(a2)
	bne	exec_rts

	move.l	8(a2),d1
	cmp.l	#APPL_SUBTYPE,d1
	beq	exec_start
	cmp.l	#PRGM_SUBTYPE,d1
	beq	exec_start
	cmp.l	#DLL_SUBTYPE,d1
	bne	exec_rts
	move.l	#EXEC_NOT_EXEC,d0
exec_rts:
	rts

exec_start:
	move.l	#EXEC_NOT_EXEC,d0
	move.w	20(a2),d1		; get pointer to export table
	tst.w	0(a2,d1.w)		; check if there's at least one export
	beq	exec_rts		; branch if there isn't

	move.w	4(sp),d0
	move.l	a2,-(sp)
	bsr	module_load
	move.l	(sp)+,a2
	tst.l	d0
	bne	exec_rts

	link	a6,#-$38-4
	pea	-$38(a6)
	jsr	tios::ER_catch
	move.l	#EXEC_TIOS_ERROR,d7
	tst.l	d0
	beq	exec_not_thrown
	cmp.l	#PRGM_SUBTYPE,8(a2)
	bne	exec_quit_thrown
	move.w	d0,-(sp)
	jsr	tios::ERD_dialog
	tios::ER_throw tios::ER_STOP
exec_not_thrown:
	move.l	a6,-(sp)
	move.w	20(a2),d1		; get pointer to export table
	move.w	2(a2,d1.w),d1		; get pointer to first export
	jsr	0(a2,d1.w)		; call the program
	move.l	(sp)+,a6
	move.l	#0,d7
exec_quit:
	jsr	tios::ER_success
	unlk	a6
exec_quit_thrown:

	move.w	4(sp),d0
	bsr	module_unload
	move.l	d7,d0
	rts

;----------------------------------------------------------------------------
; module_load()
;
; input: D0.W = handle
;
; Function: Loads Fargo program or library in memory block {handle}
;
; output: D0.L = zero on sucess, kernel error code on error
;         all other registers destroyed
;----------------------------------------------------------------------------
module_load:
	move.w	d0,d4
	bsr	module_setup
	tst.l	d7
	beq	module_load_finish
	bsr	load_cleanup
	move.l	d7,d0
	rts
module_load_finish:
	move.w	d4,d0
	bsr	module_reloc
	move.l	#0,d0
	rts

;----------------------------------------------------------------------------

module_reloc:
	tios::DEREF d0,a0

	move.w	12(a0),d0		; get linkinfo handle
	tios::DEREF d0,a1		; get the address of the linkinfo
	move.w	(a1),d0			; get usage count
	add.w	#1,(a1)+		; increment usage count
	tst.w	d0			; already been relocated?
	bne	reloc_rts		; if it has, then skip relocation

	btst	#FLAG0_PACK_TABLES,25(a0)
	beq	hook1@0001

	move.l	a1,-(sp)
	lea	module_reloc(pc),a5	; callback - recursive
	bsr	recurse_libs		; after this, "a1" points at bss memory
	lea	do_reloc(pc),a5		; callback - add addresses
	bsr	do_all_reloc
	move.l	(sp)+,a1
	bsr	do_imports

reloc_rts:
	rts

;----------------------------------------------------------------------------

_hook2:
	move.l	#EXEC_INCOMPATIBLE,d7
	rts

module_setup:
	tios::DEREF d0,a2

	tst.w	12(a2)			; already been relocated?
	bne	setup_done		; if yes, then we're done

	move.l	#EXEC_FARGO_TOO_OLD,d0
	move.w	24(a2),d1		; get flags
	and.w	#RESERVED_FLAGS,d1	; any unsupported flags?
	bne	setup_rts		; if yes, then fail

	btst	#FLAG0_PACK_TABLES,25(a2)
	beq	hook2@0000

	move.w	18(a2),d0		; pointer to import table
	lea	0(a2,d0.w),a3		; relative -> absolute

	move.l	#0,d1
	move.w	(a3),d1			; get number of libraries
	lsl.l	#1,d1			; we need one word for each library
	add.l	#2,d1			; and a place to store the usage count
	move.w	16(a2),d0		; get pointer to bss table
	add.w	0(a2,d0.w),d1		; add size of bss to be allocated
	move.l	d1,-(sp)		; amount of memory to allocate
	jsr	tios::HeapAlloc		; allocate memory
	add.l	#4,sp
	move.l	#EXEC_NO_MEM,d7
	move.w	d0,12(a2)		; store the handle
	beq	setup_rts		; if allocation was unsuccessful, then fail
	tios::DEREF d0,a4		; this is where we'll store linking data

	move.w	(a3),d0			; get number of libraries
	move.l	a4,a0
init_linkinfo:				; this loop will clear (number of libraries)+1 words,
	clr.w	(a0)+			;  and that's what we want, because the first word
	dbf.w	d0,init_linkinfo	;  is the usage count

	add.l	#2,a4			; first word is usage count

	tst.w	(a3)+			; test if there are any libraries
	beq	setup_done		; if not, then we're done
	move.w	(a3)+,d0		; get address of library name list
	lea	0(a2,d0.w),a5		; relative -> absolute
find_lib_loop:
	move.l	#EXEC_LIB_NOT_FOUND,d7
	bsr	find_library
	move.w	d2,(a4)+		; store library handle
	beq	setup_rts		; if it is zero, library was not found, so fail
	move.l	#EXEC_LIB_RANGE_ERR,d7
	bsr	check_imports
	tst.l	d0
	bne	setup_rts

	move.w	d2,d0			; get library handle
	bmi	next_lib_loop		; if it's a pseudohandle, skip this
	movem.l	a2-a5,-(sp)
	bsr	module_setup		; setup library (recursive)
	movem.l	(sp)+,a2-a5
	tst.w	d7			; relocation successful?
	bne	setup_rts		; if not, then fail

next_lib_loop:				; skip to next library name
	tst.b	(a5)+
	bne	next_lib_loop

	tst.b	(a3)			; check for final null terminator
	bne	find_lib_loop		; keep looping until we hit it

setup_done:
	move.l	#0,d7
setup_rts:
	rts

;----------------------------------------------------------------------------

load_cleanup:
	move.w	12(a2),d0		; get linkinfo handle
	beq	cleanup_done		; if it's zero, then there's nothing to cleanup

	tios::DEREF d0,a3		; get linkinfo address
	tst.w	(a3)+			; test if usage count is nonzero
	bne	cleanup_done		; if it is, then exit

	move.w	18(a2),d0		; pointer to import table
	move.w	0(a2,d0.w),d2		; get number of libraries
	beq	cleanup_finish		; if there are no libraries, skip to final step

	sub.w	#1,d2			; decrement in preparation for loop
cleanup_loop:
	move.w	(a3)+,d0		; get library handle
	beq	cleanup_finish		; if it's zero, we're done
	bmi	cleanup_next		; if it's a pseudolib, skip to next
	movem.l	a2-a3/d2,-(sp)
	tios::DEREF d0,a2
	bsr	load_cleanup		; cleanup (recursive)
	movem.l	(sp)+,a2-a3/d2
cleanup_next:
	dbf.w	d2,cleanup_loop

cleanup_finish:
	move.w	12(a2),-(sp)		; get linkinfo handle
	clr.w	12(a2)			; clear it
	jsr	tios::HeapFree		; delete it
	add.l	#2,sp

cleanup_done:
	rts

;----------------------------------------------------------------------------
; find_library(): Find a library or pseudolibrary
;
; Input:
;  a5 = pointer to library name
;
; Output:
;  d1.w = number of exports in library
;  d2.w = handle of library, or zero if library not found
;  a0-a1/a6/d0 destroyed
;----------------------------------------------------------------------------

is_tios_pseudolib:
	move.w	#TIOS_PSEUDOHANDLE,d2
	move.w	#TIOS_EXPORTS,d1
	rts

is_kernel_pseudolib:
	move.w	#KERNEL_PSEUDOHANDLE,d2
	move.w	#KERNEL_EXPORTS,d1
	rts

find_library:

	pea	(a5)			; push pointer to imported library name
	pea	tios_pseudolib(pc)	; push pointer to name of tios pseudolibrary
	jsr	tios::strcmp		; compare strings
	add.l	#8,sp
	tst.w	d0			; check the result of the comparison
	beq	is_tios_pseudolib	; branch if the strings were equal

	pea	(a5)			; push pointer to imported library name
	pea	kernel_pseudolib(pc)	; push pointer to name of kernel pseudolibrary
	jsr	tios::strcmp		; compare strings
	add.l	#8,sp
	tst.w	d0			; check the result of the comparison
	beq	is_kernel_pseudolib	; branch if the strings were equal

	pea	(a5)			; push pointer to library name
	move.w	main_folder(pc),-(sp)
	jsr	tios::FindSymEntry	; find library
	add.l	#6,sp
	move.l	a0,d0			; check if we found it
	beq	find_library_fail	; if not, then fail
	move.w	10(a0),d0		; get symbol entry's handle
	move.w	d0,d2			; store library handle
	tios::DEREF d0,a6		; get address of library

	move.w	(a6),d0
	cmp.b	#$DC,2-1(a6,d0.w)
	bne	find_library_fail
	cmp.w	#FARGO_SIG,2(a6)
	bne     find_library_fail
	cmp.l	#EXE_TYPE,4(a6)
	bne	find_library_fail
	cmp.l	#DLL_SUBTYPE,8(a6)
	bne	find_library_fail

	move.w	22(a6),d0		; get pointer to exported library name
	pea	0(a6,d0.w)		; push pointer to exported library name
	pea	(a5)			; push pointer to imported library name
	jsr	tios::strcmp		; compare strings
	add.l	#8,sp
	tst.w	d0			; check the result of the comparison
	bne	find_library_fail	; if the strings were different, then fail

	move.w	20(a6),d0		; pointer to export table
	move.w	0(a6,d0.w),d1		; get number of exports

find_library_rts:
	rts

find_library_fail:
	move.l	#0,d2
	rts

;----------------------------------------------------------------------------
; check_imports()
;
; Input:
;  a3 = pointer to import structure
;  d1 = number of exports in module being imported
;
; The function fails if there were any out-of-range imports.
;
; Output:
;  d0/d5 destroyed
;  success: d0.l = 0
;           a3 = pointer after import structure
;  failure: d0.l = nonzero
;           a3 = undefined
;----------------------------------------------------------------------------
check_imports:
	clr.w	d5			; init lib sym number
check_link_loop:
	clr.w	d0
	move.b	(a3)+,d0
	beq	check_link_done		; branch out if we've hit the null terminator
	bpl	check_link_delta
	lsl.w	#8,d0
	move.b	(a3)+,d0
	and.w	#$7FFF,d0
check_link_delta:
	add.w	d0,d5
	cmp.w	d1,d5			; check if it's within range
	bhi	check_link_fail		; if not, then fail
	clr.w	d0
skip_link_offsets:
	move.b	(a3)+,d0
	beq	check_link_loop
	lsl.b	#1,d0
	bcc	skip_link_offsets
	bmi	skip_link_word
skip_link_nibbles:
	lsr.b	#5,d0
	add.w	d0,a3
skip_link_word:
	add.l	#1,a3
	bra	skip_link_offsets
check_link_done:
	move.l	#0,d0
	rts
check_link_fail:
	st.b	d0
	rts

;----------------------------------------------------------------------------
; module_unload()
;
; input: D0.W = handle
;
; Function: Unloads Fargo program or library in memory block {handle}
;----------------------------------------------------------------------------
module_unload_compat:
	bsr	hook1@0002
	bra	unreloc_free

module_unload:
	tios::DEREF d0,a0

	move.w	12(a0),d0		; get linkinfo handle
	tios::DEREF d0,a1		; get the address of the linkinfo
	sub.w	#1,(a1)+		; decrement usage count
	bne	unreloc_rts		; if it's still nonzero, skip unrelocation

	btst	#FLAG0_PACK_TABLES,25(a0)
	beq	module_unload_compat

	move.l	a1,-(sp)
	lea	do_unreloc(pc),a5	; callback - subtract addresses
	bsr	do_imports		; after this, "a1" points at bss memory
	bsr	do_all_reloc
	move.l	(sp)+,a1
	lea	module_unload(pc),a5	; callback - recursive
	bsr	recurse_libs

unreloc_free:
	move.w	12(a0),-(sp)		; push linkinfo handle
	clr.w	12(a0)			; clear it
	jsr	tios::HeapFree		; delete it
	add.l	#2,sp

unreloc_rts:
	rts

;----------------------------------------------------------------------------
; do_reloc(): parse compressed relocation table
;
; Input:
;  a0 = base address of module being relocated
;  a2 = pointer to relocation table
;  d1 = number to add to each address
;----------------------------------------------------------------------------

reloc_word:
	lsl.w	#7,d0
	move.b	(a2)+,d0
	lsl.w	#2,d0
	lsr.w	#1,d0
	add.w	d0,a6			; add delta to address
	lea	$7F*2(a6),a6		; add rest of delta
	cmp.w	#$7FFE,d0
	beq	reloc_loop
	add.l	d1,(a6)+
	bra	reloc_loop
reloc_byte:
	lea	-2(a6,d0.w),a6		; add delta to address
	add.l	d1,(a6)+
	bra	reloc_loop

do_reloc_rts:
	move.l	(sp)+,a6
	rts

do_unreloc:
	neg.l	d1
do_reloc:
	move.l	a6,-(sp)
	lea	24(a0),a6
reloc_loop:
	clr.w	d0
	move.b	(a2)+,d0
	beq	do_reloc_rts
	lsl.b	#1,d0
	bcc	reloc_byte
	bmi	reloc_word
reloc_nibbles:
	move.w	d0,d2
	lsr.b	#5,d0
	and.w	#$1E,d2
	add.w	d2,a6			; add delta to address
	add.l	d1,(a6)+
reloc_nibble_loop:
	move.b	(a2)+,d2
	move.w	d2,d3
	lsr.b	#4,d2			; get high nibble
	add.w	d2,a6			; add delta to address \ times
	add.w	d2,a6			; add delta to address /  two
	add.l	d1,(a6)+
	and.w	#$F,d3			; get low nibble
	add.w	d3,a6			; add delta to address \ times
	add.w	d3,a6			; add delta to address /  two
	add.l	d1,(a6)+
	dbf.w	d0,reloc_nibble_loop
	bra	reloc_loop

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
	lea	0(a0,d0.w),a2		; relative -> absolute
	tst.w	(a2)+			; test if bss section has zero size
	beq	bss_skip		; if yes, then skip it
	move.l	a1,d1
	jsr	(a5)			; call relocation handler
bss_skip:

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
	lea	0(a0,d0.w),a2		; relative -> absolute
	tst.w	(a2)+			; check if there are any libraries
	beq	import_rts		; if not, then skip this
	add.l	#2,a2			; skip pointer to library name list
import_loop:
	tst.b	(a2)			; check for final null terminator
	beq	import_rts		; if we've hit it, we're done
	move.w	(a1)+,d0		; get library handle
	bmi	import_pseudo		; branch if it is a pseudohandle
import_real_lib:
	tios::DEREF d0,a3		; get address of library
	move.w	20(a3),d0		; get pointer to library's export table
	lea	2(a3,d0.w),a4		; relative -> absolute + skip first word
	lea	rel_import(pc),a6	; callback - relative import table
import_lib:
	clr.w	d5			; initialize symbol number
import_lib_loop:
	clr.w	d0
	move.b	(a2)+,d0
	beq	import_loop
	bpl	import_sym_delta
	lsl.w	#8,d0
	move.b	(a2)+,d0
import_sym_delta:
	add.w	d0,d5			; add delta to symbol number
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
	lea	kernel_base(pc),a3
	lea	kernel_table(pc),a4
	lea	rel_import(pc),a6
	bra	import_lib

;----------------------------------------------------------------------------
; rel_import()
;----------------------------------------------------------------------------
rel_import:
	move.l	#0,d0
	lsl.w	#1,d5			; convert to table index
	move.w	-2(a4,d5.w),d0		; get export table entry
	lsr.w	#1,d5			; convert back to symbol number
	move.l	a3,d1
	add.l	d0,d1
	jmp	(a5)			; call relocation handler

;----------------------------------------------------------------------------
; abs_import()
;----------------------------------------------------------------------------
abs_import:
	lsl.w	#2,d5			; convert to table index
	move.l	-4(a4,d5.w),d1		; get export table entry
	lsr.w	#2,d5			; convert back to symbol number
	jmp	(a5)			; call relocation handler

;*****************************************************
; Fargo interrupt hooks and loader
;*****************************************************

int_6_hook:
	move.w	#$2700,sr

	st.b	on_pressed

	move.l	tios::ROM_base+$78,-(sp)
	rts

;*****************************************************

int_1_hook:
	move.w	#$2700,sr

	tst.b	in_fargo
	bne	int_1_chain

	pea	int_1_check(pc)
	move.w	sr,-(sp)
int_1_chain:
	move.l	tios::ROM_base+$64,-(sp)
	rts

int_1_check:
	tst.b	waiting
	bne	check_trap

check_hotkey:
	cmp.w	#$0448,(tios::kb_globals+$C).w
	beq	shift_on
	tst.b	on_pressed
	beq	int_1_done
	clr.b	on_pressed
	btst.b	#2,(tios::kb_globals+$F).w
	beq	int_1_done

shift_on:
	clr.w	prgm_handle

	movem.l	d0-d2/a0-a1,-(sp)
	bclr.b	#2,(tios::kb_globals+$1).w	; turn off shift
	bclr.b	#2,(tios::kb_globals+$F).w	; turn off shift
	bclr.b	#2,(tios::ST_flags+3)	; turn off shift
	bset.b	#7,(tios::ST_flags+2)	; force status line to update
	jsr	tios::ST_eraseHelp
	movem.l	(sp)+,d0-d2/a0-a1

	clr.w	wait_timer
	st.b	waiting

check_trap:
	jsr	tios::OSClearBreak

	add.w	#1,wait_timer
	cmp.w	#100,wait_timer
	bcs	int_1_done

	clr.b	waiting

int_1_done:
	rte

;*****************************************************

trap_0_hook:
	move.w	#$2700,sr

;	cmp.w	trap_0_idle(pc),d0
	cmp.w	tios::idle+2,d0
	bne	not_idle

	tst.b	waiting
	beq	trap_0_chain
	clr.b	waiting
	bra	do_run_prgm

not_idle:

;	cmp.w	trap_0_OSCheckBreak(pc),d0
	cmp.w	tios::OSCheckBreak+2,d0
	bne	not_code

	move.w	(tios::globals+$1270).w,d0	; get handle of current TI-BASIC prgm
	beq	not_fargo
	move.w	d0,prgm_handle		; remember handle
	tios::DEREF d0,a0
	cmp.w	#FARGO_SIG,2(a0)
	bne     not_fargo

	lea	trap_0_count(pc),a0
	add.b	#1,(a0)
	cmp.b	#3,(a0)
	bne	not_fargo
	clr.b	(a0)

do_run_prgm:
	move.l	usp,a0
	move.l	2(sp),-(a0)
	move.l	a0,usp
	move.l	#run_prgm,2(sp)
	clr.w	d0
	rte

not_fargo:
;	move.w	trap_0_OSCheckBreak(pc),d0
	move.w	tios::OSCheckBreak+2,d0

not_code:

trap_0_chain:
	move.l	tios::ROM_base+$80,-(sp)
	rts

;*****************************************************

run_prgm:
	movem.l	d0-d7/a0-a6,-(sp)
	st.b	in_fargo

	move.w	prgm_handle(pc),d7	; save handle and test if nonzero
	bne	have_prgm		; branch if we've been triggered from TI-BASIC

	pea	fargo_var(pc)		; pointer to string "shell"
	move.w	main_folder(pc),-(sp)
	jsr	tios::FindSymEntry	; look for "shell" symbol
	add.l	#6,sp
	pea	shell_err(pc)
	move.l	a0,d0			; check if variable was found
	beq	fargo_fail		; if it wasn't, then fail
	add.l	#4,sp
	move.w	10(a0),d0		; get symbol's handle
	move.w	d0,d7			; save it

have_prgm:

	pea	no_mem(pc)
	move.l	#$F00,-(sp)
	jsr	tios::HeapAlloc		; allocate memory to save LCD image
	add.l	#4,sp
	move.w	d0,vidsave_handle
	beq	fargo_fail		; branch if allocation was unsuccessful
	add.l	#4,sp
	tios::DEREF d0,a0
	lea	(LCD_MEM).w,a1
	move.w	#$F00/4-1,d0
vid_save_loop:
	movem.l	(a1)+,(a0)+
	dbf.w	d0,vid_save_loop

	move.w	d7,-(sp)		; previously saved handle
	bsr	exec			; execute program
	add.l	#2,sp
	move.l	d0,d7			; save exit code

	move.w	vidsave_handle(pc),d0
	tios::DEREF d0,a0
	lea	(LCD_MEM).w,a1
	move.w	#$F00/4-1,d0
vid_restore_loop:
	movem.l	(a0)+,(a1)+
	dbf.w	d0,vid_restore_loop
	move.w	vidsave_handle(pc),-(sp)
	jsr	tios::HeapFree
	add.l	#2,sp

	move.l	d7,d0			; get saved exit code
	beq	fargo_exit		; branch if exec was successful
	lsl.w	#1,d0
	lea	exec_err_table(pc),a0
	move.w	-2(a0,d0.w),d0
err_base:
	pea	err_base(pc,d0.w)

fargo_fail:
	jsr	tios::ST_helpMsg
	addq	#4,sp

fargo_exit:
	jsr	tios::OSClearBreak
	clr.b	in_fargo
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

exec_err_table:
	dc.w	no_mem-err_base
	dc.w	fargo_old-err_base
	dc.w	lib_find_err-err_base
	dc.w	lib_range_err-err_base
	dc.w	not_exec-err_base
	dc.w	tios_error-err_base
	dc.w	incompat_err-err_base
	dc.w	incompat_rom-err_base
	dc.w	err_unknown-err_base

kernel_table:
	dc.w	kernel@0000-kernel_base		; exec

trap_0_idle		dc.w	0;
trap_0_OSCheckBreak	dc.w	0;

main_folder		dc.w	0	; handle of "main" folder

prgm_handle		dc.w	0
wait_timer		dc.w	0

vidsave_handle		dc.w	0

heap_load_count		dc.w	0	; number of modules loaded on the heap

in_fargo		dc.b	0
on_pressed		dc.b	0
waiting			dc.b	0
trap_0_count		dc.b	0

fargo_var		dc.b	"shell",0

tios_pseudolib		dc.b	"tios",0
kernel_pseudolib	dc.b	"kernel",0

shell_err	dc.b	"SHELL NOT FOUND",0
no_mem		dc.b	"OUT OF MEMORY",0
fargo_old	dc.b	"FARGO TOO OLD",0
lib_find_err	dc.b	"LIBRARY NOT FOUND OR INVALID",0
lib_range_err	dc.b	"WRONG LIBRARY VERSION",0
not_exec	dc.b	"FILE IS NOT EXECUTABLE",0
tios_error	dc.b	"PROGRAM QUIT DUE TO ER_throw",0
incompat_err	dc.b	"INCOMPATIBLE FARGO VERSION",0
incompat_rom	dc.b	"INCOMPATIBLE ROM VERSION",0
err_unknown	dc.b	"UNRECOGNIZED FILE FORMAT",0

;*****************************************************

	end
