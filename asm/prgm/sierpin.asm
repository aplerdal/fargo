	include	"tios.h"
	include	"flib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	jsr	flib::clr_scr

	lea	point_table(pc),a0
	move.l	(a0),d4

main_loop:
	tst.w	tios::kb_globals+$1C
	beq	no_key
	clr.w	tios::kb_globals+$1C
	move.w	tios::kb_globals+$1E,d0
	cmp.w	#$108,d0
	beq	exit

no_key:
	move.l	d4,-(a7)
	jsr	flib::pixel_on
	add.l	#4,a7

	move.w	#3,d0
	jsr	flib::random
	lsl.w	#2,d0
	add.l	0(a0,d0.w),d4
	lsr.l	#1,d4
	and.l	#$0FFF0FFF,d4

	bra	main_loop

exit:
	rts

;*****************************************************

point_table:
	dc.w	120,000
	dc.w	000,120
	dc.w	239,120

_comment	dc.b	"Sierpinski (Chaos Game)",0

;*****************************************************

	end
