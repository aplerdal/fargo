	include	"tios.h"
	include	"flib.h"
	include	"hexlib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	jsr	flib::clr_scr

main_loop:
	move.l	addr(pc),a0
	move.l	#0,d1
	move.w	#14,d3
hex_loop_1:
	move.l	a0,d0
	move.l	#0,d2
	move.w	#5,d4
	jsr	hexlib::put_hex
	add.l	#1,d2
	move.w	#1,d4
	move.w	#7,d5
hex_loop_2:
	move.b	(a0),d0
	jsr	hexlib::put_hex
	add.l	#1,a0
	add.l	#1,d2
	dbf.w	d5,hex_loop_2
	add.l	#1,d1
	dbf.w	d3,hex_loop_1

	tst.w	tios::kb_globals+$1C
	beq	main_loop
	move.w	tios::kb_globals+$1E,d0
	clr.w	tios::kb_globals+$1C

	cmp.w	#$0152,d0
	beq	key_up
	cmp.w	#$0158,d0
	beq	key_down
	cmp.w	#$1152,d0
	beq	key_up2
	cmp.w	#$1158,d0
	beq	key_down2
	cmp.w	#$2152,d0
	beq	key_up3
	cmp.w	#$2158,d0
	beq	key_down3
	cmp.w	#$4152,d0
	beq	key_up4
	cmp.w	#$4158,d0
	beq	key_down4

	cmp.w	#$0108,d0
	beq	exit

	move.w	d0,d1
	and.w	#$0FFF,d1
	sub.w	#$010C,d1
	bcs	main_loop
	cmp.w	#8,d1
	bcc	main_loop
	lea	bookmark(pc),a0
	lsl.w	#2,d1
	and.w	#$F000,d0
	beq	goto_bookmark
make_bookmark:
	move.l	addr(pc),0(a0,d1.w)
	bra	main_loop
goto_bookmark:
	move.l	0(a0,d1.w),addr
	bra	main_loop

key_up:
	sub.l	#$8,addr
	bra	main_loop
key_down:
	add.l	#$8,addr
	bra	main_loop
key_up2:
	sub.l	#$100,addr
	bra	main_loop
key_down2:
	add.l	#$100,addr
	bra	main_loop
key_up3:
	sub.l	#$1000,addr
	bra	main_loop
key_down3:
	add.l	#$1000,addr
	bra	main_loop
key_up4:
	sub.l	#$10000,addr
	bra	main_loop
key_down4:
	add.l	#$10000,addr
	bra	main_loop

exit:
	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

addr:
	dc.l	0
bookmark:
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$005340
	dc.l	$0078B4
	dc.l	$020000
	dc.l	$400000

_comment	dc.b	"Hexadecimal memory viewer",0

;*****************************************************

	end
