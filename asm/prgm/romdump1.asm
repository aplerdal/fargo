	include	"tios.h"
	include	"flib.h"
	include	"hexlib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	jsr	flib::clr_scr
	jsr	tios::OSLinkReset

	move.w	#$80,-(a7)
	lea	tios::ROM_base,a6
	pea	(a6)			; start of ROM dump
	move.l	$C4(a6),d0		; ROM size - 4
	lea	4(a6,d0.l),a6		; end of ROM dump
dump_loop:
	move.l	#0,d1
	move.l	#0,d2
	move.l	(a7),d0
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
	cmp.w	#$80,d0
	bcs	test_key

	jsr	tios::OSWriteLinkBlock

	add.l	#$80,(a7)
	cmp.l	(a7),a6
	bhi	dump_loop
dump_exit:
	add.l	#$6,a7
	rts

;*****************************************************

_comment	dc.b	"Dump ROM to link port (raw)",0

;*****************************************************

	end
