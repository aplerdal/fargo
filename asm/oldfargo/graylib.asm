	@library	graylib

;************** Start of Fargo library ***************

	label	on
	movem.l	d0-d7/a0-a5,-(a7)

	move.l	#$F08,-(a7)
	jsr	romlib[create_handle]
	add.l	#4,a7
	move.w	d0,plane_0

	handle_ptr	d0,a6
	move.l	a6,d0

	add.l	#7,d0
	lsr.l	#3,d0
	move.w	d0,table+0

	lsl.l	#3,d0
	move.l	d0,a6

	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

	movem.l	(a7)+,d0-d7/a0-a5
	rts

;*****************************************************

	label	off
	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1,$64
	bset.b	#2,$600001
	trap	#1

	move.w	#$0888,($600010)

	move.w	plane_0(pc),-(a7)
	jsr	romlib[destroy_handle]
	add.l	#2,a7

	movem.l	(a7)+,d0-d7/a0-a6
	rts

;*****************************************************
; int_1: auto int 1 handler
;*****************************************************
int_1:
	move.w	#$2700,sr

	add.w	#1,vbl_phase
	and.w	#3,vbl_phase
	bne	int_1_skip

	movem.l	d0/a0,-(a7)
	move.w	phase(pc),d0
	lea	table(pc),a0
	move.w	0(a0,d0.w),($600010)
	add.w	#2,d0
	cmp.w	#2*3,d0
	bne	no_wrap
	clr.w	d0
no_wrap:
	move.w	d0,phase
	movem.l	(a7)+,d0/a0

int_1_skip:
	move.l	old_int_1,-(a7)
	rts

;*****************************************************

old_int_1	dc.l	0

plane_0		dc.w	0

vbl_phase	dc.w	0
phase		dc.w	0

table:
	dc.w	0
	dc.w	$0888
	dc.w	$0888

vbl_stage	dc.w	0

;*************** End of Fargo library ****************

	reloc_open
	add_library	romlib
	reloc_close
	end
