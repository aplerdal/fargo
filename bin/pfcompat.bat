@echo off
%fargo%\bin\flinker -vb %1 %fargo%\asm\kernel\kernel.o %fargo%\asm\kernel\tios.o %fargo%\asm\kernel\0_1_x.o
if errorlevel 1 goto end
echo Successfully put Fargo kernel in %1, with Fargo 0.1.x compatibility
:end
