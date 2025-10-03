	include	"tios.h"
	xdef	_library
	xdef	gray4lib@0000
	xdef	gray4lib@0001
	xdef	gray4lib@0002
	xdef	gray4lib@0003

;*****************************************************

gray4lib@0001:
off:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1(pc),$64
	bset.b	#2,$600001
	trap	#1

	move.w	table+2(pc),$600010

	move.w	handle(pc),-(sp)
	jsr	tios::HeapFree
	add.l	#2,sp

graylib_fail:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#0,d0
	rts

;*****************************************************

gray4lib@0000:
on:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	#$F00*1+8,-(sp)
	jsr	tios::HeapAlloc
	add.l	#4,sp
	tst.w	d0
	beq	graylib_fail
	move.w	d0,handle

	tios::DEREF d0,a6
	move.l	a6,d0
	add.l	#7,d0
	lsr.l	#3,d0
	move.w	d0,table+2*0
	lsl.l	#3,d0
	move.l	d0,plane0

	move.l	#LCD_MEM,d0
	move.l	d0,plane1
	lsr.l	#3,d0
	move.w	d0,table+2*1
	move.w	d0,table+2*2

	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

	movem.l	(sp)+,d0-d7/a0-a6
	st.b	d0
	rts

;*****************************************************
; int_1: auto int 1 handler
;*****************************************************
int_1:
	move.w	#$2700,sr

	add.w	#1,vbl_phase
	and.w	#3,vbl_phase
	bne	int_1_skip

	movem.l	d0/a0,-(sp)
	move.w	phase(pc),d0
	lea	table(pc),a0
	move.w	0(a0,d0.w),($600010)
	add.w	#2,d0
	cmp.w	#2*3,d0
	bne	no_wrap
	clr.w	d0
no_wrap:
	move.w	d0,phase
	movem.l	(sp)+,d0/a0

int_1_skip:
	move.l	old_int_1,-(sp)
	rts

;*****************************************************

gray4lib@0002:
plane0		dc.l	0
gray4lib@0003:
plane1		dc.l	LCD_MEM

old_int_1	dc.l	0

handle		dc.w	0

vbl_phase	dc.w	0
phase		dc.w	0

table		ds.w	3

vbl_stage	dc.w	0

_library	dc.b	"gray4lib",0

;*****************************************************

	end
