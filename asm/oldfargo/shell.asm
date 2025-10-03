	@program	main,0

	include	"header.h"

;*****************************************************
; main
;*****************************************************
main:
	tst.b	in_fargo
	bne	exit
	st.b	in_fargo

	move.w	(STATUS_LINE+2),d0
	lsr.w	#8,d0
	lsr.w	#5,d0
	and.w	#3,d0
	move.w	d0,old_activity

	move.w	#ACTIVITY_BUSY,-(sp)
	jsr	romlib[set_activity]
	add.l	#2,sp

view_folders:
	clr.b	folder_mode
	move.w	($5D8C),folder_handle
	bra	view_list
view_progs:
	st.b	folder_mode
view_list:
	pea	proglist_handle(pc)
	jsr	romlib[dispose_handle]
	addq	#4,sp
no_del_proglist:
	move.w	folder_handle(pc),d0
	DEREF	d0,a0
	clr.l	d0
	move.w	2(a0),d0		; get number of variables
	add.w	#1,d0			; add 1 (for terminating zero)
	lsl.w	#1,d0			; multiply by 2
	move.l	d0,-(sp)		; set size of proglist buffer
	jsr	romlib[create_handle]
	add.l	#4,sp
	tst.l	d0
	beq	exit_clr
	move.w	d0,proglist_handle

enum_vars:
	DEREF	d0,a0		; get address of proglist
	move.w	folder_handle(pc),d0
	DEREF	d0,a1
	clr.w	d0		; offset(a0) of next entry in proglist
	move.w	#4,d2		; offset(a1) of current variable descriptor
	move.w	2(a1),d1	; get + test number of variables
	beq	enum_done
	sub.w	#1,d1		; get ready for dbf loop
var_loop:
	tst.b	folder_mode
	beq	var_no_check
	tst.b	no_test
	bne	var_no_check
	move.w	$A(a1,d2.w),d7
	DEREF	d7,a2
	cmp.l	#PROGRAM_SIG,2(a2)
	bne	next_var
	move.w	(a2),d6
	cmp.b	#$DC,2-1(a2,d6.w)
	bne	next_var
	tst.w	2+h_5(a2)
	beq	next_var
var_no_check:
	move.w	d2,0(a0,d0.w)		; enter variable into proglist
	add.w	#2,d0
next_var:
	add.w	#$C,d2
	dbf.w	d1,var_loop
enum_done:
	clr.w	0(a0,d0.w)
	move.w	d0,max_prog
	clr.w	top_prog
	clr.w	cur_prog
	clr.w	exit_flag
	clr.w	exec_error

	swap	d0
	clr.w	d0
	swap	d0
	addq	#2,d0
	move.l	d0,-(sp)
	move.w	proglist_handle(pc),-(sp)
	jsr	romlib[resize_handle]
	addq	#6,sp

	tst.b	folder_mode
	beq	redraw
	tst.w	max_prog		; any programs in memory?
	bne	redraw			; yes

	clr.w	exec_error

	bsr	xor_cursor
	lea	error2_dlog(pc),a6
	jsr	flib[show_dialog]
	jsr	flib[idle_loop]
	jsr	flib[clear_dialog]
	bra	view_folders

;*****************************************************

redraw:
	jsr	flib[clr_scr]
	bset.b	#7,(STATUS_LINE+2)	; force status line to update
	jsr	romlib[update_status]

redraw_vars:
	move.w	#$0700,d0
	trap	#1

	lea	-$A(sp),sp		; make stack frame for puttext()
	move.w	#$0004,$8(sp)		; black text on white background

	move.w	#2,-(sp)		; 10-point font
	jsr	romlib[set_font]
	add.l	#2,sp
	move.b	d0,old_font		; save original font
	move.w	#008,$0(sp)
	move.w	#004,$2(sp)
	move.l	#about_1,$4(sp)
	jsr	romlib[puttext]

	move.w	#1,-(sp)		; 8-point font
	jsr	romlib[set_font]
	add.l	#2,sp
	move.w	#187,$0(sp)
	move.w	#005,$2(sp)
	move.l	#fargo_about,$4(sp)
	jsr	romlib[puttext]

	lea	LCD_MEM,a3
	move.w	#30/2-1,d6
draw_line_1:
	move.w	#$FFFF,(30*$10)(a3)
	move.w	#$FFFF,(a3)+
	dbf.w	d6,draw_line_1

	lea	LCD_MEM,a3
	move.w	#$79,d6
draw_line_2a:
	bset.b	#7,00(a3)
	cmp.l	#LCD_MEM+30*CURSOR_TOP_Y,a3
	bcs	draw_line_2b
	bset.b	#7,07(a3)
draw_line_2b:
	bset.b	#0,29(a3)
	lea	$1E(a3),a3
	dbf.w	d6,draw_line_2a

	move.w	#CURSOR_TOP_Y,$2(sp)	; y coordinate
	move.w	proglist_handle(pc),d0
	DEREF	d0,a2
	move.w	top_prog(pc),d6
	move.w	#CURSOR_MAX,d5
	move.w	folder_handle(pc),d0
	DEREF	d0,a4
list_loop:
	move.w	0(a2,d6.w),d7
	beq	list_end
	add.w	#2,d6
	lea	0(a4,d7.w),a3

	move.w	#PROGNAME_X,$0(sp)	; x coordinate
	move.l	a3,$4(sp)
	move.b	8(a3),d2
	clr.b	8(a3)
	jsr	romlib[puttext]		; print program name
	move.b	d2,8(a3)

	tst.b	folder_mode
	beq	no_comment
	move.w	$A(a3),d7
	DEREF	d7,a3
	add.l	#2,a3
	move.w	h_5(a3),d0
	lea	0(a3,d0.w),a3
	move.l	a3,$4(sp)
	move.w	#COMMENT_X,$0(sp)	; x coordinate
	jsr	romlib[puttext]		; print program comment
no_comment:

	add.w	#$8,$2(sp)		; go to next row
	dbf.w	d5,list_loop
list_end:

	move.b	old_font(pc),d0
	move.w	d0,-(sp)
	jsr	romlib[set_font]	; restore original font
	lea	(2+$A)(sp),sp		; destroy both stack frames

	clr.w	d0
	trap	#1

;*****************************************************

	tst.w	exec_error		; was there an exec() error?
	bne	show_error		; yes

done_jump:
	bsr	xor_cursor

wait_key:
	jsr	flib[idle_loop]

	cmp.w	#$0152,d0
	beq	key_up
	cmp.w	#$0158,d0
	beq	key_down
	cmp.w	#$1152,d0
	beq	key_2nd_up
	cmp.w	#$1158,d0
	beq	key_2nd_down
	cmp.w	#$0151,d0
	beq	key_left
	cmp.w	#$0154,d0
	beq	key_right
	cmp.w	#$000D,d0
	beq	key_enter
	cmp.w	#$0020,d0
	beq	key_space
	cmp.w	#$010C,d0
	beq	key_F1
	cmp.w	#$0108,d0
	beq	exit_dealloc
	cmp.w	#'A',d0
	bcs	wait_key
	cmp.w	#'Z'+1,d0
	bcc	not_upper
	add.w	#'a'-'A',d0
	bra	key_alpha
not_upper:
	cmp.w	#'a',d0
	bcs	wait_key
	cmp.w	#'z'+1,d0
	bcc	wait_key

;*****************************************************

key_alpha:
	move.w	d0,d6
	bsr	xor_cursor

	move.w	folder_handle(pc),d7
	DEREF	d7,a0
	move.w	proglist_handle(pc),d7
	DEREF	d7,a1
	move.w	cur_prog(pc),d0

	move.w	0(a1,d0.w),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d1,d6
	bcc	alpha_loop
alpha_begin:
	clr.w	d0
	move.w	(a1),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d6,d1
	bcc	alpha_done
alpha_loop:
	move.b	d1,d2
	add.w	#2,d0
	cmp.w	max_prog(pc),d0
	beq	alpha_end
	move.w	0(a1,d0.w),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d6,d1
	beq	alpha_done
	bcs	alpha_loop
	cmp.b	d6,d2
	beq	alpha_begin
	bra	alpha_done

alpha_end:
	sub.w	#2,d0
alpha_done:
	move.w	d0,cur_prog
	sub.w	top_prog(pc),d0
	bcc	alpha_below
	move.w	cur_prog(pc),top_prog
	bra	redraw
alpha_below:
	cmp.w	#2*(CURSOR_MAX+1),d0
	bcs	done_jump
	sub.w	#2*CURSOR_MAX,d0
	add.w	d0,top_prog
	bra	redraw

;*****************************************************

exit_dealloc:
	pea	proglist_handle(pc)
	jsr	romlib[dispose_handle]
	addq	#4,sp
exit_clr:
	clr.b	in_fargo
exit:
	move.w	old_activity(pc),-(sp)
	jsr	romlib[set_activity]
	add.l	#2,sp

	move.w	#$0888,$600010
	rts

;*****************************************************

key_up:
	move.w	cur_prog(pc),d4
	beq	wait_key

	bsr	xor_cursor

	sub.w	#2,d4
	move.w	d4,cur_prog
	cmp.w	top_prog(pc),d4
	bcc	done_jump
	move.w	d4,top_prog

	lea	LCD_MEM+30*CURSOR_TOP_Y+30*8*CURSOR_MAX,a0
	lea	LCD_MEM+30*CURSOR_TOP_Y+30*8*CURSOR_MAX+30*8,a1
	move.l	#30*8*CURSOR_MAX/4-1,d0
scroll_up:
	move.l	-(a0),-(a1)
	dbf.w	d0,scroll_up

	move.w	#CURSOR_TOP_Y,d7
	bra	scroll_finish

;*****************************************************

key_down:
	move.w	cur_prog(pc),d4
	move.w	max_prog(pc),d0
	sub.w	#2,d0
	cmp.w	d0,d4
	beq	wait_key

	bsr	xor_cursor

	add.w	#2,d4
	move.w	d4,cur_prog
	sub.w	#2*(CURSOR_MAX+1),d4
	cmp.w	top_prog(pc),d4
	bmi	done_jump
	add.w	#2,top_prog

	lea	LCD_MEM+30*CURSOR_TOP_Y,a0
	lea	LCD_MEM+30*CURSOR_TOP_Y+30*8,a1
	move.l	#30*8*CURSOR_MAX/4-1,d0
scroll_down:
	move.l	(a1)+,(a0)+
	dbf.w	d0,scroll_down

	move.w	#CURSOR_TOP_Y+8*CURSOR_MAX,d7
	bra	scroll_finish

;*****************************************************

scroll_finish:

	move.l	a0,a1

	move.w	#30*8/4-1,d0
	clr.l	d1
erase_loop:
	move.l	d1,(a0)+
	dbf.w	d0,erase_loop

	move.w	#8-1,d0
fix_loop:
	bset.b	#7,00(a1)
	bset.b	#7,07(a1)
	bset.b	#0,29(a1)
	lea	30(a1),a1
	dbf.w	d0,fix_loop

	lea	-$A(sp),sp		; make stack frame for puttext()

	move.w	#1,-(sp)		; 8-point font
	jsr	romlib[set_font]
	add.l	#2,sp
	move.b	d0,old_font		; save original font

	move.w	d7,$2(sp)		; y coordinate

	move.w	proglist_handle(pc),d0
	DEREF	d0,a2
	move.w	cur_prog(pc),d6
	move.w	folder_handle(pc),d0
	DEREF	d0,a4
	move.w	0(a2,d6),d7
	lea	0(a4,d7.w),a3

	move.w	#$0004,$8(sp)		; black text on white background
	move.w	#PROGNAME_X,$0(sp)	; x coordinate
	move.l	a3,$4(sp)		; string
	move.b	8(a3),d2
	clr.b	8(a3)
	jsr	romlib[puttext]		; print program name
	move.b	d2,8(a3)

	move.w	$A(a3),d7
	DEREF	d7,a3
	add.l	#2,a3
	move.w	h_5(a3),d0
	lea	0(a3,d0.w),a3
	move.l	a3,$4(sp)		; string
	move.w	#COMMENT_X,$0(sp)	; x coordinate
	jsr	romlib[puttext]		; print program comment

	move.b	old_font(pc),d0
	move.w	d0,-(sp)
	jsr	romlib[set_font]	; restore original font
	lea	(2+$A)(sp),sp		; destroy both stack frames

	bra	done_jump

;*****************************************************

key_2nd_up:
	move.w	cur_prog(pc),d4
	beq	wait_key

	bsr	xor_cursor

	move.w	top_prog(pc),d7
	cmp.w	d4,d7
	beq	scroll_jump_up
	move.w	d7,cur_prog

	bra	done_jump

scroll_jump_up:
	sub.w	#2*CURSOR_MAX,d7
	bcc	scroll_up_no_home
	clr.w	d7
scroll_up_no_home:
	move.w	d7,cur_prog
	move.w	d7,top_prog
	bra	redraw

;*****************************************************

key_2nd_down:
	move.w	cur_prog(pc),d4
	move.w	max_prog(pc),d0
	sub.w	#2,d0
	cmp.w	d0,d4
	beq	wait_key

	bsr	xor_cursor

	move.w	top_prog(pc),d7
	add.w	#2*CURSOR_MAX,d7
	move.w	max_prog(pc),d0
	cmp.w	d0,d7
	bcs	scroll_down_filled
	sub.w	#2,d0
	move.w	d0,d7
scroll_down_filled:
	cmp.w	d4,d7
	beq	scroll_jump_down
	move.w	d7,cur_prog

	bra	done_jump

scroll_jump_down:
	add.w	#2*CURSOR_MAX,d7
	move.w	max_prog(pc),d0
	cmp.w	d0,d7
	bcs	scroll_down_no_home
	sub.w	#2,d0
	move.w	d0,d7
scroll_down_no_home:
	move.w	d7,cur_prog
	sub.w	#2*CURSOR_MAX,d7
	move.w	d7,top_prog
	bra	redraw

;*****************************************************

key_left:
	tst.b	folder_mode
	beq	wait_key
	bra	view_folders

;*****************************************************

key_right:
	tst.b	folder_mode
	bne	wait_key
	bra	run_prog

key_enter:
	tst.b	no_test
	bne	wait_key

run_prog:
	move.w	cur_prog(pc),d0
	move.w	proglist_handle(pc),d7
	DEREF	d7,a0
	move.w	0(a0,d0.w),d0

	move.w	folder_handle(pc),d7
	DEREF	d7,a0
	move.w	$A(a0,d0.w),d0

	tst.b	folder_mode
	bne	exec_prog
enter_folder:
	move.w	d0,folder_handle
	bra	view_progs
exec_prog:
	move.w	d0,-(sp)
	jsr	core[exec]
	add.l	#2,sp
	move.w	d0,exec_error
	bra	redraw

;*****************************************************

key_space:
	bchg.b	#0,no_test
	tst.b	folder_mode
	beq	view_folders
	bra	view_progs

;*****************************************************

key_F1:
	bsr	xor_cursor
	lea	about_dlog(pc),a6
	jsr	flib[show_dialog]
	jsr	flib[idle_loop]
	jsr	flib[clear_dialog]
	bra	redraw_vars

;*****************************************************

show_error:
	clr.w	exec_error
	lea	error1_dlog(pc),a6
	jsr	flib[show_dialog]
	jsr	flib[idle_loop]
	jsr	flib[clear_dialog]
	bra	redraw_vars

;*****************************************************
; xor_cursor: invert cursor bar
;*****************************************************
xor_cursor:

	move.w	cur_prog(pc),d0
	sub.w	top_prog(pc),d0
	lsl.w	#3,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0

	lea	LCD_MEM+30*CURSOR_TOP_Y,a0
	lea	0(a0,d0.w),a0

	move.w	#$8-1,d0
xor_cursor_loop:
	eor.l	#$7FFFFFFF,0(a0)
	eor.l	#$FFFFFF00,4(a0)
	lea	30(a0),a0
	dbf.w	d0,xor_cursor_loop

	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

	EVEN

old_font	dc.w	0
old_activity	dc.w	0

exit_flag	dc.w	0
exec_error	dc.w	0

folder_handle	dc.w	0
proglist_handle	dc.w	0

max_prog	dc.w	0
top_prog	dc.w	0
cur_prog	dc.w	0

in_fargo	dc.b	0
folder_mode	dc.b	0
no_test		dc.b	0

;*****************************************************
; static data and equates
;*****************************************************

PROGNAME_X	EQU	004
COMMENT_X	EQU	060
CURSOR_TOP_Y	EQU	017
CURSOR_MAX	EQU	13-1

fargo_about	dc.b	"F1-About",0

	EVEN
about_x1	EQU	037
about_y1	EQU	028
about_xs	EQU	166
about_ys	EQU	073
about_dlog:
	dc.w	about_x1
	dc.w	about_y1
	dc.w	about_x1+about_xs
	dc.w	about_y1+about_ys
	dc.w	about_xs/2-16*4,010
	dc.l	about_1
	dc.w	about_xs/2-16*4,026
	dc.l	about_2
	dc.w	about_xs/2-15*4,041
	dc.l	about_3
	dc.w	about_xs/2-19*4,053
	dc.l	about_4
	dc.w	0,0

	EVEN
error1_x1	EQU	018
error1_y1	EQU	031
error1_xs	EQU	204
error1_ys	EQU	065
error1_dlog:
	dc.w	error1_x1
	dc.w	error1_y1
	dc.w	error1_x1+error1_xs
	dc.w	error1_y1+error1_ys
	dc.w	error1_xs/2-23*4,010
	dc.l	error1_1
	dc.w	error1_xs/2-22*4,020
	dc.l	error1_2
	dc.w	error1_xs/2-18*4,030
	dc.l	error1_3
	dc.w	error1_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0


	EVEN
error2_x1	EQU	038
error2_y1	EQU	031
error2_xs	EQU	164
error2_ys	EQU	065
error2_dlog:
	dc.w	error2_x1
	dc.w	error2_y1
	dc.w	error2_x1+error2_xs
	dc.w	error2_y1+error2_ys
	dc.w	error2_xs/2-18*4,010
	dc.l	error2_1
	dc.w	error2_xs/2-15*4,020
	dc.l	error2_2
	dc.w	error2_xs/2-12*4,030
	dc.l	error2_3
	dc.w	error2_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0

about_1:	dc.b	"FBrowser v0.2.0",0
about_2:	dc.b	"Copyright ",$A9," 1997",0
about_3:	dc.b	"David Ellsworth",0
about_4:	dc.b	"davidell@ticalc.org",0

error1_1:	dc.b	"Cannot find one or more",0
error1_2:	dc.b	"libraries required for",0
error1_3:	dc.b	"program execution.",0

error2_1:	dc.b	"There are no Fargo",0
error2_2:	dc.b	"programs inside",0
error2_3:	dc.b	"that folder.",0

keyexit:	dc.b	"Press any key.",0

	reloc_open
	add_library	romlib
	add_library	flib
	reloc_close
	end
