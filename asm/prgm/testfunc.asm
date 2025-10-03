	include	"tios.h"
	xdef	_main
	xdef	_tibasic

;*****************************************************

_main:
	; make a tiny stack frame for functions that
	; take one word as a parameter
	sub.l	#2,sp

	; Trigger an "Internal error" if we can't find
	; the "x" parameter in our local folder
	pea	param_name(pc)
	move.w	tios::DefTempHandle,-(sp)
	jsr	tios::FindSymEntry
	add.l	#6,sp
	move.l	a0,d0
	bne	no_error
	tios::ER_throw 1020
no_error:
	move.w	10(a0),d0

	; Trigger a "Data type" error if the "x"
	; parameter is not a string
	tios::DEREF d0,a0
check_data_type:
	move.w	(a0),d0
	lea	2(a0,d0.w),a0
	cmp.b	#$2D,-(a0)
	beq	good_data_type
	tios::ER_throw 210
good_data_type:
	sub.l	#1,a0
find_string_loop:
	tst.b	-(a0)
	bne	find_string_loop
	add.l	#1,a0
	move.l	a0,test_args
	move.l	a0,test_args+4

	; Now we will push the return value onto
	; the estack. The return value of this
	; function is "%s=%s", where "%s" is
	; replaced with the string that was
	; passed to the function as a parameter.

	; Mark the beginning of the string
	move.w	#0,(sp)
	jsr	tios::push_quantum

	; Use the callback printf function to
	; do printf("%s=%s", string) and push
	; each outputted char onto the estack
	pea	test_args
	pea	test_format(pc)
	clr.l	-(sp)
	pea	push_char(pc)
	jsr	tios::vcbprintf
	lea	16(sp),sp

	; Mark the end of the string
	move.w	#0,(sp)
	jsr	tios::push_quantum
	; $2D = string tag
	move.w	#$2D,(sp)
	jsr	tios::push_quantum

	; Indicate that there is a return value
	move.b	#2,tios::main_lcd+$126E

	; remove our stack frame
	add.l	#2,sp

	; return to caller
	rts

;*****************************************************

push_char:
	move.w	4(sp),d0
	move.w	d0,-(sp)
	jsr	tios::push_quantum
	add.l	#2,sp
	rts

;*****************************************************

test_format	dc.b	"%s=%s",0

param_name	dc.b	"x",0

;*****************************************************
	bss

test_args:
	dc.l	0
	dc.l	0

;*****************************************************
	section	_tibasic

	dc.b	$E9
	dc.b	$0F,$E4		; EndFunc
	dc.b	$00,$E8		; :
	dc.b	$17,$E4		; Func
	dc.b	$E5,$08		; (x)
	dc.b	$00,$00,$40,$DC

_tibasic
;*****************************************************

	end
