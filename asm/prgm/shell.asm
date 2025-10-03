	include	"tios.h"
	include	"flib.h"
	include	"kernel.h"
	include	"0_1_x.h"
	xdef	_main

FARGO_SIG	EQU	$0032
EXE_TYPE	EQU	'EXE '
APPL_SUBTYPE	EQU	'APPL'

;*****************************************************
; main
;*****************************************************
_main:
	tst.b	in_fargo
	bne	exit
	st.b	in_fargo

	move.w	tios::ST_flags+2,d0
	lsr.w	#8,d0
	lsr.w	#5,d0
	and.w	#3,d0
	move.w	d0,old_activity

	move.w	#ACTIVITY_BUSY,-(sp)
	jsr	tios::ST_busy
	add.l	#2,sp

	clr.b	no_test
	clr.w	proglist_handle

view_folders:
	st.b	folder_mode
	move.w	FOLDER_LIST_HANDLE,folder_handle
	bra	view_list
view_progs:
	clr.b	folder_mode
view_list:
	pea	proglist_handle
	jsr	tios::HeapFreeIndir
	addq	#4,sp
no_del_proglist:
	move.w	folder_handle,d0
	tios::DEREF d0,a0
	move.l	#0,d0
	move.w	2(a0),d0		; get number of variables
	add.w	#1,d0			; add 1 (for terminating zero)
	lsl.w	#1,d0			; multiply by 2
	move.l	d0,-(sp)		; set size of proglist buffer
	jsr	tios::HeapAlloc
	add.l	#4,sp
	tst.w	d0
	beq	exit_clr
	move.w	d0,proglist_handle

enum_vars:
	tios::DEREF d0,a0	; get address of proglist
	move.w	folder_handle,d0
	tios::DEREF d0,a1
	clr.w	d0		; offset(a0) of next entry in proglist
	move.w	#4,d2		; offset(a1) of current variable descriptor
	move.w	2(a1),d1	; get + test number of variables
	beq	enum_done
	sub.w	#1,d1		; get ready for dbf loop
var_loop:
	tst.b	folder_mode
	bne	var_no_check
	tst.b	no_test
	bne	var_no_check
	move.w	10(a1,d2.w),d7
	tios::DEREF d7,a2

	move.w	(a2),d6
	cmp.b	#$DC,2-1(a2,d6.w)
	bne	next_var
	cmp.l	#PROGRAM_SIG,2(a2)
	beq	var_no_check
	cmp.w	#FARGO_SIG,2(a2)
	bne     next_var
	cmp.l	#EXE_TYPE,4(a2)
	bne	next_var
	cmp.l	#APPL_SUBTYPE,8(a2)
	bne	next_var

	tst.w	20(a2)			; check if there's at least one export
	beq	next_var		; branch if there isn't
	tst.w	22(a2)			; check if the program comment is defined
	beq	next_var		; branch if it isn't
var_no_check:
	move.w	d2,0(a0,d0.w)		; enter variable into proglist
	add.w	#2,d0
next_var:
	add.w	#12,d2
	dbf.w	d1,var_loop
enum_done:
	clr.w	0(a0,d0.w)
	move.w	d0,max_prog
	clr.w	top_prog
	clr.w	cur_prog
	clr.w	exec_error

	swap	d0
	clr.w	d0
	swap	d0
	addq	#2,d0
	move.l	d0,-(sp)
	move.w	proglist_handle,-(sp)
	jsr	tios::HeapRealloc
	addq	#6,sp

	tst.b	folder_mode
	bne	redraw
	tst.w	max_prog		; any programs in memory?
	bne	redraw			; yes

	clr.w	exec_error

	lea	error2_dlog,a6
	jsr	flib::show_dialog
	jsr	flib::idle_loop
	jsr	flib::clear_dialog
	bra	view_folders

;*****************************************************

redraw:
	jsr	flib::clr_scr
	bset.b	#7,tios::ST_flags+2	; force status line to update
	jsr	tios::ST_eraseHelp

redraw_vars:
	move.w	#$0700,d0
	trap	#1

	lea	-10(sp),sp		; make stack frame for DrawStrXY()
	move.w	#$0004,8(sp)		; black text on white background

	move.w	#2,-(sp)		; 10-point font
	jsr	tios::FontSetSys
	add.l	#2,sp
	move.b	d0,old_font		; save original font
	move.w	#008,0(sp)
	move.w	#004,2(sp)
	move.l	#about_1,4(sp)
	jsr	tios::DrawStrXY

	move.w	#1,-(sp)		; 8-point font
	jsr	tios::FontSetSys
	add.l	#2,sp
	move.w	#187,0(sp)
	move.w	#005,2(sp)
	move.l	#fargo_about,4(sp)
	jsr	tios::DrawStrXY

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

	move.w	#CURSOR_TOP_Y,2(sp)	; y coordinate
	move.w	proglist_handle,d0
	tios::DEREF d0,a2
	move.w	top_prog,d6
	move.w	#CURSOR_MAX,d5
	move.w	folder_handle,d0
	tios::DEREF d0,a4
list_loop:
	move.w	0(a2,d6.w),d7
	beq	list_end
	add.w	#2,d6
	lea	0(a4,d7.w),a3

	move.w	#PROGNAME_X,0(sp)	; x coordinate
	move.l	a3,4(sp)
	move.b	8(a3),d2
	clr.b	8(a3)
	jsr	tios::DrawStrXY		; print program name
	move.b	d2,8(a3)

	tst.b	folder_mode
	bne	no_comment
	move.w	10(a3),d7
	tios::DEREF d7,a3
	cmp.l	#PROGRAM_SIG,2(a3)	; check if it's a Fargo 0.1.x program
	beq	old_comment
	cmp.l	#LIBRARY_SIG,2(a3)	; check if it's a Fargo 0.1.x library
	beq	old_comment
	cmp.w	#FARGO_SIG,2(a3)
	bne	no_comment
	cmp.l	#EXE_TYPE,4(a3)
	bne	no_comment
new_comment:
	move.w	22(a3),d0		; get pointer to program comment
	beq	no_comment
	bra	do_comment
old_comment:
        add.l   #2,a3
        move.w  h_5(a3),d0
	beq	no_comment
do_comment:
	lea	0(a3,d0.w),a3		; relative -> absolute
	move.l	a3,4(sp)
	move.w	#COMMENT_X,0(sp)	; x coordinate
	jsr	tios::DrawStrXY		; print program comment
no_comment:

	add.w	#8,2(sp)		; go to next row
	dbf.w	d5,list_loop
list_end:

	move.b	old_font,d0
	move.w	d0,-(sp)
	jsr	tios::FontSetSys	; restore original font
	lea	(2+10)(sp),sp		; destroy both stack frames

	clr.w	d0
	trap	#1

;*****************************************************

	tst.w	exec_error		; was there an exec() error?
	bne	show_error		; yes

done_jump:
	bsr	xor_cursor

wait_key:
	jsr	flib::idle_loop

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

	move.w	folder_handle,d7
	tios::DEREF d7,a0
	move.w	proglist_handle,d7
	tios::DEREF d7,a1
	move.w	cur_prog,d0

	move.l	#0,d7

	move.w	0(a1,d0.w),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d1,d6
	bcc	alpha_loop
alpha_begin:
	move.l	#0,d0
	move.w	(a1),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d6,d1
	bcc	alpha_done
alpha_loop:
	move.b	d1,d2
	add.w	#2,d0
	cmp.w	max_prog,d0
	beq	alpha_end
	move.w	0(a1,d0.w),d1
	move.b	0(a0,d1.w),d1
	cmp.b	d6,d1
	beq	alpha_done
	bcs	alpha_loop
	cmp.b	d6,d2
	beq	alpha_begin
	bra	alpha_done

alpha_start_over:
	st.b	d7
	bra	alpha_begin

alpha_end:
	tst.l	d7
	beq	alpha_start_over
	sub.w	#2,d0
alpha_done:
	move.w	d0,cur_prog
	sub.w	top_prog,d0
	bcc	alpha_below
	move.w	cur_prog,top_prog
	bra	redraw
alpha_below:
	cmp.w	#2*(CURSOR_MAX+1),d0
	bcs	done_jump
	sub.w	#2*CURSOR_MAX,d0
	add.w	d0,top_prog
	bra	redraw

;*****************************************************

exit_dealloc:
	pea	proglist_handle
	jsr	tios::HeapFreeIndir
	addq	#4,sp
exit_clr:
	clr.b	in_fargo
exit:
	move.w	old_activity,-(sp)
	jsr	tios::ST_busy
	add.l	#2,sp

	rts

;*****************************************************

key_up:
	move.w	cur_prog,d4
	beq	wait_key

	bsr	xor_cursor

	sub.w	#2,d4
	move.w	d4,cur_prog
	cmp.w	top_prog,d4
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
	move.w	cur_prog,d4
	move.w	max_prog,d0
	sub.w	#2,d0
	cmp.w	d0,d4
	beq	wait_key

	bsr	xor_cursor

	add.w	#2,d4
	move.w	d4,cur_prog
	sub.w	#2*(CURSOR_MAX+1),d4
	cmp.w	top_prog,d4
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
	move.l	#0,d1
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

	lea	-10(sp),sp		; make stack frame for DrawStrXY()

	move.w	#1,-(sp)		; 8-point font
	jsr	tios::FontSetSys
	add.l	#2,sp
	move.b	d0,old_font		; save original font

	move.w	d7,2(sp)		; y coordinate

	move.w	proglist_handle,d0
	tios::DEREF d0,a2
	move.w	cur_prog,d6
	move.w	folder_handle,d0
	tios::DEREF d0,a4
	move.w	0(a2,d6),d7
	lea	0(a4,d7.w),a3		; get pointer to symbol name

	move.w	#$0004,8(sp)		; black text on white background
	move.w	#PROGNAME_X,0(sp)	; x coordinate
	move.l	a3,4(sp)		; string
	move.b	8(a3),d2
	clr.b	8(a3)			; give it a null terminator so it prints properly
	jsr	tios::DrawStrXY		; print program name
	move.b	d2,8(a3)

	tst.b	folder_mode
	bne	no_comment_2
	move.w	10(a3),d7		; get symbol handle
	tios::DEREF d7,a3
	cmp.l	#PROGRAM_SIG,2(a3)	; check if it's a Fargo 0.1.x program
	beq	old_comment_2
	cmp.l	#LIBRARY_SIG,2(a3)	; check if it's a Fargo 0.1.x library
	beq	old_comment_2
	cmp.w	#FARGO_SIG,2(a3)
	bne	no_comment_2
	cmp.l	#EXE_TYPE,4(a3)
	bne	no_comment_2
new_comment_2:
	move.w	22(a3),d0		; get pointer to program comment
	bra	do_comment_2
old_comment_2:
        add.l   #2,a3
        move.w  h_5(a3),d0
do_comment_2:
	lea	0(a3,d0.w),a3
	move.l	a3,4(sp)		; string
	move.w	#COMMENT_X,0(sp)	; x coordinate
	jsr	tios::DrawStrXY		; print program comment
no_comment_2:

	move.b	old_font,d0
	move.w	d0,-(sp)
	jsr	tios::FontSetSys	; restore original font
	lea	(2+10)(sp),sp		; destroy both stack frames

	bra	done_jump

;*****************************************************

key_2nd_up:
	move.w	cur_prog,d4
	beq	wait_key

	bsr	xor_cursor

	move.w	top_prog,d7
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
	move.w	cur_prog,d4
	move.w	max_prog,d0
	sub.w	#2,d0
	cmp.w	d0,d4
	beq	wait_key

	bsr	xor_cursor

	move.w	top_prog,d7
	add.w	#2*CURSOR_MAX,d7
	move.w	max_prog,d0
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
	move.w	max_prog,d0
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
	bne	wait_key
	bra	view_folders

;*****************************************************

key_right:
	tst.b	folder_mode
	beq	wait_key

key_enter:
	move.w	cur_prog,d0
	move.w	proglist_handle,d7
	tios::DEREF d7,a0
	move.w	0(a0,d0.w),d0

	move.w	folder_handle,d7
	tios::DEREF d7,a0
	move.w	10(a0,d0.w),d0

	tst.b	folder_mode
	beq	exec_prog
enter_folder:
	move.w	d0,folder_handle
	bsr	xor_cursor
	bra	view_progs
exec_prog:
	move.w	d0,-(sp)
	bsr	xor_cursor
	jsr	kernel::exec
	add.l	#2,sp
	move.w	d0,exec_error
	bra	redraw

;*****************************************************

key_space:
	bchg.b	#0,no_test
	tst.b	folder_mode
	bne	view_folders
	bra	view_progs

;*****************************************************

key_F1:
	bsr	xor_cursor
	lea	about_dlog,a6
	jsr	flib::show_dialog
	jsr	flib::idle_loop
	jsr	flib::clear_dialog
	bra	redraw_vars

;*****************************************************

show_error:
	move.w	exec_error,d0
	clr.w	exec_error
	cmp.w	#6,d0			; is this beyond the known range of errors?
	bhi	done_jump		; if so, then don't display a message
	lsl.w	#1,d0
	lea	error_table,a6
	move.w	-2(a6,d0.w),d0
	lea	error_base,a6
	lea	0(a6,d0.w),a6
	jsr	flib::show_dialog
	jsr	flib::idle_loop
	jsr	flib::clear_dialog
	bra	redraw_vars

;*****************************************************
; xor_cursor: invert cursor bar
;*****************************************************
xor_cursor:

	move.w	cur_prog,d0
	sub.w	top_prog,d0
	lsl.w	#3,d0
	move.w	d0,d1
	lsl.w	#4,d0
	sub.w	d1,d0

	lea	LCD_MEM+30*CURSOR_TOP_Y,a0
	lea	0(a0,d0.w),a0

	move.w	#8-1,d0
xor_cursor_loop:
	eor.l	#$7FFFFFFF,0(a0)
	eor.l	#$FFFFFF00,4(a0)
	lea	30(a0),a0
	dbf.w	d0,xor_cursor_loop

	rts

;*****************************************************
; miscellaneous program data
;*****************************************************

in_fargo	dc.b	0

;*****************************************************
; static data and equates
;*****************************************************
	DATA

PROGNAME_X	EQU	004
COMMENT_X	EQU	060
CURSOR_TOP_Y	EQU	017
CURSOR_MAX	EQU	13-1

fargo_about	dc.b	"F1-About",0

	EVEN
about_x1	EQU	037
about_y1	EQU	022
about_xs	EQU	166
about_ys	EQU	085
about_dlog:
	dc.w	about_x1
	dc.w	about_y1
	dc.w	about_x1+about_xs
	dc.w	about_y1+about_ys
	dc.w	about_xs/2-15*4,010
	dc.l	about_1
	dc.w	about_xs/2-18*4,022
	dc.l	about_2
	dc.w	about_xs/2-16*4,038
	dc.l	about_3
	dc.w	about_xs/2-15*4,053
	dc.l	about_4
	dc.w	about_xs/2-19*4,065
	dc.l	about_5
	dc.w	0,0

error_table:
	dc.w	error1a_dlog-error_base
	dc.w	error1b_dlog-error_base
	dc.w	error1c_dlog-error_base
	dc.w	error1d_dlog-error_base
	dc.w	error1e_dlog-error_base
	dc.w	error1f_dlog-error_base
	dc.w	error1g_dlog-error_base
	dc.w	error1h_dlog-error_base

error_base:

	EVEN
error1a_x1	EQU	033
error1a_y1	EQU	036
error1a_xs	EQU	234
error1a_ys	EQU	055
error1a_dlog:
	dc.w	error1a_x1
	dc.w	error1a_y1
	dc.w	error1a_x1+error1a_xs
	dc.w	error1a_y1+error1a_ys
	dc.w	error1a_xs/2-13*4,010
	dc.l	error1a_1
	dc.w	error1a_xs/2-14*4,035
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1b_x1	EQU	002
error1b_y1	EQU	031
error1b_xs	EQU	236
error1b_ys	EQU	065
error1b_dlog:
	dc.w	error1b_x1
	dc.w	error1b_y1
	dc.w	error1b_x1+error1b_xs
	dc.w	error1b_y1+error1b_ys
	dc.w	error1b_xs/2-27*4,010
	dc.l	error1b_1
	dc.w	error1b_xs/2-27*4,020
	dc.l	error1b_2
	dc.w	error1b_xs/2-25*4,030
	dc.l	error1b_3
	dc.w	error1b_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1c_x1	EQU	018
error1c_y1	EQU	031
error1c_xs	EQU	204
error1c_ys	EQU	065
error1c_dlog:
	dc.w	error1c_x1
	dc.w	error1c_y1
	dc.w	error1c_x1+error1c_xs
	dc.w	error1c_y1+error1c_ys
	dc.w	error1c_xs/2-20*4,010
	dc.l	error1c_1
	dc.w	error1c_xs/2-18*4,020
	dc.l	error1c_2
	dc.w	error1c_xs/2-17*4,030
	dc.l	error1c_3
	dc.w	error1c_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1d_x1	EQU	018
error1d_y1	EQU	031
error1d_xs	EQU	204
error1d_ys	EQU	065
error1d_dlog:
	dc.w	error1d_x1
	dc.w	error1d_y1
	dc.w	error1d_x1+error1d_xs
	dc.w	error1d_y1+error1d_ys
	dc.w	error1d_xs/2-25*4,010
	dc.l	error1d_1
	dc.w	error1d_xs/2-21*4,020
	dc.l	error1d_2
	dc.w	error1d_xs/2-14*4,030
	dc.l	error1d_3
	dc.w	error1d_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1e_x1	EQU	002
error1e_y1	EQU	036
error1e_xs	EQU	236
error1e_ys	EQU	055
error1e_dlog:
	dc.w	error1e_x1
	dc.w	error1e_y1
	dc.w	error1e_x1+error1e_xs
	dc.w	error1e_y1+error1e_ys
	dc.w	error1e_xs/2-27*4,010
	dc.l	error1e_1
	dc.w	error1e_xs/2-14*4,035
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1f_x1	EQU	018
error1f_y1	EQU	031
error1f_xs	EQU	204
error1f_ys	EQU	065
error1f_dlog:
	dc.w	error1f_x1
	dc.w	error1f_y1
	dc.w	error1f_x1+error1f_xs
	dc.w	error1f_y1+error1f_ys
	dc.w	error1f_xs/2-22*4,010
	dc.l	error1f_1
	dc.w	error1f_xs/2-19*4,020
	dc.l	error1f_2
	dc.w	error1f_xs/2-14*4,035
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1g_x1	EQU	002
error1g_y1	EQU	031
error1g_xs	EQU	236
error1g_ys	EQU	065
error1g_dlog:
	dc.w	error1g_x1
	dc.w	error1g_y1
	dc.w	error1g_x1+error1g_xs
	dc.w	error1g_y1+error1g_ys
	dc.w	error1g_xs/2-27*4,010
	dc.l	error1g_1
	dc.w	error1g_xs/2-21*4,020
	dc.l	error1g_2
	dc.w	error1g_xs/2-22*4,030
	dc.l	error1g_3
	dc.w	error1g_xs/2-17*4,030
	dc.l	error1g_3
	dc.w	error1g_xs/2-14*4,045
	dc.l	keyexit
	dc.w	0,0

	EVEN
error1h_x1	EQU	008
error1h_y1	EQU	036
error1h_xs	EQU	224
error1h_ys	EQU	055
error1h_dlog:
	dc.w	error1h_x1
	dc.w	error1h_y1
	dc.w	error1h_x1+error1h_xs
	dc.w	error1h_y1+error1h_ys
	dc.w	error1h_xs/2-24*4,010
	dc.l	error1h_1
	dc.w	error1h_xs/2-14*4,025
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

about_1		dc.b	"FBrowser v0.3.1",0
about_2		dc.b	"for Fargo v0.2.8",0
about_3		dc.b	"Copyright ",$A9," 2000",0
about_4		dc.b	"David Ellsworth",0
about_5		dc.b	"davidell@ticalc.org",0

error1a_1	dc.b	"Out of memory",0

error1b_1	dc.b	"That program, or one of the",0
error1b_2	dc.b	"libraries it uses, requires",0
error1b_3	dc.b	"a later version of Fargo.",0

error1c_1	dc.b	"One or more required",0
error1c_2	dc.b	"libraries were not",0
error1c_3	dc.b	"found or invalid.",0

error1d_1	dc.b	"One of the libraries used",0
error1d_2	dc.b	"by this program seems",0
error1d_3	dc.b	"to be too old.",0

error1e_1	dc.b	"That file is not executable",0

error1f_1	dc.b	"Program quit due to an",0
error1f_2	dc.b	"ER_throw exception.",0

error1g_1	equ	error1b_1
error1g_2	dc.b	"libraries it uses, is",0
error1g_3	dc.b	"incompatible with this",0
error1g_4	dc.b	"version of Fargo.",0

error1h_1	dc.b	"Unrecognized file format",0

error2_1:	dc.b	"There are no Fargo",0
error2_2:	dc.b	"programs inside",0
error2_3:	dc.b	"that folder.",0

keyexit:	dc.b	"Press any key.",0

;*****************************************************
; uninitialized data that doesn't
; persist after the program exits
;*****************************************************
	BSS

old_font	ds.w	1
old_activity	ds.w	1

exec_error	ds.w	1

folder_handle	ds.w	1
proglist_handle	ds.w	1

max_prog	ds.w	1
top_prog	ds.w	1
cur_prog	ds.w	1

folder_mode	ds.b	1
no_test		ds.b	1

	end
