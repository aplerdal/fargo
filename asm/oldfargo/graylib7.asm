	@library	graylib7

;************** Start of Fargo library ***************

	label	on
	movem.l	d1-d7/a0-a6,-(sp)

	bsr	alloc_plane
	tst.l	d0
	beq	graylib_fail
	move.w	d6,handle0
	move.l	a6,plane0
	move.w	d7,table+2*0

	bsr	alloc_plane
	tst.l	d0
	beq	graylib_fail
	move.w	d6,handle1
	move.l	a6,plane1
	move.w	d7,table+2*2
	move.w	d7,table+2*4

	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

	movem.l	(sp)+,d1-d7/a0-a6
	st.b	d0
	rts

;*****************************************************

	label	off
	movem.l	d1-d7/a0-a6,-(sp)

	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1,$64
	bset.b	#2,$600001
	trap	#1

	move.w	#$0888,($600010)

graylib_fail:

	pea	handle0(pc)
	jsr	romlib[dispose_handle]
	addq	#4,sp

	pea	handle1(pc)
	jsr	romlib[dispose_handle]
	addq	#4,sp

	movem.l	(sp)+,d1-d7/a0-a6
	clr.l	d0
	rts

;*****************************************************
; int_1: auto int 1 handler
;*****************************************************
int_1:
	move.w	#$2700,sr

	add.w	#1,vbl_phase
	and.w	#7,vbl_phase
	beq	int_1_skip

	movem.l	d0/a0,-(sp)
	move.w	phase(pc),d0
	lea	table(pc),a0
	move.w	0(a0,d0.w),($600010)
	add.w	#2,d0
	cmp.w	#2*6,d0
	bne	no_wrap
	clr.w	d0
no_wrap:
	move.w	d0,phase
	movem.l	(sp)+,d0/a0

int_1_skip:
	move.l	old_int_1,-(sp)
	rts

;*****************************************************
; alloc_plane: allocate a bitplane
;
; returns: D0.L = nonzero:success / zero:failure
;          D6.W = handle of bitplane
;          A6   = address of bitplane
;          D7.W = hardware address of bitplane
;*****************************************************
alloc_plane:

	move.l	#$F08,-(sp)
	jsr	romlib[create_handle]
	addq	#4,sp
	move.w	d0,d6
	beq	alloc_fail

	handle_ptr	d0,a6
	move.l	a6,d0
	add.l	#7,d0
	lsr.l	#3,d0
	move.w	d0,d7

	lsl.l	#3,d0
	move.l	d0,a6

alloc_done:
	st.b	d0
	rts

alloc_fail:
	clr.l	d0
	rts

;*****************************************************

	label	plane0
	dc.l	0
	label	plane1
	dc.l	0
	label	plane2
	dc.l	LCD_MEM

old_int_1	dc.l	0

handle0		dc.w	0
handle1		dc.w	0

vbl_phase	dc.w	0
phase		dc.w	0

table:
	dc.w	0
	dc.w	$0888
	dc.w	0
	dc.w	$0888
	dc.w	0
	dc.w	$0888

vbl_stage	dc.w	0

;*************** End of Fargo library ****************

	reloc_open
	add_library	romlib
	reloc_close
	end
