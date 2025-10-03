;----------------------------------------------------------------------------
; on(void)
;
; Function: Activate 4 shade gray scale display
;
; Return: D0.L = nonzero:success, zero=failure
;----------------------------------------------------------------------------
gray4lib::on		equ	gray4lib@0000

;----------------------------------------------------------------------------
; off(void)
;
; Function: Deactivate gray scale display
;
; Return: nothing
;----------------------------------------------------------------------------
gray4lib::off		equ	gray4lib@0001

;----------------------------------------------------------------------------
; plane0: long address of bitplane 0
; plane1: long address of bitplane 1 (always = LCD_MEM)
;----------------------------------------------------------------------------
gray4lib::plane0	equ	gray4lib@0002
gray4lib::plane1	equ	gray4lib@0003
