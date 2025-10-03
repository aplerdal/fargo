	@library	flib

;************** Start of Fargo library ***************

pixel_do	macro
	movem.l	d0-d1/a0,-(a7)

	lea	LCD_MEM,a0

	move.w	4*4+2(a7),d0		; y-coordinate
	cmp.w	#128,d0
	bcc	\pixel_bad
	lsl.w	#1,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0
	lea	0(a0,d0.w),a0

	move.w	4*4+0(a7),d0		; x-coordinate
	cmp.w	#240,d0
	bcc	\pixel_bad
	move.w	d0,d1
	lsr.w	#3,d0

	not.w	d1
	and.w	#7,d1
	b\1.b	d1,0(a0,d0.w)

\pixel_bad:
	movem.l	(a7)+,d0-d1/a0
		endm

;*****************************************************

	label	find_pixel
	move.w	d1,-(a7)

	lea	LCD_MEM,a0

	move.w	(4+2)+2(a7),d0		; y-coordinate
	cmp.w	#128,d0
	bcc	pixel_bad
	lsl.w	#1,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0
	lea	0(a0,d0.w),a0

	move.w	(4+2)+0(a7),d1		; x-coordinate
	cmp.w	#240,d1
	bcc	pixel_bad
	move.w	d1,d0
	lsr.w	#3,d1
	lea	0(a0,d1.w),a0
	not.w	d0
	and.w	#7,d0

pixel_good:
	move.w	(a7)+,d1
	rts

pixel_bad:
	sub.l	a0,a0
	bra	pixel_good

;*****************************************************

	label	pixel_on
	pixel_do	set
	rts

;*****************************************************

	label	pixel_off
	pixel_do	clr
	rts

;*****************************************************

	label	pixel_chg
	pixel_do	chg
	rts

;*****************************************************
; prep_rect: used by frame_rect and erase_rect
;*****************************************************
prep_rect:

	clr.l	d4
	move.w	$36(a7),d4
	move.w	d4,d5
	lsl.w	#5,d4
	lsl.w	#1,d5
	sub.w	d5,d4
	add.l	#LCD_MEM,d4
	move.l	d4,a0

	clr.l	d5
	move.w	$3A(a7),d5
	move.w	d5,d6
	lsl.w	#5,d5
	lsl.w	#1,d6
	sub.w	d6,d5
	add.l	#LCD_MEM,d5
	move.l	d5,a1

	move.w	$34(a7),d0
	move.w	d0,d6
	lsr.w	#3,d0
	and.w	#$7,d6

	move.w	$38(a7),d1
	move.w	d1,d7
	lsr.w	#3,d1
	and.w	#$7,d7

	rts

;*****************************************************

	label	frame_rect
	movem.l	d0-d7/a0-a2,-(a7)

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

	movem.l	(a7)+,d0-d7/a0-a2
	rts

;*****************************************************

	label	erase_rect
	movem.l	d0-d7/a0-a2,-(a7)

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

	movem.l	(a7)+,d0-d7/a0-a2
	rts

;*****************************************************

	label	show_dialog
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	0(a6),dialog_pos+0
	move.l	4(a6),dialog_pos+4

	sub.l	#8,a7
	move.l	0(a6),0(a7)
	move.l	4(a6),4(a7)
	bsr	erase_rect
	add.l	#$00010001,0(a7)
	sub.l	#$00010001,4(a7)
	bsr	frame_rect
	add.l	#$00010001,0(a7)
	sub.l	#$00010001,4(a7)
	bsr	frame_rect
	add.l	#$00020002,0(a7)
	sub.l	#$00020002,4(a7)
	bsr	frame_rect
	add.l	#8,a7

	move.w	#2,-(a7)
	jsr	romlib[set_font]
	add.l	#2,a7
	move.b	d0,old_font		; save original font

	sub.l	#$A,a7
	move.l	0(a6),d6
	add.l	#8,a6
dialog_loop:
	move.l	(a6)+,d0
	beq	dialog_done
	add.l	d6,d0
	move.l	d0,$0(a7)
	move.l	(a6)+,$4(a7)
	move.w	#$0004,$8(a7)
	jsr	romlib[puttext]
	bra	dialog_loop
dialog_done:
	add.l	#$A,a7

	move.b	old_font(pc),d0
	move.w	d0,-(a7)
	jsr	romlib[set_font]	; restore original font
	add.l	#2,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;*****************************************************

	label	clear_dialog
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	dialog_pos+4(pc),-(a7)
	move.l	dialog_pos+0(pc),-(a7)
	bsr	erase_rect
	add.l	#8,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;*****************************************************

	label	clr_scr
	movem.l	d0-d1/a0,-(a7)

	lea	LCD_MEM,a0
	move.w	#$F00/4-1,d0
	clr.l	d1
vid_clr1:
	move.l	d1,(a0)+
	dbf.w	d0,vid_clr1

	lea	LCD_MEM+121*30,a0
	move.w	#30/2-1,d0
	move.w	#$FFFF,d1
vid_clr2:
	move.w	d1,(a0)+
	dbf.w	d0,vid_clr2

	movem.l	(a7)+,d0-d1/a0
	rts

;*****************************************************

	label	idle_loop
	movem.l	a0-a6/d1-d7,-(a7)

idle_start:
	move.l	$5350,APD_TIMER		; reset APD timer (1)
	clr.w	APD_FLAG		; reset APD timer (2)
	move.w	#ACTIVITY_IDLE,-(a7)
	jsr	romlib[set_activity]
	add.l	#2,a7
wait_idle:
	stop	#$2000
	tst.w	APD_FLAG		; time for APD?
	beq	no_apd			; no -- do not shut down
do_apd:
	trap	#4
	bra	idle_start
no_apd:
	tst.w	$75B0			; has a key been pressed?
	beq	wait_idle
	move.l	$5350,APD_TIMER	; reset APD timer (1)
	move.w	$75B2,d0
	clr.w	$75B0			; clear key buffer

	move.l	d0,-(a7)
	move.w	#ACTIVITY_BUSY,-(a7)
	jsr	romlib[set_activity]
	add.l	#2,a7
	move.l	(a7)+,d0

try_key_off:
	cmp.w	#$210B,d0
	bne	not_key_off
	bra	do_apd
not_key_off:

	movem.l	(a7)+,a0-a6/d1-d7
	rts

;*****************************************************

	label	random
	move.l	d1,-(a7)
	move.w	rand_seed(pc),d1
	mulu.w	#31421,d1
	add.w	#6927,d1
	mulu.w	d1,d0
	move.w	d1,rand_seed
	clr.w	d0
	swap	d0
	move.l	(a7)+,d1
	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

rand_seed	dc.w	0

old_font	dc.w	0
dialog_pos	ds.w	4	; x1,y1,x2,y2

;*************** End of Fargo library ****************

	reloc_open
	add_library	romlib
	reloc_close
	end
