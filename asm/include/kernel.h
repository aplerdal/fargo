;-----------------------------------------------------------------------------
; exec(int handle)
;
; Function: Execute Fargo program
;
; Return: D1-D7/A0-A6 destroyed
;         If the program was successfully executed, D0.W contains zero upon
;         return. A nonzero value of D0.L indicates failure. The following
;         specific values of D0.L indicate exactly how exec() failed.
;           1 = out of memory
;           2 = Fargo too old; program apparently requires a newer version of
;               Fargo, as it uses reserved flags or header elements
;           3 = required library not found or invalid
;           4 = out-of-range library import; this probably means that the
;               module is trying to use a later version of the library than
;               the one that is present is memory
;           5 = file not executable; is a library, or doesn't have any exports
;           6 = program quit due to ER_throw
;           7 = incompatible Fargo version; program uses an obsolete format,
;               and the kernel doesn't contain a compatibility module which
;               handles the old format
;           8 = incompatible ROM version; only triggered when trying to run
;               Fargo 0.1.x programs
;           9 = unrecognized file format
;-----------------------------------------------------------------------------
kernel::exec		equ	kernel@0000

EXEC_NO_MEM		equ	1
EXEC_FARGO_TOO_OLD	equ	2
EXEC_LIB_NOT_FOUND	equ	3
EXEC_LIB_RANGE_ERR	equ	4
EXEC_NOT_EXEC		equ	5
EXEC_TIOS_ERROR		equ	6
EXEC_INCOMPATIBLE	equ	7
EXEC_INCOMPAT_ROM	equ	8
EXEC_UNKNOWN_FORMAT	equ	9
