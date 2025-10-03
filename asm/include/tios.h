;----------------------------------------------------------------------------
; Notes on ROM calls
;----------------------------------------------------------------------------
; Function parameters are listed using the C language calling convention.
; Parameters are pushed onto the stack in reverse order.
;
; To clean up after the function has been called, pop all the values that
; were pushed. This can be done by adding a value to SP; this value is
; calculated by summing the sizes of all the parameters that were pushed.
;
; Unless otherwise specified, assume that D0-D2/A0-A1 are destroyed by any
; given ROM function upon return.
;
; Inside a block of English text, variables will be
; designated with surrounding braces {}.
;----------------------------------------------------------------------------
;  BYTE =  8-bit unsigned integer
;  WORD = 16-bit unsigned integer
;  LONG = 32-bit unsigned integer
; SBYTE =  8-bit signed integer
; SWORD = 16-bit signed integer
; SLONG = 32-bit signed integer
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; ROM_base specifies the beginning address of the ROM image that is
; currently being used. It may most notably be used for ROM dumps.
;----------------------------------------------------------------------------
tios::ROM_base			equ	tios@0025

;============================================================================
; Error functions
;============================================================================

;----------------------------------------------------------------------------
; ER_throwVar(WORD errorNum)
;
; Function: Restores the state previously saved by ER_catch, making
;           D0.W = {errorNum}
;
; Return: Never returns
;----------------------------------------------------------------------------
tios::ER_throwVar		equ	tios@000D
;----------------------------------------------------------------------------
; WORD ER_catch(void *ErrorFrame)
;
; Function: Saves the state in {ErrorFrame}, which is a $38 byte structure.
;           The state consists of the values of A2-A7, D3-D7, and PC. It also
;           records a pointer to the previously saved state, which makes it a
;           linked list / stack.
;
; Return: D0.W = 0
;
; Note: If ER_throw is called later on, it simulates a return from the
;       previously called ER_catch, in which D0.W = the error code. The
;       processor must be in User mode for this to work properly.
;----------------------------------------------------------------------------
tios::ER_catch			equ	tios@0004
;----------------------------------------------------------------------------
; void ER_success(void)
;
; Function: Pops the state previously saved by ER_catch off the stack.
;----------------------------------------------------------------------------
tios::ER_success		equ	tios@0005

;============================================================================
; Error Dialog functions
;============================================================================

;----------------------------------------------------------------------------
; void ERD_dialog(WORD errorNum)
;
; Function: Displays an error dialog box with a message corresponding to the
;           error code {errorNum}.
;----------------------------------------------------------------------------
tios::ERD_dialog		equ	tios@002F

;============================================================================
; Status line functions
;============================================================================

;----------------------------------------------------------------------------
; void ST_busy(WORD mode)
;
; Function: Switches to idle, busy, or paused. This indicator is displayed
;           in the status line. You must call update_status() for the change
;           to appear visually.
;
; mode=0 -> idle
; mode=1 -> busy
; mode=2 -> paused
;----------------------------------------------------------------------------
tios::ST_busy			equ	tios@000C
;----------------------------------------------------------------------------
; void ST_eraseHelp(void)
;
; Function: If the status flags indicate that a help message is being
;           displayed, this function redraws the status line, effectively
;           removing the message.
;----------------------------------------------------------------------------
tios::ST_eraseHelp		equ	tios@0000
;----------------------------------------------------------------------------
; void ST_helpMsg(BYTE *message)
;
; Function: Displays {message} in the status line, also setting a status
;           flag indicating that a message is being displayed.
;----------------------------------------------------------------------------
tios::ST_helpMsg		equ	tios@0001

;============================================================================
; Heap functions
;============================================================================

;----------------------------------------------------------------------------
; void HeapFreeIndir(WORD *handle)
;
; Function: Deletes the allocated memory block {handle} and sets it to zero.
;----------------------------------------------------------------------------
tios::HeapFreeIndir		equ	tios@000B
;----------------------------------------------------------------------------
; void HeapFree(WORD handle)
;
; Function: Deletes the allocated memory block {handle}.
;----------------------------------------------------------------------------
tios::HeapFree			equ	tios@0002
;----------------------------------------------------------------------------
; WORD HeapAlloc(LONG size)
;
; Function: Allocates a memory handle.
;
; Return: success: D0.W = allocated handle
;         failure: D0.L = 0
;----------------------------------------------------------------------------
tios::HeapAlloc			equ	tios@0003
;----------------------------------------------------------------------------
; WORD HeapAllocThrow(LONG size)
;
; Function: Allocates a memory handle, and does an ER_throw(ER_MEMORY) if
;           there's not enough RAM available.
;
; Return: D0.W = allocated handle
;----------------------------------------------------------------------------
tios::HeapAllocThrow		equ	tios@0022
;----------------------------------------------------------------------------
; WORD HeapRealloc(WORD handle, LONG newsize)
;
; Function: Allocates or resizes a memory handle.
;
; Return: D0.W = reallocated handle (successful)
;         D0.L = 0 (unsuccessful)
;
; Note: If {handle} is zero, a new handle will be
;       created. Otherwise, {handle} will be
;       reallocated to the new size.
;----------------------------------------------------------------------------
tios::HeapRealloc		equ	tios@000E

;============================================================================
; OS misc functions
;============================================================================

;----------------------------------------------------------------------------
; void off(void)
;
; Function: Turns the calculator off. Returns when it is turned back on.
;----------------------------------------------------------------------------
tios::off			equ	tios@0043

;----------------------------------------------------------------------------
; void idle(void)
;
; Function: ?
;----------------------------------------------------------------------------
tios::idle			equ	tios@0044

;----------------------------------------------------------------------------
; void OSClearBreak(void)
;
; Function: Clears the Break flag (OSOnBreak).
;----------------------------------------------------------------------------
tios::OSClearBreak		equ	tios@0045

;----------------------------------------------------------------------------
; Boolean OSCheckBreak(void)
;
; Function: Checks if the Break flag (OSOnBreak) is set.
;
; Return: D0.L = zero if clear, nonzero if set
;----------------------------------------------------------------------------
tios::OSCheckBreak		equ	tios@0046

;----------------------------------------------------------------------------
; void OSDisableBreak(void)
;
; Function: Disables Break.
;----------------------------------------------------------------------------
tios::OSDisableBreak		equ	tios@0047

;----------------------------------------------------------------------------
; void OSEnableBreak(void)
;
; Function: Enables Break.
;----------------------------------------------------------------------------
tios::OSEnableBreak		equ	tios@0048

;============================================================================
; Link transfer functions
;============================================================================

;----------------------------------------------------------------------------
; void OSLinkReset(void)
;
; Function: resets the link interface
;----------------------------------------------------------------------------
tios::OSLinkReset		equ	tios@0006
tios::OSLinkOpen		equ	tios@0007
;----------------------------------------------------------------------------
; WORD OSLinkTxQueueInquire(void)
;
; Function: returns the number of free bytes in the link transmit buffer
;
; Return: D0.W = number of bytes
;----------------------------------------------------------------------------
tios::OSLinkTxQueueInquire	equ	tios@0008
;----------------------------------------------------------------------------
; Boolean OSWriteLinkBlock(BYTE *buffer, WORD num)
;
; Function: inserts {num} bytes from {buffer} into link transmit buffer
;
; Return: No error: D0.L = $00000000
;                   A0   = data + num
;         Error:    D0.B = $FF
;                   A0   = data
;
; {num} must be in the range [$01...$80]
;
; Note: An error occurs if {num} is out of range or if there is not enough
;       room in the transmit buffer to insert {num} bytes.
;----------------------------------------------------------------------------
tios::OSWriteLinkBlock		equ	tios@0009
;----------------------------------------------------------------------------
; OSReadLinkBlock(BYTE *buffer, WORD num)
;
; Function: reads at most {num} bytes into {buffer} from link receive buffer
;
; Return:  D0.L = number of bytes read
;          A0 = buffer + (number of bytes read)
;----------------------------------------------------------------------------
tios::OSReadLinkBlock		equ	tios@000A

;============================================================================
; Graphics functions
;============================================================================

;----------------------------------------------------------------------------
; void DrawStr(WORD x, WORD y, BYTE *string, WORD color)
;
; Function: prints {string} at {x,y} with current font
;----------------------------------------------------------------------------
tios::DrawStr			equ	tios@0010
;----------------------------------------------------------------------------
; void DrawCharMask(BYTE ch, WORD x, WORD y, WORD color,
;                 WORD what1, WORD what2, WORD what3)
;
; Function: prints {ch} at {x,y} with current font
;
; {what1} should be set to $00FF.
; {what2} should be set to $0000.
; {what3} should be set to $00FF.
;----------------------------------------------------------------------------
tios::DrawCharMask		equ	tios@0011
;----------------------------------------------------------------------------
; BYTE FontSetSys(BYTE font)
;
; Function: sets the current system font to {font}
;
; Return: D0.B = font before function was called
;----------------------------------------------------------------------------
tios::FontSetSys		equ	tios@0012
;----------------------------------------------------------------------------
; BYTE FontGetSys(void)
;
; Function: returns the current system font
;
; Return: D0.B = current font
;----------------------------------------------------------------------------
tios::FontGetSys		equ	tios@0026

;----------------------------------------------------------------------------
; void DrawTo(WORD x, WORD y)
;
; Function: Draws a line from the graphics cursor to {x,y}, moving the
;           graphics cursor to the new position.
;----------------------------------------------------------------------------
tios::DrawTo			equ	tios@0013

;----------------------------------------------------------------------------
; void LineTo(WORD x, WORD y)
;
; Function: Moves the graphics cursor to {x,y}
;----------------------------------------------------------------------------
tios::LineTo			equ	tios@0014
;----------------------------------------------------------------------------
; PortSet()
;----------------------------------------------------------------------------
tios::PortSet			equ	tios@0015
;----------------------------------------------------------------------------
; PortRestore()
;----------------------------------------------------------------------------
tios::PortRestore		equ	tios@0016

;============================================================================
; Window functions
;============================================================================

;----------------------------------------------------------------------------
; WinActivate(WINDOW *window)
;
; Function: Draws {window} as created by WinOpen()
;
; Return: nothing
;----------------------------------------------------------------------------
tios::WinActivate		equ	tios@0017
;----------------------------------------------------------------------------
; WinClose(WINDOW *window)
;
; Function: Replaces background and frees memory used by {window}
;
; Return: nothing
;----------------------------------------------------------------------------
tios::WinClose			equ	tios@0018
;----------------------------------------------------------------------------
; WinOpen(WINDOW *window, RECT *rect, WORD flags[, BYTE *title])
;
; Function: Creates a window descriptor at {window}.
;
; Return: success: D0.L = nonzero
;         failure: D0.L = zero
;----------------------------------------------------------------------------
tios::WinOpen			equ	tios@0019
;----------------------------------------------------------------------------
; void WinStrXY(WINDOW *window, WORD x, WORD y, BYTE *string)
;
; Function: prints {string} to {window} at {x,y}
;
; Return: nothing
;----------------------------------------------------------------------------
tios::WinStrXY			equ	tios@001A

;============================================================================
; Menu functions
;============================================================================

tios::MenuPopup			equ	tios@001E
tios::MenuBegin			equ	tios@001F
tios::MenuOn			equ	tios@0020

;============================================================================
; Symbol functions
;============================================================================

;----------------------------------------------------------------------------
; SYM_ENTRY *FindSymEntry(HANDLE symlist, BYTE *name)
;
; Function: Finds a symbol called {name} in a symbol list pointed to by
;           the handle {symlist}.
;
; Return: A0.L = pointer to symbol entry, NULL if symbol not found
;
; Note: If you pass {symlist} = FOLDER_LIST_HANDLE, then the function will
;       search for the folder {name}. You may then use the handle from the
;       returned symbol structure to call the function again, this time
;       searching for a variable in that folder.
;----------------------------------------------------------------------------
tios::FindSymEntry		equ	tios@0024

;----------------------------------------------------------------------------
; SYM_ENTRY *DerefSym(HSYM hsym)
;
; Function: Converts an HSYM into a pointer to a SYM_ENTRY structure. An HSYM
;           is a 32-bit number containing a handle in its high word, and a
;           displacement in its low word. Together, these allow a symbol
;           entry to be located. The handle is that of the symbol list, and
;           the displacement is that of the symbol entry within the list.
;
; Return: A0.L = pointer to symbol entry
;
; See also: DEREF_SYM
;----------------------------------------------------------------------------
tios::DerefSym			equ	tios@0041

;----------------------------------------------------------------------------
; HSYM SymFindMain(BYTE *sym_name)
;
; Function: Searchs for the symbol {sym_name} in the folder "main".
;
; Return: D0.L = HSYM corresponding to symbol, zero if symbol not found
;----------------------------------------------------------------------------
tios::SymFindMain		equ	tios@0042

;============================================================================
; Expression stack functions
;============================================================================

;----------------------------------------------------------------------------
; void push_quantum(BYTE quantum)
;
; Function: Pushes a single byte, {quantum}, onto the estack.
;----------------------------------------------------------------------------
tios::push_quantum		equ	tios@002D
;----------------------------------------------------------------------------
; void check_estack_size(WORD displacement)
;
; Function: Checks if there's enough room to push {displacement} bytes onto
;           the estack. If there isn't, it enlarges the estack to make room.
;----------------------------------------------------------------------------
tios::check_estack_size		equ	tios@0030

;============================================================================
; System Font functions and data
;============================================================================

;----------------------------------------------------------------------------
; void *SF_font: Pointer to ROM font table
;
; SF_font+$0000 = small font (height = 5, width = variable)
; SF_font+$0600 = medium font (height = 8, width = 6)
; SF_font+$0E00 = large font (height = 10, width = 8)
;----------------------------------------------------------------------------
tios::SF_font			equ	tios@0021

;============================================================================
; Miscellaneous
;============================================================================

tios::OSAlexOut			equ	tios@002E

;============================================================================
; C library functions
;----------------------------------------------------------------------------
;         int = 16-bit signed integer
;      size_t = 32-bit unsigned integer
;----------------------------------------------------------------------------
;        char =  8-bit signed integer
; short [int] = 16-bit signed integer
;  long [int] = 32-bit signed integer
;============================================================================

;----------------------------------------------------------------------------
; int sprintf(char *buffer, char *format[, argument, ...])
;
; Function: Uses {format} as a template to output a string to {buffer},
;           substituting arguments when '%' is found in {format}.
;
; Return: D0.W = number of bytes output
;
; For an explanation of format specifiers, please see a reference on the
; C programming language.
;----------------------------------------------------------------------------
tios::sprintf			equ	tios@000F
;----------------------------------------------------------------------------
; void vcbprintf(void (*func)(char, void *), void *param, char *format,
;                void *va_list)
;
; Function: Virtual callback printf. Processes {format}, using {va_list} as
;           a pointer to its parameter list, calling {func}(char, {param})
;           to output each character.
;
; For an explanation of format specifiers, please see a reference on the
; C programming language.
;----------------------------------------------------------------------------
tios::vcbprintf			equ	tios@0027
;----------------------------------------------------------------------------
; int strcmp(char *s1, char *s2)
;
; Function: Compares strings {s1} and {s2}.
;
; Return: D0.W < 0  if  s1 < s2
;         D0.W = 0  if  s1 = s2
;         D0.W > 0  if  s1 > s2
;----------------------------------------------------------------------------
tios::strcmp			equ	tios@0023
;----------------------------------------------------------------------------
; size_t strlen(char *s)
;
; Function: Calculates the length of the string {s}, not including the
;           terminating null character.
;
; Return: D0.L = length of string
;----------------------------------------------------------------------------
tios::strlen			equ	tios@0028
;----------------------------------------------------------------------------
; int strncmp(char *s1, char *s2, size_t n)
;
; Function: Compares at most {n} characters of strings {s1} and {s2}.
;
; Return: D0.W < 0  if  s1 < s2
;         D0.W = 0  if  s1 = s2
;         D0.W > 0  if  s1 > s2
;----------------------------------------------------------------------------
tios::strncmp			equ	tios@0029
;----------------------------------------------------------------------------
; char *strncpy(char *dest, char *src, size_t n)
;
; Function: Copies the first {n} characters of string {src} into {dest}. In
;           the case where the length of {src} is less than {n}, the
;           remainder of {dest} will be padded with nulls.
;
; Return: A0 = {dest}
;----------------------------------------------------------------------------
tios::strncpy			equ	tios@002A
;----------------------------------------------------------------------------
; char *strcat(char *dest, char *src)
;
; Function: Appends the {src} string to the {dest} string, overwriting the
;           null character at the end of {dest}, and adding a terminating
;           null character at the end of the new string. The strings may not
;           overlap, and the {dest} string must have enough space for the
;           result.
;
; Return: A0 = {dest}
;----------------------------------------------------------------------------
tios::strcat			equ	tios@002B
;----------------------------------------------------------------------------
; char *strchr(char *s, int c)
;
; Function: Returns a pointer to the first occurrence of the character {c} in
;           the string {s}.
;
; Return: A0 = pointer to first occurence of {c}
;----------------------------------------------------------------------------
tios::strchr			equ	tios@002C
;----------------------------------------------------------------------------
; void *memset(void *s, int c, size_t n)
;
; Function: Fills the first {n} bytes of the memory area pointed to by {s}
;           with the constant byte {c}.
;
; Return: A0 = pointer to the memory area {s}
;----------------------------------------------------------------------------
tios::memset			equ	tios@0032
;----------------------------------------------------------------------------
; int memcmp(void *s1, void *s2, size_t n)
;
; Function: Compares the first {n} bytes of the memory areas {s1} and {s2}.
;
; Return: D0.W < 0  if  s1 < s2
;         D0.W = 0  if  s1 = s2
;         D0.W > 0  if  s1 > s2
;----------------------------------------------------------------------------
tios::memcmp			equ	tios@0033
;----------------------------------------------------------------------------
; void *memcpy(void *dest, void *src, size_t n)
;
; Function: Copies {n} bytes from memory area {src} to memory area {dest}.
;           The memory areas may not overlap. Use memmove() if the memory
;           areas do overlap.
;
; Return: A0 = pointer to the memory area {dest}
;----------------------------------------------------------------------------
tios::memcpy			equ	tios@0034
;----------------------------------------------------------------------------
; void *memmove(void *dest, void *src, size_t n)
;
; Function: Copies {n} bytes from memory area {src} to memory area {dest}.
;           The memory areas may overlap.
;
; Return: A0 = pointer to the memory area {dest}
;----------------------------------------------------------------------------
tios::memmove			equ	tios@0035
;----------------------------------------------------------------------------
; int abs(int x)
;
; Function: Returns the absolute value of {x}.
;
; Return: D0.W = absolute value of {x}
;----------------------------------------------------------------------------
tios::abs			equ	tios@0036
;----------------------------------------------------------------------------
; long int abs(long int x)
;
; Function: Returns the absolute value of {x}.
;
; Return: D0.L = absolute value of {x}
;----------------------------------------------------------------------------
tios::labs			equ	tios@0031
;----------------------------------------------------------------------------
; int rand(void)
;
; Function: Returns a pseudo-random integer between 0 and RAND_MAX, where
;           RAND_MAX is 32767.
;
; Return: D0.W = a value between 0 and RAND_MAX
;----------------------------------------------------------------------------
tios::rand			equ	tios@0037
;----------------------------------------------------------------------------
; void srand(unsigned int seed)
;
; Function: Sets {seed} as the seed for a new sequence of pseudo-random
;           integers to be returned by rand(). These sequences are repeatable
;           by calling srand() with the same seed value.
;----------------------------------------------------------------------------
tios::srand			equ	tios@0038

;============================================================================
; C hidden math functions
;============================================================================

;----------------------------------------------------------------------------
; _du32u32(): 32-bit unsigned division
;
; Input: D0.L = unsigned integer "x"
;        D1.L = unsigned integer "y"
;
; Output: D1.L = y / x
;----------------------------------------------------------------------------
tios::_du32u32			equ	tios@0039
;----------------------------------------------------------------------------
; _ds32s32(): 32-bit signed division
;
; Input: D0.L = signed integer "x"
;        D1.L = signed integer "y"
;
; Output: D1.L = y / x
;----------------------------------------------------------------------------
tios::_ds32s32			equ	tios@003A
;----------------------------------------------------------------------------
; _du16u16(): 16-bit unsigned division
;
; Input: D0.W = unsigned integer "x"
;        D1.W = unsigned integer "y"
;
; Output: D1.W = y / x
;----------------------------------------------------------------------------
tios::_du16u16			equ	tios@003B
;----------------------------------------------------------------------------
; _ds16u16(): 16-bit mixed-sign division
;
; Input: D0.W = signed integer "x"
;        D1.W = unsigned integer "y"
;
; Output: D1.W = y / x
;----------------------------------------------------------------------------
tios::_ds16u16			equ	tios@003C
;----------------------------------------------------------------------------
; _mu32u32(): 32-bit unsigned modulo (remainder of division)
;
; Input: D0.L = unsigned integer "x"
;        D1.L = unsigned integer "y"
;
; Output: D1.L = y % x
;----------------------------------------------------------------------------
tios::_mu32u32			equ	tios@003D
;----------------------------------------------------------------------------
; _ms32s32(): 32-bit signed modulo (remainder of division)
;
; Input: D0.L = signed integer "x"
;        D1.L = signed integer "y"
;
; Output: D1.L = y % x
;----------------------------------------------------------------------------
tios::_ms32s32			equ	tios@003E
;----------------------------------------------------------------------------
; _mu16u16(): 16-bit unsigned modulo (remainder of division)
;
; Input: D0.W = signed integer "x"
;        D1.W = signed integer "y"
;
; Output: D1.W = y % x
;----------------------------------------------------------------------------
tios::_mu16u16			equ	tios@003F
;----------------------------------------------------------------------------
; _ms16u16(): 16-bit mixed-sign modulo (remainder of division)
;
; Input: D0.W = signed integer "x"
;        D1.W = unsigned integer "y"
;
; Output: D1.W = y % x
;----------------------------------------------------------------------------
tios::_ms16u16			equ	tios@0040

;****************************************************************************
; defines

tios::NULL		equ	0
tios::H_NULL		equ	0
tios::RAND_MAX		equ	$7FFF

; codes for ST_busy()
ACTIVITY_IDLE		equ	0
ACTIVITY_BUSY		equ	1
ACTIVITY_PAUSED		equ	2

; codes for ER_throw()
tios::ER_STOP		equ	2
tios::ER_DIMENSION	equ	230
tios::ER_MEMORY		equ	670
tios::ER_MEMORY_DML	equ	810

; tags
tios::UNDEFINED_TAG	equ	$2A
tios::LIST_TAG		equ	$D9
tios::MATRIX_TAG	equ	$DB
tios::END_TAG		equ	$E5

tios::STOF_ESI		equ	$4000
tios::STOF_HESI		equ	$4003

;****************************************************************************
; structures

tios::SYM_ENTRY.name	equ	0	; name of symbol
tios::SYM_ENTRY.flags	equ	8	; flags
tios::SYM_ENTRY.hVal	equ	10	; handle of symbol

;****************************************************************************
; RAM addresses

tios::globals		equ	tios@001C
tios::kb_globals	equ	tios@001B
tios::ST_flags		equ	tios@001D

tios::main_lcd		equ	tios::globals+$0000	; $F00 bytes

tios::OSOnBreak		equ	tios::globals+$0F02	; byte

APD_INIT		equ	tios::globals+$0F10	; long (integer)
APD_TIMER		equ	tios::globals+$0F14	; long (integer)
APD_FLAG		equ	tios::globals+$0F42	; word

LINK_TX_BUF		equ	tios::globals+$0FA8
LINK_RX_BUF		equ	tios::globals+$1030

tios::estack_max_index	equ	tios::globals+$1260
tios::top_estack	equ	tios::globals+$1264

tios::bottom_estack	equ	tios::globals+$126A

tios::NG_code_handle	equ	tios::globals+$1270

tios::ERR_code_handle	equ	tios::globals+$127E

tios::NG_control	equ	tios::globals+$12B6

tios::EV_handler	equ	tios::globals+$1360	; long (pointer)
tios::EV_runningApp	equ	tios::globals+$1364
tios::EV_currentApp	equ	tios::globals+$1366
tios::EV_appA		equ	tios::globals+$1368
tios::EV_appB		equ	tios::globals+$136A

tios::EV_errorCode	equ	tios::globals+$136E

tios::FirstWindow	equ	tios::globals+$1810

tios::CurTE		equ	tios::globals+$184C

tios::GOK_Flag		equ	tios::globals+$18CC

tios::Heap		equ	tios::globals+$1902	; long (pointer)

tios::SymTempFolCount	equ	tios::globals+$1940	; word (integer)

FOLDER_LIST_HANDLE	equ	tios::globals+$194C	; word (handle)

tios::DefTempHandle	equ	tios::globals+$1950	; word (handle)

STATUS_LINE		equ	tios::ST_flags		; long

;****************************************************************************
; useful macros

;----------------------------------------------------------------------------
; DEREF
;
; Usage: tios::DEREF Dn,An
;
; {Dn} can be any data register; {An} can be any address register.
;
; This will find the pointer corresponding to the handle {Dn}, and store it
; in {An}. The previous value of {Dn} is destroyed.
;----------------------------------------------------------------------------
tios::DEREF	macro	; Dn,An
	lsl.w	#2,\1
	move.l	tios::Heap,\2
	move.l	0(\2,\1.w),\2
		endm

;----------------------------------------------------------------------------
; DEREF_SYM
;
; Usage: tios::DEREF_SYM Dn
;
; {Dn} can be any data register.
;
; This will convert an HSYM into a pointer to a SYM_ENTRY structure. {Dn} is
; the 32-bit HSYM, and the pointer to the SYM_ENTRY is stored in A0. The
; previous values of the registers D0 and D1 are destroyed. See DerefSym()
; for more information.
;----------------------------------------------------------------------------
tios::DEREF_SYM	macro	; Dn
	move.l	\1,-(sp)
	jsr	tios::DerefSym
	add.l	#4,sp
		endm

;----------------------------------------------------------------------------
; ER_throw
;
; Usage: tios::ER_throw {num}
;
; This does the same thing as ER_throwVar(num), but is faster and can only
; take constant values.
;----------------------------------------------------------------------------
tios::ER_throw	macro
	dc.w	$A000+\1
		endm

;****************************************************************************
; Compatibility

LCD_MEM			equ	tios::main_lcd
tios::kb_vars		equ	tios::kb_globals

tios::ST_showHelp	equ	tios::ST_helpMsg
tios::MoveTo		equ	tios::LineTo
tios::reset_link	equ	tios::OSLinkReset
tios::flush_link	equ	tios::OSLinkOpen
tios::receive		equ	tios::OSReadLinkBlock
tios::transmit		equ	tios::OSWriteLinkBlock
tios::tx_free		equ	tios::OSLinkTxQueueInquire
tios::_rs16u16		equ	tios::_ms16u16
tios::_ru16u16		equ	tios::_mu16u16
tios::_rs32s32		equ	tios::_ms32s32
tios::_ru32u32		equ	tios::_mu32u32
tios::DrawStrXY		equ	tios::DrawStr
tios::DrawCharXY	equ	tios::DrawCharMask

;****************************************************************************
