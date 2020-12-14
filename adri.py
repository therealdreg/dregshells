#!/usr/bin/env python

# by Adrian Hacar Sobrino for Dregs gen

import sys
import subprocess
import sys


def CheckBadChar(entry):
    for x in entry:
#        print(x)
        if x == "0A" or x == "0a" or x == "0d" or x == "0D" or x == "00":
            print("bad char found!")
            sys.exit()

def adri(port):
    x = port # hex number
    x = x.lower()
    y = ""
    z = ""
    acarreo = False
    
    num_bits=32 #32 or 64 bits
    
    steps=int(num_bits/4)
    
    for i in range(steps,0,-2):
        byte=x[i-2:i]
    
        #check acarreo flag
        if acarreo:
            if byte == "ff":
                acarreo = True
                num=int(byte,16)
                byte=format(num+1, 'x').rjust(2,'0')[-2:] #add acarreo +1 
            else:
                acarreo = False
                num=int(byte,16)
                byte=format(num+1, 'x').rjust(2,'0')[-2:] #add acarreo +1 
        if byte == "00":
            y = "05"+y
            z = "05"+z
        elif byte == "0a":
            y = "13"+y
            z = "09"+z
        elif byte == "0d":
            y = "10"+y
            z = "03"+z
        elif byte == "ff":
            #we add two in total: ff+02 =01 01
            y = "01"+y 
            z = "02"+z
            acarreo =True
        #caso los que se acercan 
        else:
            if byte in ['09','0c']:
                #add one in hexadecimal
                num = int(byte,16)
                y=format(num+2, 'x').rjust(2,'0')+y
                z = "02"+z
            else:
                #add one in hexadecimal
                num = int(byte,16)
                y=format(num+1, 'x').rjust(2,'0')+y
                z = "01"+z
    
    line=y + " - "+z+ " = "+x
    return line
    #print(line)
    #y_num=int(y,16)
    #z_num=int(z,16)
    
    #print("Resultado:"+ hex(y_num-z_num))

#print(adri("fefea020"))
cur_port = None
endct = int("0xFFFFFFFF", 16) + 1
startc = 0
for x in xrange(startc, endct):
    cur_port = hex(x)[2:].zfill(8)
#    print(cur_port)
    if True:
        res = adri(cur_port)
#        print(res)
        if x % 100000 == 0:
            print(res)
        first = res.split("-")[0].strip()
        second = res.split("-")[1]
        res = second.split("=")[1]
        second = second.split("=")[0].strip()
        split1 = [first[i:i+2] for i in range(0, len(first), 2)]
        split2 = [second[i:i+2] for i in range(0, len(second), 2)]

#        split1[1] = "0A"
#        split1[2] = "00"
#        print(split1)
        CheckBadChar(split1)
     #   print("OK not bad chars first op")
        CheckBadChar(split2)
     #   print("OK not bad chars second op")


#        print(first, split1)
#        print(second, split2)
        first = int(first, 16)
        second = int(second, 16)

        ops = (first - second) & 0xffffffff
     #   print(ops)
        if ops == x and int(res, 16) == x:
 #           print("OK")
             pass
        else:
            print("fail!!" )
            sys.exit()


print("finish, last check was: " + adri(cur_port))
