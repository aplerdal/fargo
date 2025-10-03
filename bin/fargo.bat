@echo off
if not exist %1.asm goto error0

call %fargo%\bin\a68k %1.asm
echo ÿ
if not exist %1.o goto error1
%fargo%\bin\flinker -vo %1.92p %1.o
del %1.o>nul
goto end

:error0
echo File not found: %1.asm
goto end

:error1
echo There were errors.

:end
