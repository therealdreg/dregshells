#!/usr/bin/env python

# by Adrian Hacar Sobrino for Dregs gen

import sys
import subprocess
import sys


# Encodes an hexadecimal number as the substraction of two numbers without the characters 00 0a 0d
def adri(num,  num_bits=32):
    x = num # hex number
    x = x.lower()
    y = ""
    z = ""
    acarreo = False

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
    print(line)
    return line


#######################################TEST CODE###############################3


#Returns True if badChar is found
def CheckBadChar(entry):
    for x in entry:
        if x.lower() == "0a" or x.lower() == "0d" or x.lower() == "00":
            return True
    return False


#Test to check against all possible inputs
def tester():
    cur_port = None
    endct = int("0xFFFFFFFF", 16) + 1
    startc = 0
    for x in xrange(startc, endct):
        cur_port = hex(x)[2:].zfill(8)
        if True:
            res = adri(cur_port)
            if x % 100000 == 0:
                print(res)
                
            first = res.split("-")[0].strip()
            second = res.split("-")[1]
            res = second.split("=")[1]
            second = second.split("=")[0].strip()
            split1 = [first[i:i+2] for i in range(0, len(first), 2)]
            split2 = [second[i:i+2] for i in range(0, len(second), 2)]

    
            if CheckBadChar(split1) or CheckBadChar(split2):
                print("Test not passed: Bad Char found in addition for "+res)
                sys.exit(1)


            first = int(first, 16)
            second = int(second, 16)
            ops = (first - second) & 0xffffffff

            if not (ops == x and int(res, 16) == x):
                print("Test not passed: Addition is not correct  for "+ res)
                sys.exit(1)


if __name__ == "__main__":
    adri("ffffffff")
    print("All tests passed")