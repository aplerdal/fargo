;----------------------------------------------------------------------------
; TIOS pseudolibrary table for Fargo v0.2.8
; by David Ellsworth <davidell@ticalc.org>
;
; You are permitted to modify this file for PERSONAL USE ONLY. You may not
; distribute modified copies of this file.
;
; The purpose of this is to allow you to experiment with new ROM calls,
; especially if you own more than one TI-92 ROM (for example, if you bought
; a modular upgrade). If you find one or more entries that you think should
; be added to the TIOS pseudolibrary, please contact me.
;
; Note that if you are adding entries, you need only add them to the
; listing(s) corresponding to your own ROM(s). I also advise that you take
; care not to release programs which depend on modifications to this file.
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Earlier ROMs were dated in the form: Month DD, YYYY
; Later ROMs are dated in the form: MM/DD/YY
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Version: 1.0b1    Date: September 13, 1995
;----------------------------------------------------------------------------
	section	_tios_1.0b1
	dc.l	$4FBB44
	dc.l	$4FAC38	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAD0E	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C816	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46C894	; tios@0003 = HeapAlloc = create_handle
	dc.l	$401326	; tios@0004 = ER_catch
	dc.l	$40134C	; tios@0005 = ER_success
	dc.l	$4027E8	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40285A	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$4028B2	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4028EC	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402970	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C7FC	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FABFC	; tios@000C = ST_busy = set_activity
	dc.l	$4012FC	; tios@000D = ER_throwVar
	dc.l	$46C9E8	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F026	; tios@000F = sprintf
	dc.l	$462F04	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$46384C	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461990	; tios@0012 = FontSetSys = set_font
	dc.l	$461A58	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461A96	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461AA4	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461AC8	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4643F6	; tios@0017 = WinActivate = draw_window
	dc.l	$46478A	; tios@0018 = WinClose = destroy_window
	dc.l	$464F84	; tios@0019 = WinOpen = create_window
	dc.l	$465796	; tios@001A = WinStrXY = puttext_window
	dc.l	$0075BC	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$007644	; tios@001D = ?ST_flags
	dc.l	$46893C	; tios@001E = MenuPopup
	dc.l	$468B22	; tios@001F = MenuBegin
	dc.l	$468CE0	; tios@0020 = MenuOn
	dc.l	$465C58	; tios@0021 = SF_font
	dc.l	$46C9B8	; tios@0022 = HeapAllocThrow
	dc.l	$4FB684	; tios@0023 = strcmp
	dc.l	$46EC66	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$4619E2	; tios@0026 = FontGetSys
	dc.l	$49E5B8	; tios@0027 = ?vcbprintf
	dc.l	$4FB594	; tios@0028 = strlen
	dc.l	$4FB5AC	; tios@0029 = strncmp
	dc.l	$4FB600	; tios@002A = strncpy
	dc.l	$4FB634	; tios@002B = strcat
	dc.l	$4FB658	; tios@002C = strchr
	dc.l	$431928	; tios@002D = push_quantum
	dc.l	$4FAA34	; tios@002E = OSAlexOut
	dc.l	$4F3686	; tios@002F = ERD_dialog
	dc.l	$431F32	; tios@0030 = check_estack_size
	dc.l	$4FB880	; tios@0031 = labs
	dc.l	$4FB88C	; tios@0032 = memset
	dc.l	$4FB964	; tios@0033 = memcmp
	dc.l	$4FB9AC	; tios@0034 = memcpy
	dc.l	$4FBAE0	; tios@0035 = memmove
	dc.l	$4FBB38	; tios@0036 = abs
	dc.l	$4FB78C	; tios@0037 = rand
	dc.l	$4FB7CE	; tios@0038 = srand
	dc.l	$4FB6A8	; tios@0039 = _du32u32
	dc.l	$4FB6D2	; tios@003A = _ds32s32
	dc.l	$4FB768	; tios@003B = _du16u16
	dc.l	$4FB778	; tios@003C = _ds16u16
	dc.l	$4FB7E4	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB804	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FB858	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FB866	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E1B2	; tios@0041 = DerefSym
	dc.l	$46DAF0	; tios@0042 = SymFindMain
	dc.l	$402542	; tios@0043 = off
	dc.l	$402546	; tios@0044 = idle
	dc.l	$40254E	; tios@0045 = OSClearBreak
	dc.l	$402556	; tios@0046 = OSCheckBreak
	dc.l	$40255E	; tios@0047 = OSDisableBreak
	dc.l	$402564	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.2    Date: October 11, 1995
;----------------------------------------------------------------------------
	section	_tios_1.2
	dc.l	$4FBD0C
	dc.l	$4FAE04	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAEDC	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C53A	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46C5B8	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400F26	; tios@0004 = ER_catch
	dc.l	$400F4C	; tios@0005 = ER_success
	dc.l	$4023E8	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40245A	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$4024B2	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024EC	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402570	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C520	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FADC8	; tios@000C = ST_busy = set_activity
	dc.l	$400EFC	; tios@000D = ER_throwVar
	dc.l	$46C70C	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49EF7E	; tios@000F = sprintf
	dc.l	$462CCC	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463614	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461758	; tios@0012 = FontSetSys = set_font
	dc.l	$461820	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$46185E	; tios@0014 = MoveTo = gr_move_to
	dc.l	$46186C	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461890	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4641BE	; tios@0017 = WinActivate = draw_window
	dc.l	$464552	; tios@0018 = WinClose = destroy_window
	dc.l	$464D4C	; tios@0019 = WinOpen = create_window
	dc.l	$46555E	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$4686D0	; tios@001E = MenuPopup
	dc.l	$4688B6	; tios@001F = MenuBegin
	dc.l	$468A74	; tios@0020 = MenuOn
	dc.l	$465A20	; tios@0021 = SF_font
	dc.l	$46C6DC	; tios@0022 = HeapAllocThrow
	dc.l	$4FB84C	; tios@0023 = strcmp
	dc.l	$46E9B6	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$4617AA	; tios@0026 = FontGetSys
	dc.l	$49E510	; tios@0027 = ?vcbprintf
	dc.l	$4FB75C	; tios@0028 = strlen
	dc.l	$4FB774	; tios@0029 = strncmp
	dc.l	$4FB7C8	; tios@002A = strncpy
	dc.l	$4FB7FC	; tios@002B = strcat
	dc.l	$4FB820	; tios@002C = strchr
	dc.l	$431584	; tios@002D = push_quantum
	dc.l	$4FABFC	; tios@002E = OSAlexOut
	dc.l	$4F3786	; tios@002F = ERD_dialog
	dc.l	$431B8E	; tios@0030 = check_estack_size
	dc.l	$4FBA48	; tios@0031 = labs
	dc.l	$4FBA54	; tios@0032 = memset
	dc.l	$4FBB2C	; tios@0033 = memcmp
	dc.l	$4FBB74	; tios@0034 = memcpy
	dc.l	$4FBCA8	; tios@0035 = memmove
	dc.l	$4FBD00	; tios@0036 = abs
	dc.l	$4FB954	; tios@0037 = rand
	dc.l	$4FB996	; tios@0038 = srand
	dc.l	$4FB870	; tios@0039 = _du32u32
	dc.l	$4FB89A	; tios@003A = _ds32s32
	dc.l	$4FB930	; tios@003B = _du16u16
	dc.l	$4FB940	; tios@003C = _ds16u16
	dc.l	$4FB9AC	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB9CC	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBA20	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBA2E	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46DF02	; tios@0041 = DerefSym
	dc.l	$46D840	; tios@0042 = SymFindMain
	dc.l	$402142	; tios@0043 = off
	dc.l	$402146	; tios@0044 = idle
	dc.l	$40214E	; tios@0045 = OSClearBreak
	dc.l	$402156	; tios@0046 = OSCheckBreak
	dc.l	$40215E	; tios@0047 = OSDisableBreak
	dc.l	$402164	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.3    Date: October 20, 1995
;----------------------------------------------------------------------------
	section	_tios_1.3
	dc.l	$4FBD48
	dc.l	$4FAE40	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAF18	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C55E	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46C5DC	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400F26	; tios@0004 = ER_catch
	dc.l	$400F4C	; tios@0005 = ER_success
	dc.l	$4023EC	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40245E	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$4024B6	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024F0	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402574	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C544	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAE04	; tios@000C = ST_busy = set_activity
	dc.l	$400EFC	; tios@000D = ER_throwVar
	dc.l	$46C730	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49EFA2	; tios@000F = sprintf
	dc.l	$462CD0	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463618	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$46175C	; tios@0012 = FontSetSys = set_font
	dc.l	$461824	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461862	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461870	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461894	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4641C2	; tios@0017 = WinActivate = draw_window
	dc.l	$464556	; tios@0018 = WinClose = destroy_window
	dc.l	$464D50	; tios@0019 = WinOpen = create_window
	dc.l	$465562	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$4686D4	; tios@001E = MenuPopup
	dc.l	$4688BA	; tios@001F = MenuBegin
	dc.l	$468A78	; tios@0020 = MenuOn
	dc.l	$465A24	; tios@0021 = SF_font
	dc.l	$46C700	; tios@0022 = HeapAllocThrow
	dc.l	$4FB888	; tios@0023 = strcmp
	dc.l	$46E9DA	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$4617AE	; tios@0026 = FontGetSys
	dc.l	$49E534	; tios@0027 = ?vcbprintf
	dc.l	$4FB798	; tios@0028 = strlen
	dc.l	$4FB7B0	; tios@0029 = strncmp
	dc.l	$4FB804	; tios@002A = strncpy
	dc.l	$4FB838	; tios@002B = strcat
	dc.l	$4FB85C	; tios@002C = strchr
	dc.l	$431588	; tios@002D = push_quantum
	dc.l	$4FAC38	; tios@002E = OSAlexOut
	dc.l	$4F37AA	; tios@002F = ERD_dialog
	dc.l	$431B92	; tios@0030 = check_estack_size
	dc.l	$4FBA84	; tios@0031 = labs
	dc.l	$4FBA90	; tios@0032 = memset
	dc.l	$4FBB68	; tios@0033 = memcmp
	dc.l	$4FBBB0	; tios@0034 = memcpy
	dc.l	$4FBCE4	; tios@0035 = memmove
	dc.l	$4FBD3C	; tios@0036 = abs
	dc.l	$4FB990	; tios@0037 = rand
	dc.l	$4FB9D2	; tios@0038 = srand
	dc.l	$4FB8AC	; tios@0039 = _du32u32
	dc.l	$4FB8D6	; tios@003A = _ds32s32
	dc.l	$4FB96C	; tios@003B = _du16u16
	dc.l	$4FB97C	; tios@003C = _ds16u16
	dc.l	$4FB9E8	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FBA08	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBA5C	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBA6A	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46DF26	; tios@0041 = DerefSym
	dc.l	$46D864	; tios@0042 = SymFindMain
	dc.l	$402146	; tios@0043 = off
	dc.l	$40214A	; tios@0044 = idle
	dc.l	$402152	; tios@0045 = OSClearBreak
	dc.l	$40215A	; tios@0046 = OSCheckBreak
	dc.l	$402162	; tios@0047 = OSDisableBreak
	dc.l	$402168	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.4    Date: November 17, 1995
;----------------------------------------------------------------------------
	section	_tios_1.4
	dc.l	$4FBE40
	dc.l	$4FAF38	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FB010	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C96E	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46C9EC	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400F26	; tios@0004 = ER_catch
	dc.l	$400F4C	; tios@0005 = ER_success
	dc.l	$4023E0	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402452	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$4024AA	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024E4	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402568	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C954	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAEFC	; tios@000C = ST_busy = set_activity
	dc.l	$400EFC	; tios@000D = ER_throwVar
	dc.l	$46CB40	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F166	; tios@000F = sprintf
	dc.l	$4630E0	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463A28	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461B6C	; tios@0012 = FontSetSys = set_font
	dc.l	$461C34	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461C72	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461C80	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461CA4	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4645D2	; tios@0017 = WinActivate = draw_window
	dc.l	$464966	; tios@0018 = WinClose = destroy_window
	dc.l	$465160	; tios@0019 = WinOpen = create_window
	dc.l	$465972	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468AE4	; tios@001E = MenuPopup
	dc.l	$468CCA	; tios@001F = MenuBegin
	dc.l	$468E88	; tios@0020 = MenuOn
	dc.l	$465E34	; tios@0021 = SF_font
	dc.l	$46CB10	; tios@0022 = HeapAllocThrow
	dc.l	$4FB980	; tios@0023 = strcmp
	dc.l	$46EDEA	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461BBE	; tios@0026 = FontGetSys
	dc.l	$49E6F8	; tios@0027 = ?vcbprintf
	dc.l	$4FB890	; tios@0028 = strlen
	dc.l	$4FB8A8	; tios@0029 = strncmp
	dc.l	$4FB8FC	; tios@002A = strncpy
	dc.l	$4FB930	; tios@002B = strcat
	dc.l	$4FB954	; tios@002C = strchr
	dc.l	$431830	; tios@002D = push_quantum
	dc.l	$4FAD30	; tios@002E = OSAlexOut
	dc.l	$4F390E	; tios@002F = ERD_dialog
	dc.l	$431E3A	; tios@0030 = check_estack_size
	dc.l	$4FBB7C	; tios@0031 = labs
	dc.l	$4FBB88	; tios@0032 = memset
	dc.l	$4FBC60	; tios@0033 = memcmp
	dc.l	$4FBCA8	; tios@0034 = memcpy
	dc.l	$4FBDDC	; tios@0035 = memmove
	dc.l	$4FBE34	; tios@0036 = abs
	dc.l	$4FBA88	; tios@0037 = rand
	dc.l	$4FBACA	; tios@0038 = srand
	dc.l	$4FB9A4	; tios@0039 = _du32u32
	dc.l	$4FB9CE	; tios@003A = _ds32s32
	dc.l	$4FBA64	; tios@003B = _du16u16
	dc.l	$4FBA74	; tios@003C = _ds16u16
	dc.l	$4FBAE0	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FBB00	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBB54	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBB62	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E336	; tios@0041 = DerefSym
	dc.l	$46DC74	; tios@0042 = SymFindMain
	dc.l	$40213A	; tios@0043 = off
	dc.l	$40213E	; tios@0044 = idle
	dc.l	$402146	; tios@0045 = OSClearBreak
	dc.l	$40214E	; tios@0046 = OSCheckBreak
	dc.l	$402156	; tios@0047 = OSDisableBreak
	dc.l	$40215C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.5    Date: 01/02/96
;----------------------------------------------------------------------------
	section	_tios_1.5
	dc.l	$4FBE40
	dc.l	$4FAF40	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FB018	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C8EE	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46C96C	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$402390	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402402	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$40245A	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$402494	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402518	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C8D4	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAF04	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CAC0	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F12A	; tios@000F = sprintf
	dc.l	$46314C	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463A94	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461BD8	; tios@0012 = FontSetSys = set_font
	dc.l	$461CA0	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461CDE	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461CEC	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461D10	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$46463E	; tios@0017 = WinActivate = draw_window
	dc.l	$4649D2	; tios@0018 = WinClose = destroy_window
	dc.l	$465146	; tios@0019 = WinOpen = create_window
	dc.l	$465958	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468A78	; tios@001E = MenuPopup
	dc.l	$468C5E	; tios@001F = MenuBegin
	dc.l	$468E1C	; tios@0020 = MenuOn
	dc.l	$465E1C	; tios@0021 = SF_font
	dc.l	$46CA90	; tios@0022 = HeapAllocThrow
	dc.l	$4FB980	; tios@0023 = strcmp
	dc.l	$46ED62	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461C2A	; tios@0026 = FontGetSys
	dc.l	$49E6BC	; tios@0027 = ?vcbprintf
	dc.l	$4FB890	; tios@0028 = strlen
	dc.l	$4FB8A8	; tios@0029 = strncmp
	dc.l	$4FB8FC	; tios@002A = strncpy
	dc.l	$4FB930	; tios@002B = strcat
	dc.l	$4FB954	; tios@002C = strchr
	dc.l	$4317F8	; tios@002D = push_quantum
	dc.l	$4FAD38	; tios@002E = OSAlexOut
	dc.l	$4F3912	; tios@002F = ERD_dialog
	dc.l	$431E02	; tios@0030 = check_estack_size
	dc.l	$4FBB7C	; tios@0031 = labs
	dc.l	$4FBB88	; tios@0032 = memset
	dc.l	$4FBC60	; tios@0033 = memcmp
	dc.l	$4FBCA8	; tios@0034 = memcpy
	dc.l	$4FBDDC	; tios@0035 = memmove
	dc.l	$4FBE34	; tios@0036 = abs
	dc.l	$4FBA88	; tios@0037 = rand
	dc.l	$4FBACA	; tios@0038 = srand
	dc.l	$4FB9A4	; tios@0039 = _du32u32
	dc.l	$4FB9CE	; tios@003A = _ds32s32
	dc.l	$4FBA64	; tios@003B = _du16u16
	dc.l	$4FBA74	; tios@003C = _ds16u16
	dc.l	$4FBAE0	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FBB00	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBB54	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBB62	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E2B6	; tios@0041 = DerefSym
	dc.l	$46DBF4	; tios@0042 = SymFindMain
	dc.l	$4020EA	; tios@0043 = off
	dc.l	$4020EE	; tios@0044 = idle
	dc.l	$4020F6	; tios@0045 = OSClearBreak
	dc.l	$4020FE	; tios@0046 = OSCheckBreak
	dc.l	$402106	; tios@0047 = OSDisableBreak
	dc.l	$40210C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.7    Date: 01/18/96
;----------------------------------------------------------------------------
	section	_tios_1.7
	dc.l	$4FBDF4
	dc.l	$4FAEF4	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAFCC	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46C9C6	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CA44	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$402390	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402402	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$40245A	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$402494	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402518	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46C9AC	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAEB8	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CB98	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F20E	; tios@000F = sprintf
	dc.l	$463224	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463B6C	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461CB0	; tios@0012 = FontSetSys = set_font
	dc.l	$461D78	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461DB6	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461DC4	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461DE8	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$464716	; tios@0017 = WinActivate = draw_window
	dc.l	$464AAA	; tios@0018 = WinClose = destroy_window
	dc.l	$46521E	; tios@0019 = WinOpen = create_window
	dc.l	$465A30	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468B50	; tios@001E = MenuPopup
	dc.l	$468D36	; tios@001F = MenuBegin
	dc.l	$468EF4	; tios@0020 = MenuOn
	dc.l	$465EF4	; tios@0021 = SF_font
	dc.l	$46CB68	; tios@0022 = HeapAllocThrow
	dc.l	$4FB934	; tios@0023 = strcmp
	dc.l	$46EE3A	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461D02	; tios@0026 = FontGetSys
	dc.l	$49E7A0	; tios@0027 = ?vcbprintf
	dc.l	$4FB844	; tios@0028 = strlen
	dc.l	$4FB85C	; tios@0029 = strncmp
	dc.l	$4FB8B0	; tios@002A = strncpy
	dc.l	$4FB8E4	; tios@002B = strcat
	dc.l	$4FB908	; tios@002C = strchr
	dc.l	$431840	; tios@002D = push_quantum
	dc.l	$4FACEC	; tios@002E = OSAlexOut
	dc.l	$4F38C6	; tios@002F = ERD_dialog
	dc.l	$431E4A	; tios@0030 = check_estack_size
	dc.l	$4FBB30	; tios@0031 = labs
	dc.l	$4FBB3C	; tios@0032 = memset
	dc.l	$4FBC14	; tios@0033 = memcmp
	dc.l	$4FBC5C	; tios@0034 = memcpy
	dc.l	$4FBD90	; tios@0035 = memmove
	dc.l	$4FBDE8	; tios@0036 = abs
	dc.l	$4FBA3C	; tios@0037 = rand
	dc.l	$4FBA7E	; tios@0038 = srand
	dc.l	$4FB958	; tios@0039 = _du32u32
	dc.l	$4FB982	; tios@003A = _ds32s32
	dc.l	$4FBA18	; tios@003B = _du16u16
	dc.l	$4FBA28	; tios@003C = _ds16u16
	dc.l	$4FBA94	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FBAB4	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBB08	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBB16	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E38E	; tios@0041 = DerefSym
	dc.l	$46DCCC	; tios@0042 = SymFindMain
	dc.l	$4020EA	; tios@0043 = off
	dc.l	$4020EE	; tios@0044 = idle
	dc.l	$4020F6	; tios@0045 = OSClearBreak
	dc.l	$4020FE	; tios@0046 = OSCheckBreak
	dc.l	$402106	; tios@0047 = OSDisableBreak
	dc.l	$40210C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.8    Date: 02/28/96
;----------------------------------------------------------------------------
	section	_tios_1.8
	dc.l	$4FBC98
	dc.l	$4FAD98	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAE6E	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46CB26	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CBA4	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A0	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402412	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$40246A	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024A4	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402528	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46CB0C	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAD5C	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CCF8	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F226	; tios@000F = sprintf
	dc.l	$463384	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463CCC	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461E10	; tios@0012 = FontSetSys = set_font
	dc.l	$461ED8	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461F16	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461F24	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461F48	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$464876	; tios@0017 = WinActivate = draw_window
	dc.l	$464C0A	; tios@0018 = WinClose = destroy_window
	dc.l	$46537E	; tios@0019 = WinOpen = create_window
	dc.l	$465B90	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468CB0	; tios@001E = MenuPopup
	dc.l	$468E96	; tios@001F = MenuBegin
	dc.l	$469054	; tios@0020 = MenuOn
	dc.l	$466054	; tios@0021 = SF_font
	dc.l	$46CCC8	; tios@0022 = HeapAllocThrow
	dc.l	$4FB7D8	; tios@0023 = strcmp
	dc.l	$46EF9A	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461E62	; tios@0026 = FontGetSys
	dc.l	$49E7B8	; tios@0027 = ?vcbprintf
	dc.l	$4FB6E8	; tios@0028 = strlen
	dc.l	$4FB700	; tios@0029 = strncmp
	dc.l	$4FB754	; tios@002A = strncpy
	dc.l	$4FB788	; tios@002B = strcat
	dc.l	$4FB7AC	; tios@002C = strchr
	dc.l	$4318FC	; tios@002D = push_quantum
	dc.l	$4FAB90	; tios@002E = OSAlexOut
	dc.l	$4F39F2	; tios@002F = ERD_dialog
	dc.l	$431F06	; tios@0030 = check_estack_size
	dc.l	$4FB9D4	; tios@0031 = labs
	dc.l	$4FB9E0	; tios@0032 = memset
	dc.l	$4FBAB8	; tios@0033 = memcmp
	dc.l	$4FBB00	; tios@0034 = memcpy
	dc.l	$4FBC34	; tios@0035 = memmove
	dc.l	$4FBC8C	; tios@0036 = abs
	dc.l	$4FB8E0	; tios@0037 = rand
	dc.l	$4FB922	; tios@0038 = srand
	dc.l	$4FB7FC	; tios@0039 = _du32u32
	dc.l	$4FB826	; tios@003A = _ds32s32
	dc.l	$4FB8BC	; tios@003B = _du16u16
	dc.l	$4FB8CC	; tios@003C = _ds16u16
	dc.l	$4FB938	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB958	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FB9AC	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FB9BA	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E4EE	; tios@0041 = DerefSym
	dc.l	$46DE2C	; tios@0042 = SymFindMain
	dc.l	$4020FA	; tios@0043 = off
	dc.l	$4020FE	; tios@0044 = idle
	dc.l	$402106	; tios@0045 = OSClearBreak
	dc.l	$40210E	; tios@0046 = OSCheckBreak
	dc.l	$402116	; tios@0047 = OSDisableBreak
	dc.l	$40211C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.10    Date: 03/20/96
;----------------------------------------------------------------------------
	section	_tios_1.10
	dc.l	$4FBCF4
	dc.l	$4FADF4	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAECA	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46CB32	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CBB0	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A0	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402412	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$40246A	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024A4	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402528	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46CB18	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FADB8	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CD04	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F262	; tios@000F = sprintf
	dc.l	$463390	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463CD8	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461E1C	; tios@0012 = FontSetSys = set_font
	dc.l	$461EE4	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461F22	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461F30	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461F54	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$464882	; tios@0017 = WinActivate = draw_window
	dc.l	$464C16	; tios@0018 = WinClose = destroy_window
	dc.l	$46538A	; tios@0019 = WinOpen = create_window
	dc.l	$465B9C	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468CBC	; tios@001E = MenuPopup
	dc.l	$468EA2	; tios@001F = MenuBegin
	dc.l	$469060	; tios@0020 = MenuOn
	dc.l	$466060	; tios@0021 = SF_font
	dc.l	$46CCD4	; tios@0022 = HeapAllocThrow
	dc.l	$4FB834	; tios@0023 = strcmp
	dc.l	$46EFA6	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461E6E	; tios@0026 = FontGetSys
	dc.l	$49E7F4	; tios@0027 = ?vcbprintf
	dc.l	$4FB744	; tios@0028 = strlen
	dc.l	$4FB75C	; tios@0029 = strncmp
	dc.l	$4FB7B0	; tios@002A = strncpy
	dc.l	$4FB7E4	; tios@002B = strcat
	dc.l	$4FB808	; tios@002C = strchr
	dc.l	$431908	; tios@002D = push_quantum
	dc.l	$4FABEC	; tios@002E = OSAlexOut
	dc.l	$4F3A32	; tios@002F = ERD_dialog
	dc.l	$431F12	; tios@0030 = check_estack_size
	dc.l	$4FBA30	; tios@0031 = labs
	dc.l	$4FBA3C	; tios@0032 = memset
	dc.l	$4FBB14	; tios@0033 = memcmp
	dc.l	$4FBB5C	; tios@0034 = memcpy
	dc.l	$4FBC90	; tios@0035 = memmove
	dc.l	$4FBCE8	; tios@0036 = abs
	dc.l	$4FB93C	; tios@0037 = rand
	dc.l	$4FB97E	; tios@0038 = srand
	dc.l	$4FB858	; tios@0039 = _du32u32
	dc.l	$4FB882	; tios@003A = _ds32s32
	dc.l	$4FB918	; tios@003B = _du16u16
	dc.l	$4FB928	; tios@003C = _ds16u16
	dc.l	$4FB994	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB9B4	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBA08	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBA16	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E4FA	; tios@0041 = DerefSym
	dc.l	$46DE38	; tios@0042 = SymFindMain
	dc.l	$4020FA	; tios@0043 = off
	dc.l	$4020FE	; tios@0044 = idle
	dc.l	$402106	; tios@0045 = OSClearBreak
	dc.l	$40210E	; tios@0046 = OSCheckBreak
	dc.l	$402116	; tios@0047 = OSDisableBreak
	dc.l	$40211C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.10    Date: 03/26/96
;----------------------------------------------------------------------------
	section	_tios_1.10
	dc.l	$4FBC5C
	dc.l	$4FAD5C	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAE32	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46CA8E	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CB0C	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A0	; tios@0006 = OSLinkReset = reset_link
	dc.l	$402412	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$40246A	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024A4	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402528	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46CA74	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAD20	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CC60	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F1BE	; tios@000F = sprintf
	dc.l	$4632EC	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463C34	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461D78	; tios@0012 = FontSetSys = set_font
	dc.l	$461E40	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461E7E	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461E8C	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461EB0	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4647DE	; tios@0017 = WinActivate = draw_window
	dc.l	$464B72	; tios@0018 = WinClose = destroy_window
	dc.l	$4652E6	; tios@0019 = WinOpen = create_window
	dc.l	$465AF8	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468C18	; tios@001E = MenuPopup
	dc.l	$468DFE	; tios@001F = MenuBegin
	dc.l	$468FBC	; tios@0020 = MenuOn
	dc.l	$465FBC	; tios@0021 = SF_font
	dc.l	$46CC30	; tios@0022 = HeapAllocThrow
	dc.l	$4FB79C	; tios@0023 = strcmp
	dc.l	$46EF02	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461DCA	; tios@0026 = FontGetSys
	dc.l	$49E750	; tios@0027 = ?vcbprintf
	dc.l	$4FB6AC	; tios@0028 = strlen
	dc.l	$4FB6C4	; tios@0029 = strncmp
	dc.l	$4FB718	; tios@002A = strncpy
	dc.l	$4FB74C	; tios@002B = strcat
	dc.l	$4FB770	; tios@002C = strchr
	dc.l	$4318BC	; tios@002D = push_quantum
	dc.l	$4FAB54	; tios@002E = OSAlexOut
	dc.l	$4F398E	; tios@002F = ERD_dialog
	dc.l	$431EC6	; tios@0030 = check_estack_size
	dc.l	$4FB998	; tios@0031 = labs
	dc.l	$4FB9A4	; tios@0032 = memset
	dc.l	$4FBA7C	; tios@0033 = memcmp
	dc.l	$4FBAC4	; tios@0034 = memcpy
	dc.l	$4FBBF8	; tios@0035 = memmove
	dc.l	$4FBC50	; tios@0036 = abs
	dc.l	$4FB8A4	; tios@0037 = rand
	dc.l	$4FB8E6	; tios@0038 = srand
	dc.l	$4FB7C0	; tios@0039 = _du32u32
	dc.l	$4FB7EA	; tios@003A = _ds32s32
	dc.l	$4FB880	; tios@003B = _du16u16
	dc.l	$4FB890	; tios@003C = _ds16u16
	dc.l	$4FB8FC	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB91C	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FB970	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FB97E	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E456	; tios@0041 = DerefSym
	dc.l	$46DD94	; tios@0042 = SymFindMain
	dc.l	$4020FA	; tios@0043 = off
	dc.l	$4020FE	; tios@0044 = idle
	dc.l	$402106	; tios@0045 = OSClearBreak
	dc.l	$40210E	; tios@0046 = OSCheckBreak
	dc.l	$402116	; tios@0047 = OSDisableBreak
	dc.l	$40211C	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.11    Date: 04/11/96
;----------------------------------------------------------------------------
	section	_tios_1.11
	dc.l	$4FBC64
	dc.l	$4FAD64	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAE3A	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46CA96	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CB14	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A8	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40241A	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$402472	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024AC	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402530	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46CA7C	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FAD28	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CC68	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F1C6	; tios@000F = sprintf
	dc.l	$4632F4	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463C3C	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461D80	; tios@0012 = FontSetSys = set_font
	dc.l	$461E48	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461E86	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461E94	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461EB8	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$4647E6	; tios@0017 = WinActivate = draw_window
	dc.l	$464B7A	; tios@0018 = WinClose = destroy_window
	dc.l	$4652EE	; tios@0019 = WinOpen = create_window
	dc.l	$465B00	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468C20	; tios@001E = MenuPopup
	dc.l	$468E06	; tios@001F = MenuBegin
	dc.l	$468FC4	; tios@0020 = MenuOn
	dc.l	$465FC4	; tios@0021 = SF_font
	dc.l	$46CC38	; tios@0022 = HeapAllocThrow
	dc.l	$4FB7A4	; tios@0023 = strcmp
	dc.l	$46EF0A	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461DD2	; tios@0026 = FontGetSys
	dc.l	$49E758	; tios@0027 = ?vcbprintf
	dc.l	$4FB6B4	; tios@0028 = strlen
	dc.l	$4FB6CC	; tios@0029 = strncmp
	dc.l	$4FB720	; tios@002A = strncpy
	dc.l	$4FB754	; tios@002B = strcat
	dc.l	$4FB778	; tios@002C = strchr
	dc.l	$4318C4	; tios@002D = push_quantum
	dc.l	$4FAB5C	; tios@002E = OSAlexOut
	dc.l	$4F3996	; tios@002F = ERD_dialog
	dc.l	$431ECE	; tios@0030 = check_estack_size
	dc.l	$4FB9A0	; tios@0031 = labs
	dc.l	$4FB9AC	; tios@0032 = memset
	dc.l	$4FBA84	; tios@0033 = memcmp
	dc.l	$4FBACC	; tios@0034 = memcpy
	dc.l	$4FBC00	; tios@0035 = memmove
	dc.l	$4FBC58	; tios@0036 = abs
	dc.l	$4FB8AC	; tios@0037 = rand
	dc.l	$4FB8EE	; tios@0038 = srand
	dc.l	$4FB7C8	; tios@0039 = _du32u32
	dc.l	$4FB7F2	; tios@003A = _ds32s32
	dc.l	$4FB888	; tios@003B = _du16u16
	dc.l	$4FB898	; tios@003C = _ds16u16
	dc.l	$4FB904	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB924	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FB978	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FB986	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E45E	; tios@0041 = DerefSym
	dc.l	$46DD9C	; tios@0042 = SymFindMain
	dc.l	$402102	; tios@0043 = off
	dc.l	$402106	; tios@0044 = idle
	dc.l	$40210E	; tios@0045 = OSClearBreak
	dc.l	$402116	; tios@0046 = OSCheckBreak
	dc.l	$40211E	; tios@0047 = OSDisableBreak
	dc.l	$402124	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 1.12    Date: 05/08/96
;----------------------------------------------------------------------------
	section	_tios_1.12
	dc.l	$4FBD10
	dc.l	$4FAE10	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4FAEE6	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$46CACA	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46CB48	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A8	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40241A	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$402472	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024AC	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402530	; tios@000A = OSReadLinkBlock = receive
	dc.l	$46CAB0	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4FADD4	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$46CC9C	; tios@000E = HeapRealloc = resize_handle
	dc.l	$49F272	; tios@000F = sprintf
	dc.l	$463328	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$463C70	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$461DB4	; tios@0012 = FontSetSys = set_font
	dc.l	$461E7C	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$461EBA	; tios@0014 = MoveTo = gr_move_to
	dc.l	$461EC8	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$461EEC	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$46481A	; tios@0017 = WinActivate = draw_window
	dc.l	$464BAE	; tios@0018 = WinClose = destroy_window
	dc.l	$465322	; tios@0019 = WinOpen = create_window
	dc.l	$465B34	; tios@001A = WinStrXY = puttext_window
	dc.l	$007594	; tios@001B = ? = kb_globals
	dc.l	$004440	; tios@001C = ? = globals
	dc.l	$00761C	; tios@001D = ?ST_flags
	dc.l	$468C54	; tios@001E = MenuPopup
	dc.l	$468E3A	; tios@001F = MenuBegin
	dc.l	$468FF8	; tios@0020 = MenuOn
	dc.l	$465FF8	; tios@0021 = SF_font
	dc.l	$46CC6C	; tios@0022 = HeapAllocThrow
	dc.l	$4FB850	; tios@0023 = strcmp
	dc.l	$46EF3E	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$461E06	; tios@0026 = FontGetSys
	dc.l	$49E804	; tios@0027 = ?vcbprintf
	dc.l	$4FB760	; tios@0028 = strlen
	dc.l	$4FB778	; tios@0029 = strncmp
	dc.l	$4FB7CC	; tios@002A = strncpy
	dc.l	$4FB800	; tios@002B = strcat
	dc.l	$4FB824	; tios@002C = strchr
	dc.l	$4318B8	; tios@002D = push_quantum
	dc.l	$4FAC08	; tios@002E = OSAlexOut
	dc.l	$4F3A42	; tios@002F = ERD_dialog
	dc.l	$431EC2	; tios@0030 = check_estack_size
	dc.l	$4FBA4C	; tios@0031 = labs
	dc.l	$4FBA58	; tios@0032 = memset
	dc.l	$4FBB30	; tios@0033 = memcmp
	dc.l	$4FBB78	; tios@0034 = memcpy
	dc.l	$4FBCAC	; tios@0035 = memmove
	dc.l	$4FBD04	; tios@0036 = abs
	dc.l	$4FB958	; tios@0037 = rand
	dc.l	$4FB99A	; tios@0038 = srand
	dc.l	$4FB874	; tios@0039 = _du32u32
	dc.l	$4FB89E	; tios@003A = _ds32s32
	dc.l	$4FB934	; tios@003B = _du16u16
	dc.l	$4FB944	; tios@003C = _ds16u16
	dc.l	$4FB9B0	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4FB9D0	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4FBA24	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4FBA32	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$46E492	; tios@0041 = DerefSym
	dc.l	$46DDD0	; tios@0042 = SymFindMain
	dc.l	$402102	; tios@0043 = off
	dc.l	$402106	; tios@0044 = idle
	dc.l	$40210E	; tios@0045 = OSClearBreak
	dc.l	$402116	; tios@0046 = OSCheckBreak
	dc.l	$40211E	; tios@0047 = OSDisableBreak
	dc.l	$402124	; tios@0048 = OSEnableBreak

;----------------------------------------------------------------------------
; Version: 2.1    Date: 08/19/96
;----------------------------------------------------------------------------
	section	_tios_2.1
	dc.l	$500000
	dc.l	$4D1204	; tios@0000 = ST_eraseHelp = ST_redraw = update_status
	dc.l	$4D12DC	; tios@0001 = ST_helpMsg = ST_showHelp = ST_message = status_message
	dc.l	$4620FE	; tios@0002 = HeapFree = destroy_handle
	dc.l	$46217C	; tios@0003 = HeapAlloc = create_handle
	dc.l	$400ED6	; tios@0004 = ER_catch
	dc.l	$400EFC	; tios@0005 = ER_success
	dc.l	$4023A8	; tios@0006 = OSLinkReset = reset_link
	dc.l	$40241A	; tios@0007 = OSLinkOpen = flush_link
	dc.l	$402472	; tios@0008 = OSLinkTxQueueInquire = tx_free
	dc.l	$4024AC	; tios@0009 = OSWriteLinkBlock = transmit
	dc.l	$402530	; tios@000A = OSReadLinkBlock = receive
	dc.l	$4620E4	; tios@000B = HeapFreeIndir = dispose_handle
	dc.l	$4D11C8	; tios@000C = ST_busy = set_activity
	dc.l	$400EAC	; tios@000D = ER_throwVar
	dc.l	$4622D6	; tios@000E = HeapRealloc = resize_handle
	dc.l	$483706	; tios@000F = sprintf
	dc.l	$45885C	; tios@0010 = DrawStr = DrawStrXY = puttext
	dc.l	$4591A8	; tios@0011 = DrawCharMask = DrawCharXY = putchar
	dc.l	$4572C8	; tios@0012 = FontSetSys = set_font
	dc.l	$457394	; tios@0013 = LineTo = DrawTo = gr_draw_to
	dc.l	$4573D2	; tios@0014 = MoveTo = gr_move_to
	dc.l	$4573E0	; tios@0015 = PortSet = gr_set_buffer
	dc.l	$457404	; tios@0016 = PortRestore = gr_screen_buffer
	dc.l	$459D66	; tios@0017 = WinActivate = draw_window
	dc.l	$45A102	; tios@0018 = WinClose = destroy_window
	dc.l	$45A88E	; tios@0019 = WinOpen = create_window
	dc.l	$45B0A6	; tios@001A = WinStrXY = puttext_window
	dc.l	$0079A8	; tios@001B = ? = kb_globals
	dc.l	$004720	; tios@001C = ? = globals
	dc.l	$007A60	; tios@001D = ?ST_flags
	dc.l	$45E23C	; tios@001E = MenuPopup
	dc.l	$45E424	; tios@001F = MenuBegin
	dc.l	$45E5E2	; tios@0020 = MenuOn
	dc.l	$45B578	; tios@0021 = SF_font
	dc.l	$4622A6	; tios@0022 = HeapAllocThrow
	dc.l	$4D1C70	; tios@0023 = strcmp
	dc.l	$4645BE	; tios@0024 = ?FindSymEntry
	dc.l	$400000	; tios@0025 = ROM_base
	dc.l	$45731A	; tios@0026 = FontGetSys
	dc.l	$482C90	; tios@0027 = ?vcbprintf
	dc.l	$4D1B80	; tios@0028 = strlen
	dc.l	$4D1B98	; tios@0029 = strncmp
	dc.l	$4D1BEC	; tios@002A = strncpy
	dc.l	$4D1C20	; tios@002B = strcat
	dc.l	$4D1C44	; tios@002C = strchr
	dc.l	$42FD64	; tios@002D = push_quantum
	dc.l	$4D00D0	; tios@002E = OSAlexOut
	dc.l	$4C912A	; tios@002F = ERD_dialog
	dc.l	$430378	; tios@0030 = check_estack_size
	dc.l	$4D1EA8	; tios@0031 = labs
	dc.l	$4D1EB4	; tios@0032 = memset
	dc.l	$4D1F8C	; tios@0033 = memcmp
	dc.l	$4D1FD4	; tios@0034 = memcpy
	dc.l	$4D2108	; tios@0035 = memmove
	dc.l	$4D2160	; tios@0036 = abs
	dc.l	$4D1D78	; tios@0037 = rand
	dc.l	$4D1DBA	; tios@0038 = srand
	dc.l	$4D1C94	; tios@0039 = _du32u32
	dc.l	$4D1CBE	; tios@003A = _ds32s32
	dc.l	$4D1D54	; tios@003B = _du16u16
	dc.l	$4D1D64	; tios@003C = _ds16u16
	dc.l	$4D1DD0	; tios@003D = _mu32u32 = _ru32u32
	dc.l	$4D1DF0	; tios@003E = _ms32s32 = _rs32s32
	dc.l	$4D1E44	; tios@003F = _mu16u16 = _ru16u16
	dc.l	$4D1E52	; tios@0040 = _ms16u16 = _rs16u16
	dc.l	$463AF8	; tios@0041 = DerefSym
	dc.l	$463430	; tios@0042 = SymFindMain
	dc.l	$402102	; tios@0043 = off
	dc.l	$402106	; tios@0044 = idle
	dc.l	$40210E	; tios@0045 = OSClearBreak
	dc.l	$402116	; tios@0046 = OSCheckBreak
	dc.l	$40211E	; tios@0047 = OSDisableBreak
	dc.l	$402124	; tios@0048 = OSEnableBreak

	end
