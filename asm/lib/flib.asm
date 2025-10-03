	include	"flib.h"
	include	"tios.h"
	xdef	_library
	xdef	flib@0000
	xdef	flib@0001
	xdef	flib@0002
	xdef	flib@0003
	xdef	flib@0004
	xdef	flib@0005
	xdef	flib@0006
	xdef	flib@0007
	xdef	flib@0008
	xdef	flib@0009
	xdef	flib@000A
	xdef	flib@000B
	xdef	flib@000C

;*****************************************************	

pixel_do	macro
	movem.l	d0-d1/a0,-(sp)

	lea	LCD_MEM,a0

	move.w	4*4+2(sp),d0		; y-coordinate
	cmp.w	#128,d0
	bcc	\pixel_bad
	lsl.w	#1,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0
	lea	0(a0,d0.w),a0

	move.w	4*4+0(sp),d0		; x-coordinate
	cmp.w	#240,d0
	bcc	\pixel_bad
	move.w	d0,d1
	lsr.w	#3,d0

	not.w	d1
	and.w	#7,d1
	b\1.b	d1,0(a0,d0.w)

\pixel_bad:
	movem.l	(sp)+,d0-d1/a0
		endm

;*****************************************************

flib@0000:
find_pixel:
	move.w	d1,-(sp)

	lea	LCD_MEM,a0

	move.w	(4+2)+2(sp),d0		; y-coordinate
	cmp.w	#128,d0
	bcc	pixel_bad
	lsl.w	#1,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0
	lea	0(a0,d0.w),a0

	move.w	(4+2)+0(sp),d1		; x-coordinate
	cmp.w	#240,d1
	bcc	pixel_bad
	move.w	d1,d0
	lsr.w	#3,d1
	lea	0(a0,d1.w),a0
	not.w	d0
	and.w	#7,d0

pixel_good:
	move.w	(sp)+,d1
	rts

pixel_bad:
	sub.l	a0,a0
	bra	pixel_good

;*****************************************************

flib@0001:
pixel_on:
	pixel_do	set
	rts

;*****************************************************

flib@0002:
pixel_off:
	pixel_do	clr
	rts

;*****************************************************

flib@0003:
pixel_chg:
	pixel_do	chg
	rts

;*****************************************************
; prep_rect: used by frame_rect and erase_rect
;*****************************************************
flib@0004:
prep_rect:

	move.l	#0,d4
	move.w	$36(sp),d4
	move.w	d4,d5
	lsl.w	#5,d4
	lsl.w	#1,d5
	sub.w	d5,d4
	add.l	#LCD_MEM,d4
	move.l	d4,a0

	move.l	#0,d5
	move.w	$3A(sp),d5
	move.w	d5,d6
	lsl.w	#5,d5
	lsl.w	#1,d6
	sub.w	d6,d5
	add.l	#LCD_MEM,d5
	move.l	d5,a1

	move.w	$34(sp),d0
	move.w	d0,d6
	lsr.w	#3,d0
	and.w	#$7,d6

	move.w	$38(sp),d1
	move.w	d1,d7
	lsr.w	#3,d1
	and.w	#$7,d7

	rts

;*****************************************************

flib@0005:
frame_rect:
	movem.l	d0-d7/a0-a2,-(sp)

	bsr	prep_rect
	move.b	#$FF,d2
	move.b	#$FF,d3
	move.b	#$80,d4
	move.b	#$01,d5
	lsr.b	d6,d2
	lsr.b	d6,d4
	move.w	#7,d6
	sub.w	d7,d6
	lsl.b	d6,d3
	lsl.b	d6,d5

	move.w	d0,d7
horz_loop:
	move.b	#$FF,d6
	cmp.w	d0,d7
	bne	horz_not_left
	and.b	d2,d6
horz_not_left:
	cmp.w	d1,d7
	bne	horz_not_right
	and.b	d3,d6
horz_not_right:
	or.b	d6,0(a0,d7.w)
	or.b	d6,0(a1,d7.w)
	add.w	#1,d7
	cmp.w	d1,d7
	bls	horz_loop

	lea	30(a0),a2
vert_loop:
	or.b	d4,0(a2,d0.w)
	or.b	d5,0(a2,d1.w)
	lea	30(a2),a2
	cmp.l	a1,a2
	bcs	vert_loop

	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************

flib@0006:
erase_rect:
	movem.l	d0-d7/a0-a2,-(sp)

	bsr	prep_rect
	move.b	#$FF,d2
	move.b	#$FF,d3
	lsr.b	d6,d2
	move.w	#7,d6
	sub.w	d7,d6
	lsl.b	d6,d3
	not.b	d2
	not.b	d3

	not.b	d6
	move.l	a0,a2
vert_loop1:
	move.w	d0,d7
horz_loop1:
	clr.b	d6
	cmp.w	d0,d7
	bne	horz_not_left1
	or.b	d2,d6
horz_not_left1:
	cmp.w	d1,d7
	bne	horz_not_right1
	or.b	d3,d6
horz_not_right1:
	and.b	d6,0(a2,d7.w)
	add.w	#1,d7
	cmp.w	d1,d7
	bls	horz_loop1
	lea	30(a2),a2
	cmp.l	a1,a2
	bls	vert_loop1

	movem.l	(sp)+,d0-d7/a0-a2
	rts

;*****************************************************

flib@0007:
show_dialog:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	0(a6),dialog_pos+0
	move.l	4(a6),dialog_pos+4

	sub.l	#8,sp
	move.l	0(a6),0(sp)
	move.l	4(a6),4(sp)
	bsr	erase_rect
	add.l	#$00010001,0(sp)
	sub.l	#$00010001,4(sp)
	bsr	frame_rect
	add.l	#$00010001,0(sp)
	sub.l	#$00010001,4(sp)
	bsr	frame_rect
	add.l	#$00020002,0(sp)
	sub.l	#$00020002,4(sp)
	bsr	frame_rect
	add.l	#8,sp

	move.w	#2,-(sp)
	jsr	tios::FontSetSys
	add.l	#2,sp
	move.b	d0,old_font		; save original font

	sub.l	#$A,sp
	move.l	0(a6),d6
	add.l	#8,a6
dialog_loop:
	move.l	(a6)+,d0
	beq	dialog_done
	add.l	d6,d0
	move.l	d0,$0(sp)
	move.l	(a6)+,$4(sp)
	move.w	#$0004,$8(sp)
	jsr	tios::DrawStrXY
	bra	dialog_loop
dialog_done:
	add.l	#10,sp

	move.b	old_font,d0
	move.w	d0,-(sp)
	jsr	tios::FontSetSys	; restore original font
	add.l	#2,sp

	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************

flib@0008:
clear_dialog:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	dialog_pos+4,-(sp)
	move.l	dialog_pos+0,-(sp)
	bsr	erase_rect
	add.l	#8,sp

	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************

flib@0009:
clr_scr:
	movem.l	d0/a0,-(sp)

	bsr	zap_screen

	lea	LCD_MEM+121*30,a0
	move.l	#$FFFFFFFF,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	d0,(a0)+

	movem.l	(sp)+,d0/a0
	rts

;*****************************************************

flib@000A:
zap_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a7,save

	lea	LCD_MEM+$F00,a7
	movem.l	zeroes,d0-d7/a0-a6

	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times
	movem.l	d0-d7/a0-a6,-(a7)	; repeated 64 times

	move.l	save,a7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;*****************************************************

flib@000B:
idle_loop:
	movem.l	a0-a6/d1-d7,-(sp)

idle_start:
	move.l	APD_INIT,APD_TIMER	; reset APD timer (1)
	clr.w	APD_FLAG		; reset APD timer (2)
	move.w	#ACTIVITY_IDLE,-(sp)
	jsr	tios::ST_busy
	add.l	#2,sp
wait_idle:
	tst.w	APD_FLAG		; time for APD?
	bne	do_apd
	tst.w	tios::kb_globals+$1C	; has a key been pressed?
	beq	wait_idle
	move.l	APD_INIT,APD_TIMER	; reset APD timer (1)
	move.w	tios::kb_globals+$1E,d0
	clr.w	tios::kb_globals+$1C	; clear key buffer

	move.l	d0,-(sp)
	move.w	#ACTIVITY_BUSY,-(sp)
	jsr	tios::ST_busy
	add.l	#2,sp
	move.l	(sp)+,d0

try_key_off:
	cmp.w	#$210B,d0
	bne	not_key_off
	bra	do_apd
not_key_off:

	movem.l	(sp)+,a0-a6/d1-d7
	rts

do_apd:
	trap	#4
	bra	idle_start

;*****************************************************

flib@000C:
random:
	move.l	d1,-(sp)
	move.w	rand_seed(pc),d1
	mulu.w	#31421,d1
	add.w	#6927,d1
	mulu.w	d1,d0
	move.w	d1,rand_seed
	clr.w	d0
	swap	d0
	move.l	(sp)+,d1
	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

flib@000D:
rand_seed	dc.w	0

; for zap_screen
zeroes		dcb.l	15,0

_library	dc.b	"flib",0

;*****************************************************
	BSS

; for the dialog routines
old_font	dc.w	0
dialog_pos	ds.w	4	; x1,y1,x2,y2

; for zap_screen
save		dc.l	0

;*****************************************************

	end
