@echo off

flink -0
if errorlevel 1 goto error

flink -b %fargo%\fargo.92b
if errorlevel 1 goto error

call pfcompat %fargo%\fargo.92b
if errorlevel 1 goto error_2

flink -u %fargo%\fargo.92b

echo Wait at least 1 second, then
pause

flink -0
if errorlevel 1 goto error

flink -s %fargo%\asm\lib\*.92p -s %fargo%\asm\prgm\*.92p -s %fargo%\asm\oldfargo\*.92p
if errorlevel 1 goto error
goto end

:error
echo Error communicating with TI-92. Please make sure the link cable is attached.
goto end

:error_2
echo Error putting Fargo in backup file

:end
