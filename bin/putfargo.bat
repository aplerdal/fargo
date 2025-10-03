@echo off
%fargo%\bin\flinker -vb %1 %fargo%\asm\kernel\kernel.o %fargo%\asm\kernel\tios.o
if errorlevel 1 goto end
echo Successfully put Fargo kernel in %1
:end
