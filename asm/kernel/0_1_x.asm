	include	"tios.h"
	include	"kernel.h"
	include	"0_1_x.h"
	xdef	hook1@0000

;*****************************************************

core_base:

hook1@0000:
exec_compat:
;	move.w	#EXEC_INCOMPAT_ROM,d0
;	lea	(tios::main_lcd).w,a0
;	cmp.l	#$4440,a0
;	bne	exec_rts
;	lea	(tios::kb_vars).w,a0
;	cmp.l	#$7594,a0
;	bne	exec_rts
;	lea	(tios::ST_flags).w,a0
;	cmp.l	#$761C,a0
;	bne	exec_rts

	move.w	4(sp),prog_handle

	move.w	#$0700,d0
	trap	#1
	move.w	d0,save_sr

	bclr.b	#2,$600001
	move.l	$B8,old_trap_14
	move.l	#exec_trap,$B8

	trap	#14

exec_rts:
	rts

;-----------------------------------------------------

exec_trap:
	move.w	#$2700,sr

	move.l	old_trap_14(pc),$B8
	bset.b	#2,$600001

	move.w	prog_handle(pc),d0
	bsr	load_link
	tst.l	d0
	bne	exec_trap_rte

	move.w	prog_handle(pc),d0
	bsr	load_reloc
	move.w	2+h_6(a0),d0		; get program entry pointer
	move.w	#$2000,sr
	jsr	2(a0,d0.w)
	move.w	#$2700,sr

	move.w	prog_handle(pc),d0
	bsr	unload
	clr.l	d0

exec_trap_rte:
	move.w	save_sr(pc),(sp)
	rte

;*****************************************************

	dc.w	0	; symbol ID#*2
find_var:
	movem.l	a0-a1/d1-d2,-(sp)

	pea	oldfargo_name(pc)
	move.w	(FOLDER_LIST_HANDLE).w,-(sp)
	jsr	tios::FindSymEntry
	add.l	#6,sp
	move.w	10(a0),d0
	beq	find_var_done

	move.l	4*4+4(sp),a0
	pea	(a0)
	move.w	d0,-(sp)
	jsr	tios::FindSymEntry
	add.l	#6,sp
	move.w	10(a0),d0

find_var_done:
	movem.l	(sp)+,a0-a1/d1-d2
	rts

;----------------------------------------------------------------------------

	dc.w	2	; symbol ID#*2
exec:
	move.w	sr,-(sp)
	move.w	#$2700,sr

	move.w	2+4(sp),d0
	bsr	load_link
	tst.l	d0
	bne	exec_fail

	move.w	2+4(sp),d0
	bsr	load_reloc
	move.w	2+h_6(a0),d0		; get program entry pointer
	move.w	#$2000,sr
	jsr	2(a0,d0.w)
	move.w	#$2700,sr

	move.w	2+4(sp),d0
	bsr	unload
	clr.l	d0

exec_fail:
	rte

;----------------------------------------------------------------------------
; load_link()
;
; input: D0.W = handle
;
; Function: Loads Fargo program or library in memory block {handle}
;           (Step 1)
;
; output: success: D0.L = zero
;         failure: D0.L = nonzero
;----------------------------------------------------------------------------
load_link:
	tios::DEREF d0,a6

	move.w	2+h_3(a6),d0		; get pointer to library handle table
	lea	2(a6,d0.w),a2
	move.w	2+h_2(a6),d0		; get pointer to library import table
	lea	2(a6,d0.w),a5
	move.w	(a5)+,d3		; get number of libraries
find_lib_loop:
	beq	reloc_done

	pea	romlib_name(pc)
	pea	(a5)
	jsr	tios::strcmp
	add.l	#8,sp
	tst.w	d0			; check result of comparison
	bne	link_not_romlib

	add.l	#7,a5			; length of "romlib" string
	move.w	#$FFFF,(a2)+		; romlib pseudohandle
	sub.w	#1,d3
	bra	find_lib_loop

link_not_romlib:

	pea	(a5)
	bsr	find_var
	add.l	#4,sp
	tst.l	d0
	beq	reloc_fail

	move.w	d0,(a2)			; store library handle

	tios::DEREF d0,a3
	cmp.l	#LIBRARY_SIG,2(a3)
	bne     reloc_fail
	move.w	(a3),d7
	cmp.b	#$DC,2-1(a3,d7.w)
	bne	reloc_fail

	move.w	2+h_5(a3),d7		; get pointer to library name
	lea	2(a3,d7.w),a3
	move.w	#8-1,d2
lib_cmp:
	cmp.b	(a5)+,(a3)+
	bne	reloc_fail
	tst.b	-1(a5)
	dbeq.w	d2,lib_cmp

	move.w	(a2)+,d0		; get library handle

	movem.l	d3/a2/a5/a6,-(sp)
	bsr     load_link		; relocate library (recursive)
	movem.l	(sp)+,d3/a2/a5/a6

	tst.l	d0			; relocation successful?
	bne	reloc_fail		; nope

	sub.w	#1,d3
	bra	find_lib_loop

reloc_fail:
	move.l	#EXEC_LIB_NOT_FOUND,d0
	rts
reloc_done:
	move.l	#0,d0
	rts

;----------------------------------------------------------------------------
; load_reloc()
;
; input: D0.W = handle
;
; Function: Loads Fargo program or library in memory block {handle}
;           (Step 2)
;
; Return: A0 = pointer to program
;----------------------------------------------------------------------------
load_reloc:
	tios::DEREF d0,a0

	move.w	2+h_4(a0),d0		; get relocation count
	add.w	#1,2+h_4(a0)		; increment relocation count
	tst.w	d0			; already been relocated?
	bne	reloc_done		; yes; skip it

	lea	load_reloc(pc),a5
	bsr	recurse_libs

	move.l	a0,d1
	add.l	#2,d1
	move.w	2+h_3(a0),d0		; get pointer to library handle table
	lea	2(a0,d0.w),a3
	move.w	2+h_1(a0),d0		; get pointer to relocation table
	lea	2(a0,d0.w),a1
reloc_loop:
	move.w	(a1)+,d0
	beq	reloc_done
	lea	2(a0,d0.w),a2
	move.b	(a2),d0
	bne	reloc_lib
reloc_self:
	add.l	d1,(a2)
	bra	reloc_loop
reloc_lib:
	cmp.b	#$FF,d0
	beq	reloc_core
	move.b	d0,d2
	and.w	#$FF,d0
	add.w	d0,d0
	move.w	-2(a3,d0.w),d6		; get handle of library
	bmi	reloc_romlib
reloc_real_lib:
	tios::DEREF d6,a4		; get pointer to library
	move.w	2(a2),d0		; get library routine ID#*2
	move.w	2+h_6(a4,d0.w),d0	; get library routine near-pointer
	lea	2(a4,d0.w),a4		; get library routine address
	move.l	a4,(a2)
	move.b	d2,(a2)
	bra	reloc_loop
reloc_romlib:
	move.w	2(a2),d0		; get library routine ID#*2
	lea	romlib_table(pc),a4
	add.w	d0,a4
	add.w	d0,a4
	move.l	(a4),(a2)
	lsr.w	#1,d0
	not.b	d0
	sub.b	#1,d0
	move.b	d0,(a2)
	bra	reloc_loop
reloc_core:
	lea	core_table(pc),a4
	add.w	2(a2),a4
	move.w	(a4),a4
	add.l	#core_base,a4
	move.l	a4,(a2)
	move.b	d0,(a2)
	bra	reloc_loop

	rts

;----------------------------------------------------------------------------
; unload()
;
; input: D0.W = handle
;
; Function: Unloads Fargo program or library in memory block {handle}
;
; Return: nothing
;----------------------------------------------------------------------------
unload:
	tios::DEREF d0,a0

	sub.w	#1,2+h_4(a0)		; decrement relocation count
	bne	unreloc_skip		; skip unrelocation if still in use

	move.w	2+h_3(a0),d0		; get pointer to library handle table
	lea	2(a0,d0.w),a3		; relative -> absolute
	move.w	2+h_2(a0),d0		; get pointer to library import table
	move.w	2(a0,d0.w),d1		; relative -> absolute, get number of libraries
	beq	unreloc_handles_done	; skip this if there are none
	move.l	#0,d3			; initialize library index
	sub.w	#1,d1			; prepare for dbf loop
unreloc_handles_loop:
	add.b	#1,d3			; increment current library index
	tst.w	(a3)+			; check if library handle is the romlib pseudohandle
	bpl	unreloc_handle_not_romlib
	move.l	#0,d0			; \   put romlib
	move.b	d3,d0			;  | index in high
	ror.l	#8,d0			; /   byte of d0
unreloc_handle_not_romlib:
	dbf.w	d1,unreloc_handles_loop
unreloc_handles_done:

	move.l	a0,d1
	add.l	#2,d1
	move.w	2+h_1(a0),d0		; get pointer to relocation table
	lea	2(a0,d0.w),a1		; relative -> absolute
unreloc_loop:
	move.w	(a1)+,d0
	beq	unreloc_done
	lea	2(a0,d0.w),a2
	move.b	(a2),d0			; get high byte
	bne	unreloc_lib		; if it is nonzero, this is a library symbol
unreloc_self:
	sub.l	d1,(a2)
	bra	unreloc_loop
unreloc_lib:
	cmp.b	#$FF-23,d0		; check if it's a normal library
	bcs	unreloc_not_romlib	; branch if it is
	cmp.b	#$FF,d0			; check if it's the core library
	bne	unreloc_romlib		; if it's not, then it has to be romlib
unreloc_not_romlib:
	move.l	(a2),a3
	move.w	-2(a3),2(a2)
	bra	unreloc_loop
unreloc_romlib:
	add.b	#1,d0
	not.b	d0
	and.w	#$FF,d0
	add.w	d0,d0
	move.l	d0,(a2)			; high byte has romlib's library index
	bra	unreloc_loop
unreloc_done:

	lea	unload(pc),a5
	bsr	recurse_libs

unreloc_skip:
	rts

;*****************************************************************************

recurse_libs:

	move.w	2+h_3(a0),d0		; get pointer to library handle table
	lea	2(a0,d0.w),a1
	move.w	2+h_2(a0),d0		; get pointer to library import table
	move.w	2(a0,d0.w),d1
lib_reloc_loop:
	beq	lib_reloc_done

	move.w	(a1)+,d0		; get library handle
	bmi	lib_reloc_next

	movem.l	d1/a0/a1/a5,-(sp)
	jsr	(a5)
	movem.l	(sp)+,d1/a0/a1/a5

lib_reloc_next:
	sub.w	#1,d1
	bra	lib_reloc_loop
lib_reloc_done:

	rts

;*****************************************************************************

prog_handle	dc.w	0

save_sr		dc.w	0

old_trap_14	dc.l	0

core_table:
	dc.w	find_var-core_base
	dc.w	exec-core_base

romlib_table:
	dc.l	tios::DrawCharXY
	dc.l	tios::DrawStrXY
	dc.l	tios::FontSetSys
	dc.l	tios::reset_link
	dc.l	tios::tx_free
	dc.l	tios::transmit
	dc.l	tios::receive
	dc.l	tios::sprintf
	dc.l	tios::ST_eraseHelp
	dc.l	tios::ST_busy
	dc.l	tios::HeapFree
	dc.l	tios::HeapFreeIndir
	dc.l	tios::HeapAlloc
	dc.l	tios::HeapRealloc
	dc.l	tios::WinOpen
	dc.l	tios::WinClose
	dc.l	tios::WinActivate
	dc.l	tios::WinStrXY
	dc.l	tios::flush_link
	dc.l	tios::DrawTo
	dc.l	tios::MoveTo
	dc.l	tios::PortSet
	dc.l	tios::PortRestore

romlib_name	dc.b	"romlib",0

oldfargo_name	dc.b	"oldfargo",0

;*****************************************************************************

	end
