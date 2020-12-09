rm -rf reverse_shell*
nasm.exe -f win32 reverse_asm.asm -o reverse_shell.o
ld -mi386pe reverse_shell.o -o reverse_shell32.exe
