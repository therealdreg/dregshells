rm -rf reverse_shell64*
nasm -f win64 reverse_asm64.asm -o reverse_shell64.o
ld -mi386pep reverse_shell64.o -o reverse_shell64.exe
