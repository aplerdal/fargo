	include	"tios.h"
	xdef	_library
	xdef	gray7lib@0000
	xdef	gray7lib@0001
	xdef	gray7lib@0002
	xdef	gray7lib@0003
	xdef	gray7lib@0004

;*****************************************************

gray7lib@0000:
on:
	movem.l	d1-d7/a0-a6,-(sp)

	move.l	#$F00*2+8,-(sp)
	jsr	tios::HeapAlloc
	addq	#4,sp
	move.w	d0,d6
	beq	graylib_fail
	move.w	d0,handle

	tios::DEREF d0,a6
	move.l	a6,d0
	add.l	#7,d0
	lsr.l	#3,d0
	move.w	d0,d7
	lsl.l	#3,d0
	move.l	d0,plane0
	move.w	d7,table+2*0

	add.l	#$F00,d0
	add.w	#$F00/8,d7
	move.l	d0,plane1
	move.w	d7,table+2*2
	move.w	d7,table+2*4

	move.l	#LCD_MEM,d0
	move.l	d0,plane2
	lsr.l	#3,d0
	move.w	d0,table+2*1
	move.w	d0,table+2*3
	move.w	d0,table+2*5

	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

	movem.l	(sp)+,d1-d7/a0-a6
	st.b	d0
	rts

;*****************************************************

gray7lib@0001:
off:
	movem.l	d1-d7/a0-a6,-(sp)

	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1,$64
	bset.b	#2,$600001
	trap	#1

	move.w	table+2(pc),($600010)

	move.w	handle(pc),-(sp)
	jsr	tios::HeapFree
	addq	#2,sp

graylib_fail:
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	#0,d0
	rts

;*****************************************************
; int_1: auto int 1 handler
;*****************************************************
int_1:
	move.w	#$2700,sr

	add.w	#1,vbl_phase
	and.w	#7,vbl_phase
	beq	int_1_skip

	movem.l	d0/a0,-(sp)
	move.w	phase(pc),d0
	lea	table(pc),a0
	move.w	0(a0,d0.w),($600010)
	add.w	#2,d0
	cmp.w	#2*6,d0
	bne	no_wrap
	clr.w	d0
no_wrap:
	move.w	d0,phase
	movem.l	(sp)+,d0/a0

int_1_skip:
	move.l	old_int_1,-(sp)
	rts

;*****************************************************
; alloc_plane: allocate a bitplane
;
; returns: D0.L = nonzero:success / zero:failure
;          D6.W = handle of bitplane
;          A6   = address of bitplane
;          D7.W = hardware address of bitplane
;*****************************************************
alloc_plane:

	move.l	#$F08,-(sp)
	jsr	tios::HeapAlloc
	addq	#4,sp
	move.w	d0,d6
	beq	alloc_fail

	tios::DEREF d0,a6
	move.l	a6,d0
	add.l	#7,d0
	lsr.l	#3,d0
	move.w	d0,d7

	lsl.l	#3,d0
	move.l	d0,a6

alloc_done:
	st.b	d0
	rts

alloc_fail:
	move.l	#0,d0
	rts

;*****************************************************

gray7lib@0002:
plane0		dc.l	0
gray7lib@0003:
plane1		dc.l	0
gray7lib@0004:
plane2		dc.l	LCD_MEM

old_int_1	dc.l	0

handle		dc.w	0

vbl_phase	dc.w	0
phase		dc.w	0

table		ds.w	6

vbl_stage	dc.w	0

_library	dc.b	"gray7lib",0

;*****************************************************

	end
