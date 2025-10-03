	include	"tios.h"
	include	"flib.h"
	xdef	_main
	xdef	_comment

MAX_ESC_ARGS	equ	32

;*****************************************************

_main:
	; initialize all terminal information
	clr.b	f0
	clr.b	ascii_code

	jsr	flib::clr_scr

	lea	about_dlog(pc),a6
	jsr	flib::show_dialog
wait_key_1:
	tst.w	tios::kb_globals+$1C
	beq	wait_key_1
	jsr	flib::clear_dialog
	cmp.w	#$010C,tios::kb_globals+$1E
	bne	no_help_1
	clr.w	tios::kb_globals+$1C
show_help_1:
	lea	fhelp_dlog(pc),a6
	jsr	flib::show_dialog
wait_key_2:
	tst.w	tios::kb_globals+$1C
	beq	wait_key_2
	jsr	flib::clear_dialog
no_help_1:
	clr.w	tios::kb_globals+$1C

	move.w	#1,-(sp)		; set font to 1 (8-point)
	jsr	tios::FontSetSys
	add.l	#2,sp
	move.b	d0,save_font		; save original font

	bsr	clear_all

	move.w	#$0700,d0
	trap	#1
	move.l	$64,old_int_1
	bclr.b	#2,$600001
	move.l	#int_1,$64
	bset.b	#2,$600001
	trap	#1

;****************************************************

reset_link:
	jsr	tios::reset_link

idle_loop:
	bclr.b	#f0_caret_busy,f0

	tst.w	LINK_RX_BUF+6
	beq	no_receive
	bset.b	#f0_caret_busy,f0
get_char:
	move.w	#1,-(sp)
	pea	buf_receive
	jsr	tios::receive
	add.l	#6,sp
	move.b	buf_receive,d6
got_char:
	lea	vt_1,a0
	btst.b	#f0_split,f0
	beq	do_receive_echo
	lea	vt_2,a0
do_receive_echo:
	bsr	echo_char
	bra	idle_loop
no_receive:

	tst.w	tios::kb_globals+$1C
	beq	idle_loop
	bset.b	#f0_caret_busy,f0
	move.w	tios::kb_globals+$1E,d6
	clr.w	tios::kb_globals+$1C

	btst.w	#13,d6
	bne	special_key
	cmp.w	#$010B,d6
	beq	reset_link
	cmp.w	#$1108,d6		; 2nd+ESC
	beq	exit
	cmp.w	#$0100,d6		; ASCII character
	bcs	send_char
	cmp.w	#$0101,d6		; Backspace
	beq	key_bs
	cmp.w	#$2101,d6		; Backspace
	beq	key_del
	cmp.w	#$0107,d6		; CLEAR
	beq	key_clear
	cmp.w	#$200D,d6		; Diamond+ENTER
	beq	key_lf
	cmp.w	#$0108,d6		; ESC
	beq	key_esc
	cmp.w	#$010A,d6		; MODE
	beq     toggle_ctrl_mode
	cmp.w	#$0151,d6		; left
	beq	key_left
	cmp.w	#$0152,d6		; up
	beq	key_up
	cmp.w	#$0154,d6		; right
	beq	key_right
	cmp.w	#$0158,d6		; down
	beq	key_down
	bra	idle_loop

;****************************************************

toggle_ctrl_mode:
	bchg.b	#f0_ctrl_mode,f0
	bra	idle_loop

ctrl_key:
	sub.w	#$2040,d6
	bra	send_char

special_key:
	cmp.w	#$202E,d6
	beq	key_dmnd_period
	cmp.w	#$2030,d6
	bcs	key_not_dmnd_num
	cmp.w	#$203A,d6
	bcs	key_dmnd_num
key_not_dmnd_num:

	btst.b	#f0_ctrl_mode,f0
	bne	ctrl_key

	cmp.w	#$2051,d6		; Diamond+Q
	beq	exit
	cmp.w	#$2045,d6		; Diamond+E
	beq	key_dmnd_e
	cmp.w	#$2052,d6		; Diamond+R
	beq	key_dmnd_r
	cmp.w	#$2059,d6		; Diamond+Y
	beq	key_dmnd_y
	bra	idle_loop

;****************************************************

key_bs:
	move.b	#$08,d6
	bra	send_char
key_del:
	move.b	#$7F,d6
	bra	send_char
key_clear:
	move.b	#$0C,d6
	bra	send_char
key_lf:
	move.b	#$0A,d6
	bra	send_char
key_esc:
	move.b	#$1B,d6
	bra	send_char
key_dmnd_e:
	bchg.b	#f0_local_echo,f0
	bra	idle_loop
key_dmnd_r:
	bchg.b	#f0_cr_lf,f0
	bra	idle_loop
key_dmnd_y:
	bchg.b	#f0_split,f0
	bsr	clear_all
	bra	idle_loop
key_dmnd_num:
	move.b	ascii_code,d0
	lsl.b	#1,d0
	move.b	d0,d1
	lsl.b	#2,d1
	add.b	d1,d0
	and.b	#$F,d6
	add.b	d6,d0
	move.b	d0,ascii_code
	bra	idle_loop
key_dmnd_period:
	move.b	ascii_code,d6
	clr.b	ascii_code
	bra	send_char
key_left:
	pea	str_left(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	idle_loop
key_up:
	pea	str_up(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	idle_loop
key_right:
	pea	str_right(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	idle_loop
key_down:
	pea	str_down(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	idle_loop

;****************************************************

exit:
	move.b	save_font,d0
	move.w	d0,-(sp)
	jsr	tios::FontSetSys	; restore original font
	add.w	#2,sp

	move.w	#$0700,d0
	trap	#1
	bclr.b	#2,$600001
	move.l	old_int_1,$64
	bset.b	#2,$600001
	trap	#1

	rts

;****************************************************

send_char:
	jsr	tios::tx_free
	cmp.w	#1,d0			; is there room to send?
	bcs	idle_loop		; no - ignore character
	move.b	d6,buf_transmit		; put character in buffer

	btst.b	#f0_split,f0
	bne	do_local_echo
	btst.b	#f0_local_echo,f0
	beq	send_no_echo
do_local_echo:
	lea	vt_1,a0
	bsr	echo_char
send_no_echo:

	move.w	#1,-(sp)		; set buffer size
	pea	buf_transmit		; set send buffer pointer
	jsr	tios::transmit
	add.l	#$6,sp
	bra	idle_loop

;****************************************************
; xor_caret: toggle caret (text cursor)
;
; input: A0 points to vt struct
;****************************************************
xor_caret:
	movem.l	d0/d4-d5/a6,-(sp)

	move.w	cur_row(a0),d4
	move.w	cur_col(a0),d5

	lsl.w	#3,d4
	add.w	lcd_y_origin(a0),d4

	move.l	#0,d0
	move.w	d4,d0
	lsl.w	#5,d0
	lsl.w	#1,d4
	sub.w	d4,d0

	lsl.w	#1,d5
	move.w	d5,d4
	lsl.w	#1,d4
	add.w	d4,d5

	move.w	d5,d4
	lsr.w	#3,d5
	add.w	d5,d0

	add.l	#LCD_MEM,d0
	move.l	d0,a6

	and.w	#$0007,d4
	move.b	#$C0,d0
	lsr.b	d4,d0

	move.w	#8-1,d5
caret_loop:
	eor.b	d0,(a6)
	lea	30(a6),a6
	dbf.w	d5,caret_loop

	movem.l	(sp)+,d0/d4-d5/a6
	rts

;****************************************************
; printf_link
;****************************************************
printf_link:
	link	a6,#-4
	movem.l	d0-d7/a0-a6,-(sp)

	pea	4+8(a6)
	move.l	0+8(a6),-(sp)
	clr.l	-(sp)
	pea	putchar_link(pc)
	jsr	tios::vcbprintf
	lea	16(sp),sp

	movem.l	(sp)+,d0-d7/a0-a6
	unlk	a6
	rts

putchar_link:
	move.w	d6,-(sp)
	move.b	1+2+4(sp),d6
	btst.b	#f0_local_echo,f0
	beq	putchar_no_echo
	lea	vt_1,a0
	bsr	echo_char
putchar_no_echo:
	move.b	d6,buf_transmit		; put char in buffer
	move.w	#1,-(sp)		; set buffer size
	pea	buf_transmit		; set send buffer pointer
	jsr	tios::transmit		; transmit char
	add.l	#6,sp
	move.w	(sp)+,d6
	rts

;****************************************************
; echo_char: echo a single character to TTY
;
; input: A0 points to vt struct
;        D6.B = character
;****************************************************
echo_char:
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	#$7FFF,cur_timer(a0)
	btst.b	#0,cur_caret(a0)
	beq	echo_no_caret
	bclr.b	#0,cur_caret(a0)
	bsr	xor_caret
echo_no_caret:

	move.w	cur_row(a0),d4
	move.w	cur_col(a0),d5

	tst.b	esc_state(a0)
	bne	echo_esc

	move.l	#0,d0
	move.b	d6,d0
	lsl.w	#1,d0
	lea	echo_table(pc),a6
	move.w	0(a6,d0.w),d0
	jmp	echo_base(pc,d0.w)
echo_base:

echo_normal:
	bsr	put_char
	add.w	#1,d5			; increment column

update_pos_xy:
	cmp.w	num_cols(a0),d5
	bne	update_pos_y
	clr.w	d5
	add.w	#1,d4

update_pos_y:
	cmp.w	num_rows(a0),d4
	bcs	echo_update
	bsr	scroll_up
	sub.w	#1,d4

echo_update:
	move.w	d4,cur_row(a0)
	move.w	d5,cur_col(a0)

echo_done:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;****************************************************

echo_cr:
	clr.w	d5
	btst.b	#f0_cr_lf,f0
	beq	update_pos_y
	add.w	#1,d4
	bra	update_pos_y

echo_lf:
	add.w	#1,d4
	bra	update_pos_y

echo_bs:
	sub.w	#1,d5
	bcs	echo_done
	bra	echo_update

echo_ff:
	bsr	clear_vt
	clr.l	cur_pos(a0)
	bra	echo_done

;****************************************************

echo_esc_prefix:
	move.b	#1,esc_state(a0)
	bra	echo_done

echo_esc:
	cmp.b	#1,esc_state(a0)
	bne	echo_esc[

	clr.b	esc_state(a0)
	cmp.b	#$1B,d6
	beq	echo_update
	cmp.b	#'[',d6
	beq	echo_esc[_prefix
	cmp.b	#'H',d6
	beq	echo_esc_H
	cmp.b	#'c',d6
	beq	echo_reset
	bra	echo_normal

echo_esc[_prefix:
	move.b	#2,esc_state(a0)
	clr.w	esc_arg_state(a0)
	bra	echo_done

echo_esc[:
	cmp.b	#';',d6
	beq	echo_esc[_sep
	cmp.b	#'?',d6
	beq	echo_done
	cmp.b	#'0',d6
	bcs	echo_esc_finish
	cmp.b	#'9',d6
	bhi	echo_esc_finish

echo_esc[_num:
	sub.b	#'0',d6
	move.b	esc_cur_arg(a0),d0
	lsl.b	#1,d0
	move.b	d0,d1
	lsl.b	#2,d1
	add.b	d1,d0
	add.b	d6,d0
	move.b	d0,esc_cur_arg(a0)
	bra	echo_done

echo_esc[_sep:
	bsr	add_esc_arg
	clr.b	esc_cur_arg(a0)
	bra	echo_done

echo_esc_finish:
	bsr	add_esc_arg
	clr.b	esc_state(a0)
	cmp.b	#'A',d6
	beq	echo_esc[A
	cmp.b	#'B',d6
	beq	echo_esc[B
	cmp.b	#'C',d6
	beq	echo_esc[C
	cmp.b	#'D',d6
	beq	echo_esc[D
	cmp.b	#'H',d6
	beq	echo_esc[H
	cmp.b	#'f',d6
	beq	echo_esc[H
	cmp.b	#'J',d6
	beq	echo_esc[J
	cmp.b	#'K',d6
	beq	echo_esc[K
	cmp.b	#'g',d6
	beq	echo_esc[g
	cmp.b	#'n',d6
	beq	echo_esc[n
	cmp.b	#'c',d6
	beq	echo_esc[c
	bra	echo_done

;****************************************************

echo_reset:
	bsr	clear_vt
	bsr	reset_vt
	bra	echo_done

;----------------------------------------------------

echo_tab:
	move.w	num_cols(a0),d0
_find_tab:
	add.w	#1,d5
	cmp.w	d0,d5
	beq	echo_done
	tst.b	tabs(a0,d5.w)
	beq	_find_tab
	bra	echo_update

;----------------------------------------------------

echo_esc_H:
	st.b	tabs(a0,d5.w)
	bra	echo_done

;----------------------------------------------------

echo_esc[g:
	move.b	esc_args+0(a0),d0
	bne	_tab_3?
	clr.b	tabs(a0,d5.w)
	bra	echo_done
_tab_3?:
	cmp.b	#3,d0
	bne	echo_done

	move.w	num_cols(a0),d0
	lsr.w	#2,d0
	sub.w	#1,d0
	lea	tabs(a0),a1
	move.l	#0,d6
_clr_tabs:
	move.l	d6,(a1)+
	dbf.w	d0,_clr_tabs

	bra	echo_done

;----------------------------------------------------

echo_esc[A:
	clr.w	d1
	bsr	default_arg
	sub.w	d0,d4
	bcc	echo_update
	clr.w	d4
	bra	echo_update

;----------------------------------------------------

echo_esc[B:
	clr.w	d1
	bsr	default_arg
	add.w	d0,d4
	move.w	num_rows(a0),d0
	cmp.w	d0,d4
	bcs	echo_update
	move.w	d0,d4
	sub.w	#1,d4
	bra	echo_update

;----------------------------------------------------

echo_esc[C:
	clr.w	d1
	bsr	default_arg
	add.w	d0,d5
	move.w	num_cols(a0),d0
	cmp.w	d0,d5
	bcs	echo_update
	move.w	d0,d5
	sub.w	#1,d5
	bra	echo_update

;----------------------------------------------------

echo_esc[D:
	clr.w	d1
	bsr	default_arg
	sub.w	d0,d5
	bcc	echo_update
	clr.w	d5
	bra	echo_update

;----------------------------------------------------

echo_esc[H:
	clr.w	d1
	bsr	default_arg
	move.w	d0,d4
	move.w	num_rows(a0),d0
	cmp.w	d0,d4
	bls	_home_a
	move.w	d0,d4
_home_a:
	move.w	#1,d1
	bsr	default_arg
	move.w	d0,d5
	move.w	num_cols(a0),d0
	cmp.w	d0,d5
	bls	_home_b
	move.w	d0,d5
_home_b:
	sub.w	#1,d4
	sub.w	#1,d5
	bra	echo_update

;----------------------------------------------------

echo_esc[J:
	move.b	esc_args+0(a0),d0
	tst.b	d0
	beq	clr_scr_0
	cmp.b	#1,d0
	beq	clr_scr_1
	cmp.b	#2,d0
	bne	echo_done

clr_scr_2:
	bsr	clear_vt
	bra	echo_done

clr_scr_0:
	bsr	get_row_addr
	add.l	#LCD_MEM,d1

	move.l	#0,d7
	move.w	num_rows(a0),d6
	sub.w	d4,d6
	sub.w	#1,d6

	move.w	d6,d0
	lsl.w	#6,d0
	lsl.w	#2,d6
	sub.w	d6,d0

	sub.w	#1,d0
	move.l	d1,a1
	lea	30*8(a1),a1
	move.l	#0,d6
_scr_clr_0:
	move.l	d6,(a1)+
	dbf.w	d0,_scr_clr_0

	bra	clr_line_0

clr_scr_1:
	move.l	#0,d7
	move.w	lcd_y_origin(a0),d6
	move.w	d6,d7
	lsl.w	#5,d7
	lsl.w	#1,d6
	sub.w	d6,d7
	add.l	#LCD_MEM,d7
	move.l	d7,a1

	bsr	get_row_addr
	move.w	d1,d0
	lsr.w	#2,d0
	sub.w	#1,d0

	move.l	#0,d6
_scr_clr_1:
	move.l	d6,(a1)+
	dbf.w	d0,_scr_clr_1

	add.l	#LCD_MEM,d1
	bra	clr_line_1

;----------------------------------------------------

echo_esc[K:
	bsr	get_row_addr
	add.l	#LCD_MEM,d1

	move.b	esc_args+0(a0),d0
	tst.b	d0
	beq	clr_line_0
	cmp.b	#1,d0
	beq	clr_line_1
	cmp.b	#2,d0
	bne	echo_done

clr_line_2:
	move.l	d1,a1
	move.w	#30*8/4-1,d0
	move.l	#0,d6
_line_clear_2:
	move.l	d6,(a1)+
	dbf.w	d0,_line_clear_2
	bra	echo_done

clr_line_0:
	lsl.w	#1,d5
	move.w	d5,d0
	lsl.w	#1,d0
	add.w	d0,d5

	move.w	d5,d0
	lsr.w	#3,d0
	and.w	#-2,d0
	add.w	d0,d1
	move.l	d1,a1

	and.w	#$000F,d5
	move.w	#$FFFF,d6
	lsr.w	d5,d6
	not.w	d6
	and.w	d6,7*30(a1)
	and.w	d6,6*30(a1)
	and.w	d6,5*30(a1)
	and.w	d6,4*30(a1)
	and.w	d6,3*30(a1)
	and.w	d6,2*30(a1)
	and.w	d6,1*30(a1)
	and.w	d6,(a1)+

	clr.w	d6
_line_clear_0:
	add.w	#2,d0
	cmp.w	#30,d0
	beq	echo_done
	move.w	d6,7*30(a1)
	move.w	d6,6*30(a1)
	move.w	d6,5*30(a1)
	move.w	d6,4*30(a1)
	move.w	d6,3*30(a1)
	move.w	d6,2*30(a1)
	move.w	d6,1*30(a1)
	move.w	d6,(a1)+
	bra	_line_clear_0

clr_line_1:
	add.w	#1,d5

	lsl.w	#1,d5
	move.w	d5,d0
	lsl.w	#1,d0
	add.w	d0,d5

	move.w	d5,d0
	lsr.w	#3,d0
	and.w	#-2,d0
	add.w	d0,d1
	move.l	d1,a1

	and.w	#$000F,d5
	move.w	#$FFFF,d6
	lsr.w	d5,d6
	and.w	d6,7*30(a1)
	and.w	d6,6*30(a1)
	and.w	d6,5*30(a1)
	and.w	d6,4*30(a1)
	and.w	d6,3*30(a1)
	and.w	d6,2*30(a1)
	and.w	d6,1*30(a1)
	and.w	d6,(a1)

	clr.w	d6
_line_clear_1:
	sub.w	#2,d0
	bcs	echo_done
	move.w	d6,-(a1)
	move.w	d6,1*30(a1)
	move.w	d6,2*30(a1)
	move.w	d6,3*30(a1)
	move.w	d6,4*30(a1)
	move.w	d6,5*30(a1)
	move.w	d6,6*30(a1)
	move.w	d6,7*30(a1)
	bra	_line_clear_1

;----------------------------------------------------

echo_esc[n:
	move.b	esc_args+0(a0),d0
_stat_5?:
	cmp.b	#5,d0
	bne	_stat_6?
	pea	str_2(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	echo_done
_stat_6?:
	cmp.b	#6,d0
	bne	echo_done
	move.w	cur_col(a0),d0
	add.w	#1,d0
	move.w	d0,-(sp)
	move.w	cur_row(a0),d0
	add.w	#1,d0
	move.w	d0,-(sp)
	pea	str_3(pc)
	pea	buf_transmit
	bsr	printf_link
	lea	12(sp),sp
	bra	echo_done

;----------------------------------------------------

echo_esc[c:
	tst.b	esc_args+0(a0)
	bne	echo_done
	pea	str_1(pc)
	bsr	printf_link
	add.l	#4,sp
	bra	echo_done

;****************************************************

add_esc_arg:
	clr.w	d0
	move.b	esc_num_args(a0),d0
	move.b	esc_cur_arg(a0),esc_args(a0,d0.w)
	add.b	#1,d0
	cmp.b	#MAX_ESC_ARGS,d0
	bls	add_esc_arg_under
	moveq	#MAX_ESC_ARGS,d0
add_esc_arg_under:
	move.b	d0,esc_num_args(a0)
	rts

default_arg:
	clr.w	d0
	cmp.b	esc_num_args(a0),d1
	bcc	default_arg_a
	move.b	esc_args(a0,d1.w),d0
default_arg_a:
	tst.b	d0
	bne	default_arg_b
	move.w	#1,d0
default_arg_b:
	rts

;****************************************************

get_row_addr:
	move.w	cur_row(a0),d0
	lsl.w	#3,d0
	add.w	lcd_y_origin(a0),d0
	move.l	#0,d1
	move.w	d0,d1
	lsl.w	#5,d1
	lsl.w	#1,d0
	sub.w	d0,d1
	rts

;*****************************************************
; reset_vt: reset virtual terminal to defaults
;
; input: A0 points to vt struct
;*****************************************************
reset_vt:

	clr.l	cur_pos(a0)
	clr.l	saved_pos(a0)
	clr.w	esc_state(a0)
	clr.w	cur_caret(a0)
	move.w	#$7FFF,cur_timer(a0)

	move.w	num_cols(a0),d0
	lsr.w	#3,d0
	sub.w	#1,d0
	lea	tabs(a0),a1
	move.l	#$FF000000,d6
	move.l	#0,d7
_reset_tabs:
	move.l	d6,(a1)+
	move.l	d7,(a1)+
	dbf.w	d0,_reset_tabs

	rts

;*****************************************************
; put_char: draw character at row,col
;
; input: A0 points to vt struct
;        D4.W = row
;        D5.W = column
;        D6.B = character
;*****************************************************
put_char:
	movem.l	a0/d4-d5,-(sp)

	lsl.w	#3,d4
	add.w	lcd_y_origin(a0),d4

	lsl.w	#1,d5
	move.w	d5,d0
	lsl.w	#1,d0
	add.w	d0,d5

	move.l	#$000000FF,-(sp)
	move.l	#$000400FF,-(sp)
	move.w	d4,-(sp)		; row
	move.w	d5,-(sp)		; col
	move.w	d6,-(sp)		; character
	jsr	tios::DrawCharXY
	lea	$E(sp),sp

	movem.l	(sp)+,a0/d4-d5
	rts

;*****************************************************
; scroll_up: scroll window up
;
; input: A0 points to vt struct
;*****************************************************
scroll_up:
	movem.l	d0-d1/a1-a2,-(sp)

	move.w	lcd_y_origin(a0),d0
	move.l	#0,d1
	move.w	d0,d1
	lsl.w	#5,d1
	lsl.w	#1,d0
	sub.w	d0,d1
	add.l	#LCD_MEM,d1
	move.l	d1,a1

	lea	(30*8)(a1),a2

	move.w	num_rows(a0),d1
	move.w	d1,d0
	lsl.w	#6,d0
	lsl.w	#2,d1
	sub.w	d1,d0
	sub.w	#30*8/4+1,d0

scroll_up_move:
	move.l	(a2)+,(a1)+
	dbf.w	d0,scroll_up_move

	move.w	#30*8/4-1,d0
	move.l	#0,d1
scroll_up_clr:
	move.l	d1,(a1)+
	dbf.w	d0,scroll_up_clr

	movem.l	(sp)+,d0-d1/a1-a2
	rts

;*****************************************************
; clear_vt: clear a virtual terminal
;
; input: A0 points to vt struct
;*****************************************************
clear_vt:
	movem.l	d0-d1/a1,-(sp)

	move.w	lcd_y_origin(a0),d0
	move.l	#0,d1
	move.w	d0,d1
	lsl.w	#5,d1
	lsl.w	#1,d0
	sub.w	d0,d1
	add.l	#LCD_MEM,d1
	move.l	d1,a1

	move.w	num_rows(a0),d1
	move.w	d1,d0
	lsl.w	#6,d0
	lsl.w	#2,d1
	sub.w	d1,d0
	sub.w	#1,d0

	move.l	#0,d1
vid_clear:
	move.l	d1,(a1)+
	dbf.w	d0,vid_clear

	movem.l	(sp)+,d0-d1/a1
	rts

;*****************************************************
; clear_all: clear entire screen
;*****************************************************
clear_all:
	movem.l	d0-d1/a0,-(sp)

	lea	LCD_MEM,a0
	move.w	#(30*120/4-1),d0
	move.l	#0,d1
vid_clear_all:
	move.l	d1,(a0)+
	dbf.w	d0,vid_clear_all

	move.w	#15,vt_1+num_rows
	move.w	#40,vt_1+num_cols
	clr.w	vt_1+lcd_y_origin

	btst.b	#f0_split,f0
	beq	clear_no_split

	lea	(LCD_MEM+59*30),a0
	move.w	#30/2-1,d0
	move.w	#$FFFF,d1
draw_split:
	move.w	d1,(a0)+
	dbf.w	d0,draw_split

	move.w	#7,vt_1+num_rows
	move.w	#7,vt_2+num_rows
	move.w	#40,vt_2+num_cols
	move.w	#63,vt_2+lcd_y_origin

	lea	vt_2,a0
	bsr	reset_vt

clear_no_split:

	lea	vt_1,a0
	bsr	reset_vt

	clr.b	ascii_code

	movem.l	(sp)+,d0-d1/a0
	rts

;*****************************************************
; int_1: auto int 1 handler
;*****************************************************
int_1:
	move.w	#$2700,sr

	btst.b	#f0_caret_busy,f0
	bne	int_1_chain

	move.l	a0,-(sp)

	cmp.w	#200,vt_1+cur_timer
	bcs	no_xor_caret_1
	clr.w	vt_1+cur_timer
	bchg.b	#0,vt_1+cur_caret
	lea	vt_1,a0
	bsr	xor_caret
no_xor_caret_1:

	btst.b	#f0_split,f0
	beq	no_xor_caret_2
	cmp.w	#200,vt_2+cur_timer
	bcs	no_xor_caret_2
	clr.w	vt_2+cur_timer
	bchg.b	#0,vt_2+cur_caret
	lea	vt_2,a0
	bsr	xor_caret
no_xor_caret_2:

	move.l	(sp)+,a0

int_1_chain:
	add.w	#1,vt_1+cur_timer
	add.w	#1,vt_2+cur_timer
	move.l	old_int_1,-(sp)
	rts

;*****************************************************

; vt struct
_offset_	SET	0

num_rows	EQU	_offset_
_offset_	SET	_offset_+2
num_cols	EQU	_offset_
_offset_	SET	_offset_+2

cur_pos		EQU	_offset_
cur_row		EQU	_offset_
_offset_	SET	_offset_+2
cur_col		EQU	_offset_
_offset_	SET	_offset_+2

saved_pos	EQU	_offset_
saved_row	EQU	_offset_
_offset_	SET	_offset_+2
saved_col	EQU	_offset_
_offset_	SET	_offset_+2

tabs		EQU	_offset_
_offset_	SET	_offset_+40

esc_state	EQU	_offset_
_offset_	SET	_offset_+2
esc_arg_state	EQU	_offset_
esc_num_args	EQU	_offset_
_offset_	SET	_offset_+1
esc_cur_arg	EQU	_offset_
_offset_	SET	_offset_+1
esc_args	EQU	_offset_
_offset_	SET	_offset_+MAX_ESC_ARGS

cur_caret	EQU	_offset_
_offset_	SET	_offset_+2
cur_timer	EQU	_offset_
_offset_	SET	_offset_+2
lcd_y_origin	EQU	_offset_
_offset_	SET	_offset_+2

vt_size		EQU	_offset_

;*****************************************************

	EVEN
echo_table:
	dc.w	echo_normal-echo_base	; 00
	dc.w	echo_normal-echo_base	; 01
	dc.w	echo_normal-echo_base	; 02
	dc.w	echo_normal-echo_base	; 03
	dc.w	echo_normal-echo_base	; 04
	dc.w	echo_normal-echo_base	; 05
	dc.w	echo_normal-echo_base	; 06
	dc.w	echo_done-echo_base	; 07
	dc.w	echo_bs-echo_base	; 08
	dc.w	echo_tab-echo_base	; 09
	dc.w	echo_lf-echo_base	; 0A
	dc.w	echo_normal-echo_base	; 0B
	dc.w	echo_ff-echo_base	; 0C
	dc.w	echo_cr-echo_base	; 0D
	dc.w	echo_normal-echo_base	; 0E
	dc.w	echo_normal-echo_base	; 0F
	dc.w	echo_normal-echo_base	; 10
	dc.w	echo_normal-echo_base	; 11
	dc.w	echo_normal-echo_base	; 12
	dc.w	echo_normal-echo_base	; 13
	dc.w	echo_normal-echo_base	; 14
	dc.w	echo_normal-echo_base	; 15
	dc.w	echo_normal-echo_base	; 16
	dc.w	echo_normal-echo_base	; 17
	dc.w	echo_normal-echo_base	; 18
	dc.w	echo_normal-echo_base	; 19
	dc.w	echo_normal-echo_base	; 1A
	dc.w	echo_esc_prefix-echo_base; 1B
	dc.w	echo_normal-echo_base	; 1C
	dc.w	echo_normal-echo_base	; 1D
	dc.w	echo_normal-echo_base	; 1E
	dc.w	echo_normal-echo_base	; 1F
	dc.w	echo_normal-echo_base	; 20
	dc.w	echo_normal-echo_base	; 21
	dc.w	echo_normal-echo_base	; 22
	dc.w	echo_normal-echo_base	; 23
	dc.w	echo_normal-echo_base	; 24
	dc.w	echo_normal-echo_base	; 25
	dc.w	echo_normal-echo_base	; 26
	dc.w	echo_normal-echo_base	; 27
	dc.w	echo_normal-echo_base	; 28
	dc.w	echo_normal-echo_base	; 29
	dc.w	echo_normal-echo_base	; 2A
	dc.w	echo_normal-echo_base	; 2B
	dc.w	echo_normal-echo_base	; 2C
	dc.w	echo_normal-echo_base	; 2D
	dc.w	echo_normal-echo_base	; 2E
	dc.w	echo_normal-echo_base	; 2F
	dc.w	echo_normal-echo_base	; 30
	dc.w	echo_normal-echo_base	; 31
	dc.w	echo_normal-echo_base	; 32
	dc.w	echo_normal-echo_base	; 33
	dc.w	echo_normal-echo_base	; 34
	dc.w	echo_normal-echo_base	; 35
	dc.w	echo_normal-echo_base	; 36
	dc.w	echo_normal-echo_base	; 37
	dc.w	echo_normal-echo_base	; 38
	dc.w	echo_normal-echo_base	; 39
	dc.w	echo_normal-echo_base	; 3A
	dc.w	echo_normal-echo_base	; 3B
	dc.w	echo_normal-echo_base	; 3C
	dc.w	echo_normal-echo_base	; 3D
	dc.w	echo_normal-echo_base	; 3E
	dc.w	echo_normal-echo_base	; 3F
	dc.w	echo_normal-echo_base	; 40
	dc.w	echo_normal-echo_base	; 41
	dc.w	echo_normal-echo_base	; 42
	dc.w	echo_normal-echo_base	; 43
	dc.w	echo_normal-echo_base	; 44
	dc.w	echo_normal-echo_base	; 45
	dc.w	echo_normal-echo_base	; 46
	dc.w	echo_normal-echo_base	; 47
	dc.w	echo_normal-echo_base	; 48
	dc.w	echo_normal-echo_base	; 49
	dc.w	echo_normal-echo_base	; 4A
	dc.w	echo_normal-echo_base	; 4B
	dc.w	echo_normal-echo_base	; 4C
	dc.w	echo_normal-echo_base	; 4D
	dc.w	echo_normal-echo_base	; 4E
	dc.w	echo_normal-echo_base	; 4F
	dc.w	echo_normal-echo_base	; 50
	dc.w	echo_normal-echo_base	; 51
	dc.w	echo_normal-echo_base	; 52
	dc.w	echo_normal-echo_base	; 53
	dc.w	echo_normal-echo_base	; 54
	dc.w	echo_normal-echo_base	; 55
	dc.w	echo_normal-echo_base	; 56
	dc.w	echo_normal-echo_base	; 57
	dc.w	echo_normal-echo_base	; 58
	dc.w	echo_normal-echo_base	; 59
	dc.w	echo_normal-echo_base	; 5A
	dc.w	echo_normal-echo_base	; 5B
	dc.w	echo_normal-echo_base	; 5C
	dc.w	echo_normal-echo_base	; 5D
	dc.w	echo_normal-echo_base	; 5E
	dc.w	echo_normal-echo_base	; 5F
	dc.w	echo_normal-echo_base	; 60
	dc.w	echo_normal-echo_base	; 61
	dc.w	echo_normal-echo_base	; 62
	dc.w	echo_normal-echo_base	; 63
	dc.w	echo_normal-echo_base	; 64
	dc.w	echo_normal-echo_base	; 65
	dc.w	echo_normal-echo_base	; 66
	dc.w	echo_normal-echo_base	; 67
	dc.w	echo_normal-echo_base	; 68
	dc.w	echo_normal-echo_base	; 69
	dc.w	echo_normal-echo_base	; 6A
	dc.w	echo_normal-echo_base	; 6B
	dc.w	echo_normal-echo_base	; 6C
	dc.w	echo_normal-echo_base	; 6D
	dc.w	echo_normal-echo_base	; 6E
	dc.w	echo_normal-echo_base	; 6F
	dc.w	echo_normal-echo_base	; 70
	dc.w	echo_normal-echo_base	; 71
	dc.w	echo_normal-echo_base	; 72
	dc.w	echo_normal-echo_base	; 73
	dc.w	echo_normal-echo_base	; 74
	dc.w	echo_normal-echo_base	; 75
	dc.w	echo_normal-echo_base	; 76
	dc.w	echo_normal-echo_base	; 77
	dc.w	echo_normal-echo_base	; 78
	dc.w	echo_normal-echo_base	; 79
	dc.w	echo_normal-echo_base	; 7A
	dc.w	echo_normal-echo_base	; 7B
	dc.w	echo_normal-echo_base	; 7C
	dc.w	echo_normal-echo_base	; 7D
	dc.w	echo_normal-echo_base	; 7E
	dc.w	echo_normal-echo_base	; 7F
	dc.w	echo_normal-echo_base	; 80
	dc.w	echo_normal-echo_base	; 81
	dc.w	echo_normal-echo_base	; 82
	dc.w	echo_normal-echo_base	; 83
	dc.w	echo_normal-echo_base	; 84
	dc.w	echo_normal-echo_base	; 85
	dc.w	echo_normal-echo_base	; 86
	dc.w	echo_normal-echo_base	; 87
	dc.w	echo_normal-echo_base	; 88
	dc.w	echo_normal-echo_base	; 89
	dc.w	echo_normal-echo_base	; 8A
	dc.w	echo_normal-echo_base	; 8B
	dc.w	echo_normal-echo_base	; 8C
	dc.w	echo_normal-echo_base	; 8D
	dc.w	echo_normal-echo_base	; 8E
	dc.w	echo_normal-echo_base	; 8F
	dc.w	echo_normal-echo_base	; 90
	dc.w	echo_normal-echo_base	; 91
	dc.w	echo_normal-echo_base	; 92
	dc.w	echo_normal-echo_base	; 93
	dc.w	echo_normal-echo_base	; 94
	dc.w	echo_normal-echo_base	; 95
	dc.w	echo_normal-echo_base	; 96
	dc.w	echo_normal-echo_base	; 97
	dc.w	echo_normal-echo_base	; 98
	dc.w	echo_normal-echo_base	; 99
	dc.w	echo_normal-echo_base	; 9A
	dc.w	echo_normal-echo_base	; 9B
	dc.w	echo_normal-echo_base	; 9C
	dc.w	echo_normal-echo_base	; 9D
	dc.w	echo_normal-echo_base	; 9E
	dc.w	echo_normal-echo_base	; 9F
	dc.w	echo_normal-echo_base	; A0
	dc.w	echo_normal-echo_base	; A1
	dc.w	echo_normal-echo_base	; A2
	dc.w	echo_normal-echo_base	; A3
	dc.w	echo_normal-echo_base	; A4
	dc.w	echo_normal-echo_base	; A5
	dc.w	echo_normal-echo_base	; A6
	dc.w	echo_normal-echo_base	; A7
	dc.w	echo_normal-echo_base	; A8
	dc.w	echo_normal-echo_base	; A9
	dc.w	echo_normal-echo_base	; AA
	dc.w	echo_normal-echo_base	; AB
	dc.w	echo_normal-echo_base	; AC
	dc.w	echo_normal-echo_base	; AD
	dc.w	echo_normal-echo_base	; AE
	dc.w	echo_normal-echo_base	; AF
	dc.w	echo_normal-echo_base	; B0
	dc.w	echo_normal-echo_base	; B1
	dc.w	echo_normal-echo_base	; B2
	dc.w	echo_normal-echo_base	; B3
	dc.w	echo_normal-echo_base	; B4
	dc.w	echo_normal-echo_base	; B5
	dc.w	echo_normal-echo_base	; B6
	dc.w	echo_normal-echo_base	; B7
	dc.w	echo_normal-echo_base	; B8
	dc.w	echo_normal-echo_base	; B9
	dc.w	echo_normal-echo_base	; BA
	dc.w	echo_normal-echo_base	; BB
	dc.w	echo_normal-echo_base	; BC
	dc.w	echo_normal-echo_base	; BD
	dc.w	echo_normal-echo_base	; BE
	dc.w	echo_normal-echo_base	; BF
	dc.w	echo_normal-echo_base	; C0
	dc.w	echo_normal-echo_base	; C1
	dc.w	echo_normal-echo_base	; C2
	dc.w	echo_normal-echo_base	; C3
	dc.w	echo_normal-echo_base	; C4
	dc.w	echo_normal-echo_base	; C5
	dc.w	echo_normal-echo_base	; C6
	dc.w	echo_normal-echo_base	; C7
	dc.w	echo_normal-echo_base	; C8
	dc.w	echo_normal-echo_base	; C9
	dc.w	echo_normal-echo_base	; CA
	dc.w	echo_normal-echo_base	; CB
	dc.w	echo_normal-echo_base	; CC
	dc.w	echo_normal-echo_base	; CD
	dc.w	echo_normal-echo_base	; CE
	dc.w	echo_normal-echo_base	; CF
	dc.w	echo_normal-echo_base	; D0
	dc.w	echo_normal-echo_base	; D1
	dc.w	echo_normal-echo_base	; D2
	dc.w	echo_normal-echo_base	; D3
	dc.w	echo_normal-echo_base	; D4
	dc.w	echo_normal-echo_base	; D5
	dc.w	echo_normal-echo_base	; D6
	dc.w	echo_normal-echo_base	; D7
	dc.w	echo_normal-echo_base	; D8
	dc.w	echo_normal-echo_base	; D9
	dc.w	echo_normal-echo_base	; DA
	dc.w	echo_normal-echo_base	; DB
	dc.w	echo_normal-echo_base	; DC
	dc.w	echo_normal-echo_base	; DD
	dc.w	echo_normal-echo_base	; DE
	dc.w	echo_normal-echo_base	; DF
	dc.w	echo_normal-echo_base	; E0
	dc.w	echo_normal-echo_base	; E1
	dc.w	echo_normal-echo_base	; E2
	dc.w	echo_normal-echo_base	; E3
	dc.w	echo_normal-echo_base	; E4
	dc.w	echo_normal-echo_base	; E5
	dc.w	echo_normal-echo_base	; E6
	dc.w	echo_normal-echo_base	; E7
	dc.w	echo_normal-echo_base	; E8
	dc.w	echo_normal-echo_base	; E9
	dc.w	echo_normal-echo_base	; EA
	dc.w	echo_normal-echo_base	; EB
	dc.w	echo_normal-echo_base	; EC
	dc.w	echo_normal-echo_base	; ED
	dc.w	echo_normal-echo_base	; EE
	dc.w	echo_normal-echo_base	; EF
	dc.w	echo_normal-echo_base	; F0
	dc.w	echo_normal-echo_base	; F1
	dc.w	echo_normal-echo_base	; F2
	dc.w	echo_normal-echo_base	; F3
	dc.w	echo_normal-echo_base	; F4
	dc.w	echo_normal-echo_base	; F5
	dc.w	echo_normal-echo_base	; F6
	dc.w	echo_normal-echo_base	; F7
	dc.w	echo_normal-echo_base	; F8
	dc.w	echo_normal-echo_base	; F9
	dc.w	echo_normal-echo_base	; FA
	dc.w	echo_normal-echo_base	; FB
	dc.w	echo_normal-echo_base	; FC
	dc.w	echo_normal-echo_base	; FD
	dc.w	echo_normal-echo_base	; FE
	dc.w	echo_normal-echo_base	; FF

str_1		dc.b	$1B,"[?6c",0
str_2		dc.b	$1B,"[0n",0
str_3		dc.b	$1B,"[%d;%dR",0
str_left	dc.b	$1B,"[D",0
str_up		dc.b	$1B,"[A",0
str_right	dc.b	$1B,"[C",0
str_down	dc.b	$1B,"[B",0

	EVEN
about_x1	EQU     026
about_y1	EQU	021
about_xs	EQU     188
about_ys	EQU	085
about_dlog:
	dc.w	about_x1
	dc.w	about_y1
	dc.w	about_x1+about_xs
	dc.w	about_y1+about_ys
	dc.w	about_xs/2-11*4,010
	dc.l	about_1
	dc.w	about_xs/2-21*4,025
	dc.l	about_2
	dc.w	about_xs/2-15*4,040
	dc.l	about_3
	dc.w	about_xs/2-19*4,050
	dc.l	about_4
	dc.w	about_xs/2-17*4,065
	dc.l	about_5
	dc.w	0,0

	EVEN
fhelp_x1	EQU     000
fhelp_y1	EQU	008
fhelp_xs	EQU     240
fhelp_ys	EQU	111
fhelp_dlog:
	dc.w	fhelp_x1
	dc.w	fhelp_y1
	dc.w	fhelp_x1+fhelp_xs
	dc.w	fhelp_y1+fhelp_ys
	dc.w	fhelp_xs/2-10*4,010
	dc.l	fhelp_1
	dc.w	008,025
	dc.l	fhelp_2
	dc.w	008,036
	dc.l	fhelp_3
	dc.w	008,047
	dc.l	fhelp_4
	dc.w	008,058
	dc.l	fhelp_5
	dc.w	008,069
	dc.l	fhelp_6
	dc.w	008,080
	dc.l	fhelp_7
	dc.w	008,091
	dc.l	fhelp_8
	dc.w	0,0

_comment:
about_1:	dc.b	"FTerm 1.0.9",0
about_2:	dc.b	"Copyright ",$A9," 1996-1998",0
about_3:	dc.b	"David Ellsworth",0
about_4:	dc.b	"davidell@ticalc.org",0
about_5:	dc.b	"Press F1 for help",0

fhelp_1:	dc.b	"FTerm Help",0
fhelp_2:	dc.b	$7F,"Q or 2nd-ESC = Quit FTerm",0
fhelp_3:	dc.b	$7F,"E = Toggle Local Echo",0
fhelp_4:	dc.b	$7F,"R = Toggle CR+LF (incoming)",0
fhelp_5:	dc.b	$7F,"Y = Toggle Split Screen",0
fhelp_6:	dc.b	$7F,"ENTER = Line Feed (LF)",0
fhelp_7:	dc.b	$7F,"123. = ASCII 123 (example)",0
fhelp_8:	dc.b	"MODE = toggle ",$7F,"=Ctrl",0

;*****************************************************

f0_local_echo	EQU	0
f0_cr_lf	EQU	1
f0_split	EQU	2
f0_caret_busy	EQU	3
f0_ctrl_mode	EQU	4

;*****************************************************
; uninitialized data that doesn't
; persist after the program exits
;*****************************************************
	BSS

;------------------------------ Word-aligned variables

	EVEN

old_int_1	ds.l	1

vt_1		ds.b	vt_size
vt_2		ds.b	vt_size

;------------------------------- Non-aligned variables

save_font	ds.b	1

buf_transmit	ds.b	11
buf_receive	ds.b	1

ascii_code	ds.b	1

f0		ds.b	1

;*****************************************************

	end
