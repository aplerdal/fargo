	include	"tios.h"
	include	"flib.h"
	include	"hexlib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

	move.l	#121,d6
	move.l	#62,d7
	move.l	#4,d4
	lea	Spritedata(pc),a5

main_loop:
	move.l	d6,d0
	move.l	#10,d1
	move.l	#10,d2
	move.l	#3,d4

	jsr	hexlib::put_hex
	move.l	d7,d0
	move.l	#10,d1
	move.l	#20,d2
	move.l	#3,d4
	jsr	hexlib::put_hex

	move.w	d6,d0
	move.w	d7,d1
	move.l	a5,a0

	bsr	PutSprite

test_key:
	tst.w	tios::kb_globals+$1C
	beq	test_arrow

	clr.w	tios::kb_globals+$1C
	move.w	tios::kb_globals+$1E,d0
	cmp.w	#$108,d0
	beq	exit

test_arrow:
	move.w	tios::kb_globals+$C,d0
	move.w	d0,d1
	and.w	#$FFF0,d1
	cmp.w	#$0050,d1
	bne	wait_vbl

testdown:
	btst	#1,d0
	bne	testup
	add.w	#1,d7
	cmp.w	#112,d7
	bcs	testup
	move.w	#112,d7

testup:
	btst	#3,d0
	bne	testleft
	sub.w	#1,d7
	bcc	testleft
	clr.w	d7

testleft:
	btst	#2,d0
	bne	testright
	sub.w	#1,d6
	bcc	testright
	clr.w	d6

testright:
	btst	#0,d0
	bne	wait_vbl
	add.w	#1,d6
	cmp.w	#224,d6
	bcs	wait_vbl
	move.w	#224,d6

wait_vbl:
	tst.w	vbl_phase
	bne	wait_vbl
	add.w	#5,vbl_phase	; Haven't spent the time yet to
				; figure out why this works.
				; It used to use #4 as its constant.
				; Andy Selle tried changing it to
				; #5 and that made it work much more
				; nicely.

	bsr	RemoveSprite
	bra	main_loop

exit:
	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1,$64
	bset.b	#2,$600001
	trap	#1

	rts

;*****************************************************

int_1:
	add.w	#1,vbl_phase
	and.w	#3,vbl_phase

	move.l	old_int_1,-(a7)
	rts

;*****************************************************

;16*16 sprite put
;data is of the format
;32 bytes sprite
;32 bytes mask
;a0=pointer to sprite
;d0=x coord, d1=y coord

PutSprite:
	move.w  d1,d2  multiply d1 by 30
	lsl.w   #4,d1
	sub.w   d2,d1
	lsl.w   #1,d1
	ext.l   d1
	move.l  d1,a1

	move.w  d0,d2
	and.w   #$F,d2
	and.w   #$fff0,d0
	asr.w   #3,d0
	ext.l   d0
	adda.l  d0,a1  a1=address to start putting sprite at
	adda.l  #LCD_MEM,a1

	lea backstore,a2

	move.l  a1,(a2)+
	tst.w   d2
	beq QuickPut    if x is on a word boundary we're OK
	cmp.w   #8,d2
	blt RightShift

LeftShift:
	move.w  #1,(a2)+

	sub.w   #16,d2
	neg.w   d2
	move.w  #15,d3
LeftLoop:

	move.l  (a1),d0
	move.l  d0,(a2)+      store background

	move.l  #0,d1
	move.w  32(a0),d1    get mask
	lsl.l   d2,d1          shift it
	not.l   d1
	and.l   d1,d0         and with back
	move.l  #0,d1
	move.w  (a0)+,d1      get data
	lsl.l   d2,d1          shift it
	or.l    d1,d0           or with back+mask
	move.l  d0,(a1)       put it on the screen
	lea     30(a1),a1        next line
	dbra    d3,LeftLoop      loop
	rts

RightShift:
	move.w #1,(a2)+
	move.w #15,d3
RightLoop:
	move.l (a1),d0
	move.l d0,(a2)+      store background

	move.l #0,d1
	move.w 32(a0),d1    get mask
	swap d1
	lsr.l   d2,d1          shift it
	not.l   d1
	and.l   d1,d0         and with back

	move.l #0,d1
	move.w (a0)+,d1      get data
	swap d1
	lsr.l d2,d1          shift it
	or.l d1,d0           or with back+mask
	move.l d0,(a1)       put it on the screen
	lea 30(a1),a1        next line
	dbra d3,RightLoop      loop
	rts

QuickPut:
	move.w #0,(a2)+
	move.w #15,d3
QuickLoop:
	move.w (a1),d0
	move.w d0,(a2)+      store background

	move.w 32(a0),d1    get mask
	not.w   d1
	and.w  d1,d0         and with back

	move.w (a0)+,d1      get data
	or.w d1,d0           or with back+mask
	move.w d0,(a1)       put it on the screen
	lea 30(a1),a1        next line
	dbra d3,QuickLoop      loop
	rts

RemoveSprite:
	lea backstore,a1
	move.l (a1)+,a0
	tst.w (a1)+
	beq QuickRemove

        move.w #15,d1
RemoveLoop:
	move.l (a1)+,(a0)
	lea 30(a0),a0
	dbra d1,RemoveLoop
	rts

QuickRemove:
	move.w #15,d1
QRemoveLoop:
	move.w (a1)+,(a0)
	lea 30(a0),a0
	dbra d1,QRemoveLoop
	rts

;*****************************************************

Spritedata:
	dc.w    %1111000000001111
	dc.w    %0111100000011110
	dc.w    %0011110000111100
	dc.w    %0001111001111000
	dc.w    %0000111111110000
	dc.w    %0000011111100000
	dc.w    %0000001001000000
	dc.w    %0000001001000000
	dc.w    %0000001001000000
	dc.w    %0000011111100000
	dc.w    %0000111111110000
	dc.w    %0001111001111000
	dc.w    %0011110000111100
	dc.w    %0111100000011110
	dc.w    %1111000000001111
	dc.w    %0000000000000000

	dc.w    %1111100000011111
	dc.w    %1111110000111111
	dc.w    %0111111001111110
	dc.w    %0011111111111100
	dc.w    %0001111111111000
	dc.w    %0000111111110000
	dc.w    %0000011111100000
	dc.w    %0000011111100000
	dc.w    %0000011111100000
	dc.w    %0000111111110000
	dc.w    %0001111111111000
	dc.w    %0011111111111100
	dc.w    %0111111001111110
	dc.w    %1111110000111111
	dc.w    %1111100000011111
	dc.w    %1111000000001111

;*****************************************************

_comment	dc.b	"Sprite test",0

;*****************************************************
	BSS

old_int_1	dc.l	0

vbl_phase	dc.w	0

backstore:
	dc.l 0
	dc.w 0
	dcb.l 16,0

;*****************************************************

	end
