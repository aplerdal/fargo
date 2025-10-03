;****************************************************************************
; memory addresses

LCD_MEM			EQU	$4440

BREAK_FLAG		EQU	$5342	; byte

APD_TIMER		EQU	$5354	; long
APD_FLAG		EQU	$5382	; word

HANDLE_TABLE_PTR	EQU	$5D42	; long pointer

STATUS_LINE		EQU	$761C	; long

;****************************************************************************
; codes for set_activity()

ACTIVITY_IDLE		EQU	0
ACTIVITY_BUSY		EQU	1
ACTIVITY_PAUSED		EQU	2

;****************************************************************************
; useful macros

DEREF	macro	; Dn,An
	lsl.w	#2,\1
	move.l	HANDLE_TABLE_PTR,\2
	move.l	0(\2,\1.w),\2
	endm

handle_ptr	macro
	DEREF	\1,\2
		endm

;****************************************************************************
; equates

FARGO_VER	EQU	'10'
PROGRAM_SIG	EQU	'P'*$10000+FARGO_VER
LIBRARY_SIG	EQU	'L'*$10000+FARGO_VER

;****************************************************************************
; symbol indexing macros

index_lib_sym	macro
		xdef	_label[\2]
		xdef	_label[\2].index
_label[\2].index equ	num_sym
_??\2		equ	num_sym*2
num_sym		set	num_sym+1
		endm

index_library	macro
num_sym		set	0
	\1.sym	< index_lib_sym \1>
		endm

label		macro
	dc.w	_??\1
_label[\1]:
\1:
		endm

reloc_open	macro
		endm

add_lib_syms	macro
		xref	\1[\2]
		xdef	\1[\2].index
\1[\2].index	equ	num_sym
num_sym		set	num_sym+1
		endm

add_library	macro
num_sym		set	0
	\1.sym	< add_lib_syms \1>
		endm

reloc_close     macro
num_sym		set	0
      core.sym	< add_lib_syms core>
                endm
