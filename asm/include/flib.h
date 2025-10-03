flib::FORMAT_LEFT	equ	1
flib::FORMAT_CENTER	equ	2
flib::FORMAT_RIGHT	equ	3

;----------------------------------------------------------------------------
; find_pixel(point p)
;
; Function: Returns the address and bit number of the pixel {p}.
;
; Return: D0.W = bit number
;         A0   = address in video RAM
;                (zero if out of range)
;----------------------------------------------------------------------------
flib::find_pixel	equ	flib@0000

;----------------------------------------------------------------------------
; pixel_on(point p)
;
; Function: Plots a black pixel at {p}
;
; Return: nothing
;----------------------------------------------------------------------------
flib::pixel_on		equ	flib@0001

;----------------------------------------------------------------------------
; pixel_off(point p)
;
; Function: Plots a white pixel at {p}
;
; Return: nothing
;----------------------------------------------------------------------------
flib::pixel_off		equ	flib@0002

;----------------------------------------------------------------------------
; pixel_chg(point p)
;
; Function: Toggles the state of the pixel at {p}
;
; Return: nothing
;----------------------------------------------------------------------------
flib::pixel_chg		equ	flib@0003

;----------------------------------------------------------------------------
; frame_rect(rect r)
;
; Function: Draws the rectangle frame {r}.
;
; Return: nothing
;----------------------------------------------------------------------------
flib::prep_rect		equ	flib@0004

;----------------------------------------------------------------------------
; frame_rect(rect r)
;
; Function: Draws the rectangle frame {r}.
;
; Return: nothing
;----------------------------------------------------------------------------
flib::frame_rect	equ	flib@0005

;----------------------------------------------------------------------------
; erase_rect(rect r)
;
; Function: Fills the rectangle {r} with solid white.
;
; Return: nothing
;----------------------------------------------------------------------------
flib::erase_rect	equ	flib@0006

;----------------------------------------------------------------------------
; show_dialog()
;
; Function: Displays a dialog box.
;
; input: A6=pointer to dialog struct
; output: nothing
;----------------------------------------------------------------------------
flib::show_dialog	equ	flib@0007

;----------------------------------------------------------------------------
; clear_dialog()
;
; Function: Erases the last dialog box drawn by show_dialog(). The area
;           previously under the dialog will need to be redrawn.
;
; input:  nothing
; output: nothing
;----------------------------------------------------------------------------
flib::clear_dialog	equ	flib@0008

;----------------------------------------------------------------------------
; clr_scr(void)
;
; Function: Clears the entire screen, then redraws the dividing line between
;           the top area of the screen and the status line.
;----------------------------------------------------------------------------
flib::clr_scr		equ	flib@0009

;----------------------------------------------------------------------------
; zap_screen(void)
;
; Function: Clears the entire screen -- FAST!
;
; Return: nothing
;----------------------------------------------------------------------------

flib::zap_screen	equ	flib@000A

;----------------------------------------------------------------------------
; idle_loop(void)
;
; Function: Wait for a key press. Diamond-ON will turn off the calculator;
;           any other key will cause the function to return. This function
;           also supports APD (Auto Power Down).
;
; Return: D0.W = getkey code of key pressed
;----------------------------------------------------------------------------
flib::idle_loop		equ	flib@000B

;----------------------------------------------------------------------------
; random(void)
;
; Function: Return a pseudorandom number
;
; input:  D0.W = upper limit
; output: D0.W = random number in [0..limit-1]
;----------------------------------------------------------------------------
flib::random		equ	flib@000C

;----------------------------------------------------------------------------
; WORD rand_seed
;
; Random seed used by random(). You may store values to it to initialize
; the random number seed.
;----------------------------------------------------------------------------
flib::rand_seed		equ	flib@000D
