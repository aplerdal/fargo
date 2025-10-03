	include	"tios.h"
	include	"flib.h"
	include	"hexlib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	jsr	flib::clr_scr
	jsr	tios::OSLinkReset

	lea	tios::ROM_base,a4	; start of ROM dump
	move.l	$C4(a4),d0		; ROM size - 4
	lea	4(a4,d0.l),a5		; end of ROM dump
	move.w	#8,-(a7)
	pea	buffer(pc)
dump_loop:
	move.l	#0,d1
	move.l	#0,d2
	move.l	a4,d0
	move.w	#7,d4
	jsr	hexlib::put_hex

test_key:
	tst.w	tios::kb_globals+$1C
	beq	no_key
	move.w	tios::kb_globals+$1E,d0
	clr.w	tios::kb_globals+$1C
	cmp.w	#$0108,d0
	beq	dump_exit
no_key:
	jsr	tios::OSLinkTxQueueInquire
	cmp.w	#8,d0
	bcs	test_key

	lea	(buffer+8)(pc),a0

	move.b	3(a4),d0
	asl.l	#8,d0
	move.b	4(a4),d0
	asl.l	#8,d0
	move.b	5(a4),d0
	asl.l	#8,d0
	move.b	6(a4),d0

	move.w	#3,d1
bit_loop_1:
	move.b	d0,d2
	or.b	#$80,d2
	move.b	d2,-(a0)
	asr.l	#7,d0
	dbf.w	d1,bit_loop_1

	move.b	(a4),d0
	asl.l	#8,d0
	move.b	1(a4),d0
	asl.l	#8,d0
	move.b	2(a4),d0
	asl.l	#8,d0
	move.b	3(a4),d0
	asr.l	#4,d0

	move.w	#3,d1
bit_loop_2:
	move.b	d0,d2
	or.b	#$80,d2
	move.b	d2,-(a0)
	asr.l	#7,d0
	dbf.w	d1,bit_loop_2

	jsr	tios::OSWriteLinkBlock

	add.l	#7,a4
	cmp.l	a5,a4
	bcs	dump_loop
dump_exit:
	add.l	#$6,a7
	rts

;*****************************************************

buffer		dcb.b	8,0

_comment	dc.b	"Dump ROM to link port (ASCII)",0

;*****************************************************

	end
