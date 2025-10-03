const int ROM_exports = 0x0030;
struct {
  char *Version;
  LONG Exports[ROM_exports];
} ROM_table[] = {
  {"1.0b1", {
    0x4FAC38, // tios@0000 = ? = ST_redraw = update_status
    0x4FAD0E, // tios@0001 = ? = ST_message = status_message
    0x46C816, // tios@0002 = HeapFree = destroy_handle
    0x46C894, // tios@0003 = HeapAlloc = create_handle
    0x401326, // tios@0004 = ER_catch
    0x40134C, // tios@0005 = ER_success
    0x4027E8, // tios@0006 = ? = reset_link
    0x40285A, // tios@0007 = ? = flush_link
    0x4028B2, // tios@0008 = ? = tx_free
    0x4028EC, // tios@0009 = ? = transmit
    0x402970, // tios@000A = ? = receive
    0x46C7FC, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FABFC, // tios@000C = ST_busy = set_activity
    0x4012FC, // tios@000D = ER_throwVar
    0x46C9E8, // tios@000E = HeapRealloc = resize_handle
    0x49F026, // tios@000F = sprintf
    0x462F04, // tios@0010 = DrawStrXY = puttext
    0x46384C, // tios@0011 = DrawCharXY = putchar
    0x461990, // tios@0012 = FontSetSys = set_font
    0x461A58, // tios@0013 = ? = MoveTo = gr_draw_to
    0x461A96, // tios@0014 = ? = DrawTo = gr_move_to
    0x461AA4, // tios@0015 = PortSet = gr_set_buffer
    0x461AC8, // tios@0016 = PortRestore = gr_screen_buffer
    0x4643F6, // tios@0017 = WinActivate = draw_window
    0x46478A, // tios@0018 = WinClose = destroy_window
    0x464F84, // tios@0019 = WinOpen = create_window
    0x465796, // tios@001A = WinStrXY = puttext_window
    0x0075BC, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x007644, // tios@001D = ? = ST_flags
    0x46893C, // tios@001E = MenuPopup
    0x468B22, // tios@001F = MenuBegin
    0x468CE0, // tios@0020 = MenuOn
    0x465C58, // tios@0021 = SF_font
    0x46C9B8, // tios@0022 = HeapAllocThrow
    0x4FB684, // tios@0023 = strcmp
    0x46EC66, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x4619E2, // tios@0026 = ? = FontGetSys
    0x49E5B8, // tios@0027 = ? = vcbprintf
    0x4FB594, // tios@0028 = strlen
    0x4FB5AC, // tios@0029 = strncmp
    0x4FB600, // tios@002A = strncpy
    0x4FB634, // tios@002B = strcat
    0x4FB658, // tios@002C = strchr
    0x431928, // tios@002D = push_quantum
    0x4FAA34, // tios@002E = OSAlexOut
    0x4F3686, // tios@002F = ERD_dialog
  }},
  {"1.2", {
    0x4FAE04, // tios@0000 = ? = ST_redraw = update_status
    0x4FAEDC, // tios@0001 = ? = ST_message = status_message
    0x46C53A, // tios@0002 = HeapFree = destroy_handle
    0x46C5B8, // tios@0003 = HeapAlloc = create_handle
    0x400F26, // tios@0004 = ER_catch
    0x400F4C, // tios@0005 = ER_success
    0x4023E8, // tios@0006 = ? = reset_link
    0x40245A, // tios@0007 = ? = flush_link
    0x4024B2, // tios@0008 = ? = tx_free
    0x4024EC, // tios@0009 = ? = transmit
    0x402570, // tios@000A = ? = receive
    0x46C520, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FADC8, // tios@000C = ST_busy = set_activity
    0x400EFC, // tios@000D = ER_throwVar
    0x46C70C, // tios@000E = HeapRealloc = resize_handle
    0x49EF7E, // tios@000F = sprintf
    0x462CCC, // tios@0010 = DrawStrXY = puttext
    0x463614, // tios@0011 = DrawCharXY = putchar
    0x461758, // tios@0012 = FontSetSys = set_font
    0x461820, // tios@0013 = ? = gr_draw_to
    0x46185E, // tios@0014 = ? = gr_move_to
    0x46186C, // tios@0015 = PortSet = gr_set_buffer
    0x461890, // tios@0016 = PortRestore = gr_screen_buffer
    0x4641BE, // tios@0017 = WinActivate = draw_window
    0x464552, // tios@0018 = WinClose = destroy_window
    0x464D4C, // tios@0019 = WinOpen = create_window
    0x46555E, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x4686D0, // tios@001E = MenuPopup
    0x4688B6, // tios@001F = MenuBegin
    0x468A74, // tios@0020 = MenuOn
    0x465A20, // tios@0021 = SF_font
    0x46C6DC, // tios@0022 = HeapAllocThrow
    0x4FB84C, // tios@0023 = strcmp
    0x46E9B6, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x4617AA, // tios@0026 = ? = FontGetSys
    0x49E510, // tios@0027 = ? = vcbprintf
    0x4FB75C, // tios@0028 = strlen
    0x4FB774, // tios@0029 = strncmp
    0x4FB7C8, // tios@002A = strncpy
    0x4FB7FC, // tios@002B = strcat
    0x4FB820, // tios@002C = strchr
    0x431584, // tios@002D = push_quantum
    0x4FABFC, // tios@002E = OSAlexOut
    0x4F3786, // tios@002F = ERD_dialog
  }},
  {"1.3", {
    0x4FAE40, // tios@0000 = ? = ST_redraw = update_status
    0x4FAF18, // tios@0001 = ? = ST_message = status_message
    0x46C55E, // tios@0002 = HeapFree = destroy_handle
    0x46C5DC, // tios@0003 = HeapAlloc = create_handle
    0x400F26, // tios@0004 = ER_catch
    0x400F4C, // tios@0005 = ER_success
    0x4023EC, // tios@0006 = ? = reset_link
    0x40245E, // tios@0007 = ? = flush_link
    0x4024B6, // tios@0008 = ? = tx_free
    0x4024F0, // tios@0009 = ? = transmit
    0x402574, // tios@000A = ? = receive
    0x46C544, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAE04, // tios@000C = ST_busy = set_activity
    0x400EFC, // tios@000D = ER_throwVar
    0x46C730, // tios@000E = HeapRealloc = resize_handle
    0x49EFA2, // tios@000F = sprintf
    0x462CD0, // tios@0010 = DrawStrXY = puttext
    0x463618, // tios@0011 = DrawCharXY = putchar
    0x46175C, // tios@0012 = FontSetSys = set_font
    0x461824, // tios@0013 = ? = gr_draw_to
    0x461862, // tios@0014 = ? = gr_move_to
    0x461870, // tios@0015 = PortSet = gr_set_buffer
    0x461894, // tios@0016 = PortRestore = gr_screen_buffer
    0x4641C2, // tios@0017 = WinActivate = draw_window
    0x464556, // tios@0018 = WinClose = destroy_window
    0x464D50, // tios@0019 = WinOpen = create_window
    0x465562, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x4686D4, // tios@001E = MenuPopup
    0x4688BA, // tios@001F = MenuBegin
    0x468A78, // tios@0020 = MenuOn
    0x465A24, // tios@0021 = SF_font
    0x46C700, // tios@0022 = HeapAllocThrow
    0x4FB888, // tios@0023 = strcmp
    0x46E9DA, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x4617AE, // tios@0026 = ? = FontGetSys
    0x49E534, // tios@0027 = ? = vcbprintf
    0x4FB798, // tios@0028 = strlen
    0x4FB7B0, // tios@0029 = strncmp
    0x4FB804, // tios@002A = strncpy
    0x4FB838, // tios@002B = strcat
    0x4FB85C, // tios@002C = strchr
    0x431588, // tios@002D = push_quantum
    0x4FAC38, // tios@002E = OSAlexOut
    0x4F37AA, // tios@002F = ERD_dialog
  }},
  {"1.4", {
    0x4FAF38, // tios@0000 = ? = ST_redraw = update_status
    0x4FB010, // tios@0001 = ? = ST_message = status_message
    0x46C96E, // tios@0002 = HeapFree = destroy_handle
    0x46C9EC, // tios@0003 = HeapAlloc = create_handle
    0x400F26, // tios@0004 = ER_catch
    0x400F4C, // tios@0005 = ER_success
    0x4023E0, // tios@0006 = ? = reset_link
    0x402452, // tios@0007 = ? = flush_link
    0x4024AA, // tios@0008 = ? = tx_free
    0x4024E4, // tios@0009 = ? = transmit
    0x402568, // tios@000A = ? = receive
    0x46C954, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAEFC, // tios@000C = ST_busy = set_activity
    0x400EFC, // tios@000D = ER_throwVar
    0x46CB40, // tios@000E = HeapRealloc = resize_handle
    0x49F166, // tios@000F = sprintf
    0x4630E0, // tios@0010 = DrawStrXY = puttext
    0x463A28, // tios@0011 = DrawCharXY = putchar
    0x461B6C, // tios@0012 = FontSetSys = set_font
    0x461C34, // tios@0013 = ? = gr_draw_to
    0x461C72, // tios@0014 = ? = gr_move_to
    0x461C80, // tios@0015 = PortSet = gr_set_buffer
    0x461CA4, // tios@0016 = PortRestore = gr_screen_buffer
    0x4645D2, // tios@0017 = WinActivate = draw_window
    0x464966, // tios@0018 = WinClose = destroy_window
    0x465160, // tios@0019 = WinOpen = create_window
    0x465972, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468AE4, // tios@001E = MenuPopup
    0x468CCA, // tios@001F = MenuBegin
    0x468E88, // tios@0020 = MenuOn
    0x465E34, // tios@0021 = SF_font
    0x46CB10, // tios@0022 = HeapAllocThrow
    0x4FB980, // tios@0023 = strcmp
    0x46EDEA, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461BBE, // tios@0026 = ? = FontGetSys
    0x49E6F8, // tios@0027 = ? = vcbprintf
    0x4FB890, // tios@0028 = strlen
    0x4FB8A8, // tios@0029 = strncmp
    0x4FB8FC, // tios@002A = strncpy
    0x4FB930, // tios@002B = strcat
    0x4FB954, // tios@002C = strchr
    0x431830, // tios@002D = push_quantum
    0x4FAD30, // tios@002E = OSAlexOut
    0x4F390E, // tios@002F = ERD_dialog
  }},
  {"1.5", {
    0x4FAF40, // tios@0000 = ? = ST_redraw = update_status
    0x4FB018, // tios@0001 = ? = ST_message = status_message
    0x46C8EE, // tios@0002 = HeapFree = destroy_handle
    0x46C96C, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x402390, // tios@0006 = ? = reset_link
    0x402402, // tios@0007 = ? = flush_link
    0x40245A, // tios@0008 = ? = tx_free
    0x402494, // tios@0009 = ? = transmit
    0x402518, // tios@000A = ? = receive
    0x46C8D4, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAF04, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CAC0, // tios@000E = HeapRealloc = resize_handle
    0x49F12A, // tios@000F = sprintf
    0x46314C, // tios@0010 = DrawStrXY = puttext
    0x463A94, // tios@0011 = DrawCharXY = putchar
    0x461BD8, // tios@0012 = FontSetSys = set_font
    0x461CA0, // tios@0013 = ? = gr_draw_to
    0x461CDE, // tios@0014 = ? = gr_move_to
    0x461CEC, // tios@0015 = PortSet = gr_set_buffer
    0x461D10, // tios@0016 = PortRestore = gr_screen_buffer
    0x46463E, // tios@0017 = WinActivate = draw_window
    0x4649D2, // tios@0018 = WinClose = destroy_window
    0x465146, // tios@0019 = WinOpen = create_window
    0x465958, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468A78, // tios@001E = MenuPopup
    0x468C5E, // tios@001F = MenuBegin
    0x468E1C, // tios@0020 = MenuOn
    0x465E1C, // tios@0021 = SF_font
    0x46CA90, // tios@0022 = HeapAllocThrow
    0x4FB980, // tios@0023 = strcmp
    0x46ED62, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461C2A, // tios@0026 = ? = FontGetSys
    0x49E6BC, // tios@0027 = ? = vcbprintf
    0x4FB890, // tios@0028 = strlen
    0x4FB8A8, // tios@0029 = strncmp
    0x4FB8FC, // tios@002A = strncpy
    0x4FB930, // tios@002B = strcat
    0x4FB954, // tios@002C = strchr
    0x4317F8, // tios@002D = push_quantum
    0x4FAD38, // tios@002E = OSAlexOut
    0x4F3912, // tios@002F = ERD_dialog
  }},
  {"1.7", {
    0x4FAEF4, // tios@0000 = ? = ST_redraw = update_status
    0x4FAFCC, // tios@0001 = ? = ST_message = status_message
    0x46C9C6, // tios@0002 = HeapFree = destroy_handle
    0x46CA44, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x402390, // tios@0006 = ? = reset_link
    0x402402, // tios@0007 = ? = flush_link
    0x40245A, // tios@0008 = ? = tx_free
    0x402494, // tios@0009 = ? = transmit
    0x402518, // tios@000A = ? = receive
    0x46C9AC, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAEB8, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CB98, // tios@000E = HeapRealloc = resize_handle
    0x49F20E, // tios@000F = sprintf
    0x463224, // tios@0010 = DrawStrXY = puttext
    0x463B6C, // tios@0011 = DrawCharXY = putchar
    0x461CB0, // tios@0012 = FontSetSys = set_font
    0x461D78, // tios@0013 = ? = gr_draw_to
    0x461DB6, // tios@0014 = ? = gr_move_to
    0x461DC4, // tios@0015 = PortSet = gr_set_buffer
    0x461DE8, // tios@0016 = PortRestore = gr_screen_buffer
    0x464716, // tios@0017 = WinActivate = draw_window
    0x464AAA, // tios@0018 = WinClose = destroy_window
    0x46521E, // tios@0019 = WinOpen = create_window
    0x465A30, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468B50, // tios@001E = MenuPopup
    0x468D36, // tios@001F = MenuBegin
    0x468EF4, // tios@0020 = MenuOn
    0x465EF4, // tios@0021 = SF_font
    0x46CB68, // tios@0022 = HeapAllocThrow
    0x4FB934, // tios@0023 = strcmp
    0x46EE3A, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461D02, // tios@0026 = ? = FontGetSys
    0x49E7A0, // tios@0027 = ? = vcbprintf
    0x4FB844, // tios@0028 = strlen
    0x4FB85C, // tios@0029 = strncmp
    0x4FB8B0, // tios@002A = strncpy
    0x4FB8E4, // tios@002B = strcat
    0x4FB908, // tios@002C = strchr
    0x431840, // tios@002D = push_quantum
    0x4FACEC, // tios@002E = OSAlexOut
    0x4F38C6, // tios@002F = ERD_dialog
  }},
  {"1.8", {
    0x4FAD98, // tios@0000 = ? = ST_redraw = update_status
    0x4FAE6E, // tios@0001 = ? = ST_message = status_message
    0x46CB26, // tios@0002 = HeapFree = destroy_handle
    0x46CBA4, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x4023A0, // tios@0006 = ? = reset_link
    0x402412, // tios@0007 = ? = flush_link
    0x40246A, // tios@0008 = ? = tx_free
    0x4024A4, // tios@0009 = ? = transmit
    0x402528, // tios@000A = ? = receive
    0x46CB0C, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAD5C, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CCF8, // tios@000E = HeapRealloc = resize_handle
    0x49F226, // tios@000F = sprintf
    0x463384, // tios@0010 = DrawStrXY = puttext
    0x463CCC, // tios@0011 = DrawCharXY = putchar
    0x461E10, // tios@0012 = FontSetSys = set_font
    0x461ED8, // tios@0013 = ? = gr_draw_to
    0x461F16, // tios@0014 = ? = gr_move_to
    0x461F24, // tios@0015 = PortSet = gr_set_buffer
    0x461F48, // tios@0016 = PortRestore = gr_screen_buffer
    0x464876, // tios@0017 = WinActivate = draw_window
    0x464C0A, // tios@0018 = WinClose = destroy_window
    0x46537E, // tios@0019 = WinOpen = create_window
    0x465B90, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468CB0, // tios@001E = MenuPopup
    0x468E96, // tios@001F = MenuBegin
    0x469054, // tios@0020 = MenuOn
    0x466054, // tios@0021 = SF_font
    0x46CCC8, // tios@0022 = HeapAllocThrow
    0x4FB7D8, // tios@0023 = strcmp
    0x46EF9A, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461E62, // tios@0026 = ? = FontGetSys
    0x49E7B8, // tios@0027 = ? = vcbprintf
    0x4FB6E8, // tios@0028 = strlen
    0x4FB700, // tios@0029 = strncmp
    0x4FB754, // tios@002A = strncpy
    0x4FB788, // tios@002B = strcat
    0x4FB7AC, // tios@002C = strchr
    0x4318FC, // tios@002D = push_quantum
    0x4FAB90, // tios@002E = OSAlexOut
    0x4F39F2, // tios@002F = ERD_dialog
  }},
  {"1.10", {
    0x4FADF4, // tios@0000 = ? = ST_redraw = update_status
    0x4FAECA, // tios@0001 = ? = ST_message = status_message
    0x46CB32, // tios@0002 = HeapFree = destroy_handle
    0x46CBB0, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x4023A0, // tios@0006 = ? = reset_link
    0x402412, // tios@0007 = ? = flush_link
    0x40246A, // tios@0008 = ? = tx_free
    0x4024A4, // tios@0009 = ? = transmit
    0x402528, // tios@000A = ? = receive
    0x46CB18, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FADB8, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CD04, // tios@000E = HeapRealloc = resize_handle
    0x49F262, // tios@000F = sprintf
    0x463390, // tios@0010 = DrawStrXY = puttext
    0x463CD8, // tios@0011 = DrawCharXY = putchar
    0x461E1C, // tios@0012 = FontSetSys = set_font
    0x461EE4, // tios@0013 = ? = gr_draw_to
    0x461F22, // tios@0014 = ? = gr_move_to
    0x461F30, // tios@0015 = PortSet = gr_set_buffer
    0x461F54, // tios@0016 = PortRestore = gr_screen_buffer
    0x464882, // tios@0017 = WinActivate = draw_window
    0x464C16, // tios@0018 = WinClose = destroy_window
    0x46538A, // tios@0019 = WinOpen = create_window
    0x465B9C, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468CBC, // tios@001E = MenuPopup
    0x468EA2, // tios@001F = MenuBegin
    0x469060, // tios@0020 = MenuOn
    0x466060, // tios@0021 = SF_font
    0x46CCD4, // tios@0022 = HeapAllocThrow
    0x4FB834, // tios@0023 = strcmp
    0x46EFA6, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461E6E, // tios@0026 = ? = FontGetSys
    0x49E7F4, // tios@0027 = ? = vcbprintf
    0x4FB744, // tios@0028 = strlen
    0x4FB75C, // tios@0029 = strncmp
    0x4FB7B0, // tios@002A = strncpy
    0x4FB7E4, // tios@002B = strcat
    0x4FB808, // tios@002C = strchr
    0x431908, // tios@002D = push_quantum
    0x4FABEC, // tios@002E = OSAlexOut
    0x4F3A32, // tios@002F = ERD_dialog
  }},
  {"1.11", {
    0x4FAD64, // tios@0000 = ? = ST_redraw = update_status
    0x4FAE3A, // tios@0001 = ? = ST_message = status_message
    0x46CA96, // tios@0002 = HeapFree = destroy_handle
    0x46CB14, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x4023A8, // tios@0006 = ? = reset_link
    0x40241A, // tios@0007 = ? = flush_link
    0x402472, // tios@0008 = ? = tx_free
    0x4024AC, // tios@0009 = ? = transmit
    0x402530, // tios@000A = ? = receive
    0x46CA7C, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FAD28, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CC68, // tios@000E = HeapRealloc = resize_handle
    0x49F1C6, // tios@000F = sprintf
    0x4632F4, // tios@0010 = DrawStrXY = puttext
    0x463C3C, // tios@0011 = DrawCharXY = putchar
    0x461D80, // tios@0012 = FontSetSys = set_font
    0x461E48, // tios@0013 = ? = gr_draw_to
    0x461E86, // tios@0014 = ? = gr_move_to
    0x461E94, // tios@0015 = PortSet = gr_set_buffer
    0x461EB8, // tios@0016 = PortRestore = gr_screen_buffer
    0x4647E6, // tios@0017 = WinActivate = draw_window
    0x464B7A, // tios@0018 = WinClose = destroy_window
    0x4652EE, // tios@0019 = WinOpen = create_window
    0x465B00, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468C20, // tios@001E = MenuPopup
    0x468E06, // tios@001F = MenuBegin
    0x468FC4, // tios@0020 = MenuOn
    0x465FC4, // tios@0021 = SF_font
    0x46CC38, // tios@0022 = HeapAllocThrow
    0x4FB7A4, // tios@0023 = strcmp
    0x46EF0A, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461DD2, // tios@0026 = ? = FontGetSys
    0x49E758, // tios@0027 = ? = vcbprintf
    0x4FB6B4, // tios@0028 = strlen
    0x4FB6CC, // tios@0029 = strncmp
    0x4FB720, // tios@002A = strncpy
    0x4FB754, // tios@002B = strcat
    0x4FB778, // tios@002C = strchr
    0x4318C4, // tios@002D = push_quantum
    0x4FAB5C, // tios@002E = OSAlexOut
    0x4F3996, // tios@002F = ERD_dialog
  }},
  {"1.12", {
    0x4FAE10, // tios@0000 = ? = ST_redraw = update_status
    0x4FAEE6, // tios@0001 = ? = ST_message = status_message
    0x46CACA, // tios@0002 = HeapFree = destroy_handle
    0x46CB48, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x4023A8, // tios@0006 = ? = reset_link
    0x40241A, // tios@0007 = ? = flush_link
    0x402472, // tios@0008 = ? = tx_free
    0x4024AC, // tios@0009 = ? = transmit
    0x402530, // tios@000A = ? = receive
    0x46CAB0, // tios@000B = HeapFreeIndir = dispose_handle
    0x4FADD4, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x46CC9C, // tios@000E = HeapRealloc = resize_handle
    0x49F272, // tios@000F = sprintf
    0x463328, // tios@0010 = DrawStrXY = puttext
    0x463C70, // tios@0011 = DrawCharXY = putchar
    0x461DB4, // tios@0012 = FontSetSys = set_font
    0x461E7C, // tios@0013 = ? = gr_draw_to
    0x461EBA, // tios@0014 = ? = gr_move_to
    0x461EC8, // tios@0015 = PortSet = gr_set_buffer
    0x461EEC, // tios@0016 = PortRestore = gr_screen_buffer
    0x46481A, // tios@0017 = WinActivate = draw_window
    0x464BAE, // tios@0018 = WinClose = destroy_window
    0x465322, // tios@0019 = WinOpen = create_window
    0x465B34, // tios@001A = WinStrXY = puttext_window
    0x007594, // tios@001B = ? = kb_vars
    0x004440, // tios@001C = ? = main_lcd
    0x00761C, // tios@001D = ? = ST_flags
    0x468C54, // tios@001E = MenuPopup
    0x468E3A, // tios@001F = MenuBegin
    0x468FF8, // tios@0020 = MenuOn
    0x465FF8, // tios@0021 = SF_font
    0x46CC6C, // tios@0022 = HeapAllocThrow
    0x4FB850, // tios@0023 = strcmp
    0x46EF3E, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x461E06, // tios@0026 = ? = FontGetSys
    0x49E804, // tios@0027 = ? = vcbprintf
    0x4FB760, // tios@0028 = strlen
    0x4FB778, // tios@0029 = strncmp
    0x4FB7CC, // tios@002A = strncpy
    0x4FB800, // tios@002B = strcat
    0x4FB824, // tios@002C = strchr
    0x4318B8, // tios@002D = push_quantum
    0x4FAC08, // tios@002E = OSAlexOut
    0x4F3A42, // tios@002F = ERD_dialog
  }},
  {"2.1", {
    0x4D1204, // tios@0000 = ? = ST_redraw = update_status
    0x4D12DC, // tios@0001 = ? = ST_message = status_message
    0x4620FE, // tios@0002 = HeapFree = destroy_handle
    0x46217C, // tios@0003 = HeapAlloc = create_handle
    0x400ED6, // tios@0004 = ER_catch
    0x400EFC, // tios@0005 = ER_success
    0x4023A8, // tios@0006 = ? = reset_link
    0x40241A, // tios@0007 = ? = flush_link
    0x402472, // tios@0008 = ? = tx_free
    0x4024AC, // tios@0009 = ? = transmit
    0x402530, // tios@000A = ? = receive
    0x4620E4, // tios@000B = HeapFreeIndir = dispose_handle
    0x4D11C8, // tios@000C = ST_busy = set_activity
    0x400EAC, // tios@000D = ER_throwVar
    0x4622D6, // tios@000E = HeapRealloc = resize_handle
    0x483706, // tios@000F = sprintf
    0x45885C, // tios@0010 = DrawStrXY = puttext
    0x4591A8, // tios@0011 = DrawCharXY = putchar
    0x4572C8, // tios@0012 = FontSetSys = set_font
    0x457394, // tios@0013 = ? = gr_draw_to
    0x4573D2, // tios@0014 = ? = gr_move_to
    0x4573E0, // tios@0015 = PortSet = gr_set_buffer
    0x457404, // tios@0016 = PortRestore = gr_screen_buffer
    0x459D66, // tios@0017 = WinActivate = draw_window
    0x45A102, // tios@0018 = WinClose = destroy_window
    0x45A88E, // tios@0019 = WinOpen = create_window
    0x45B0A6, // tios@001A = WinStrXY = puttext_window
    0x0079A8, // tios@001B = ? = kb_vars
    0x004720, // tios@001C = ? = main_lcd
    0x007A60, // tios@001D = ? = ST_flags
    0x45E23C, // tios@001E = MenuPopup
    0x45E424, // tios@001F = MenuBegin
    0x45E5E2, // tios@0020 = MenuOn
    0x45B578, // tios@0021 = SF_font
    0x4622A6, // tios@0022 = HeapAllocThrow
    0x4D1C70, // tios@0023 = strcmp
    0x4645BE, // tios@0024 = ? = FindSymEntry
    0x400000, // tios@0025 = ROM_origin
    0x45731A, // tios@0026 = ? = FontGetSys
    0x482C90, // tios@0027 = ? = vcbprintf
    0x4D1B80, // tios@0028 = strlen
    0x4D1B98, // tios@0029 = strncmp
    0x4D1BEC, // tios@002A = strncpy
    0x4D1C20, // tios@002B = strcat
    0x4D1C44, // tios@002C = strchr
    0x42FD64, // tios@002D = push_quantum
    0x4D00D0, // tios@002E = OSAlexOut
    0x4C912A, // tios@002F = ERD_dialog
  }},
  {NULL, {}}
};
