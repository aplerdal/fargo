	include	"tios.h"
	include	"flib.h"
	xdef	_main
	xdef	_comment

;*****************************************************

_main:
	jsr	flib::clr_scr

	move.w	#120,d3
	move.w	#064,d4
	move.w	#2,d5
	clr.w	d6

main_loop:
	tst.w	tios::kb_globals+$1C
	beq	no_key
	clr.w	tios::kb_globals+$1C
	move.w	tios::kb_globals+$1E,d0

try_key_exit:
	cmp.w	#$0108,d0		; [ESC] to quit
	beq	exit
not_key_exit:
try_key_r:
	cmp.w	#$0072,d0		; [R] to reverse time
	bne	not_key_r
	not.w	d6
not_key_r:

no_key:
	tst.w	d6
	bne	time_reverse

	bsr	do_direction
do_langston:
	move.w	d4,-(a7)
	move.w	d3,-(a7)
	jsr	flib::find_pixel
	add.l	#4,a7
	bchg.b	d0,(a0)
	bne	pixel_1
pixel_0:
	add.w	#3,d5
	and.w	#3,d5
	bra	main_loop
pixel_1:
	add.w	#1,d5
	and.w	#3,d5
	bra	main_loop

time_reverse:

	move.w	d4,-(a7)
	move.w	d3,-(a7)
	jsr	flib::find_pixel
	add.l	#4,a7
	bchg.b	d0,(a0)
	bne	r_pixel_1
r_pixel_0:
	add.w	#3,d5
	and.w	#3,d5
	bra	r_do_direction
r_pixel_1:
	add.w	#1,d5
	and.w	#3,d5
	bra	r_do_direction
r_do_direction:
	bchg.w	#1,d5
	bsr	do_direction
	bchg.w	#1,d5
	bra	main_loop

exit:
	rts

;*****************************************************
do_direction:

d_0:
	tst.w	d5
	bne	d_1
	add.w	#1,d3
	cmp.w	#240,d3
	bne	dir_done
	clr.w	d3
	rts
d_1:
	cmp.w	#1,d5
	bne	d_2
	add.w	#1,d4
	cmp.w	#121,d4
	bne	dir_done
	clr.w	d4
	rts
d_2:
	cmp.w	#2,d5
	bne	d_3
	sub.w	#1,d3
	bcc	dir_done
	move.w	#239,d3
	rts
d_3:
	sub.w	#1,d4
	bcc	dir_done
	move.w	#120,d4
dir_done:
	rts

;*****************************************************

_comment	dc.b	"Langston's Ant",0

;*****************************************************

	end
