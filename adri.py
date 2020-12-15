#!/usr/bin/env python

# by Adrian Hacar Sobrino for Dregs gen

import sys
import subprocess
import sys


# Encodes an hexadecimal number passed as a string into the subtraction of two numbers without the characters 00 0a 0d. 
# Ex: adri("000000ff") 
# Output: 01010201 - 01010102 = 000000ff
def adri(num,  num_bits=32):
    x = num # hex number
    x = x.lower()
    y = ""
    z = ""
    carry = False

    steps=int(num_bits/4)
    
    for i in range(steps,0,-2):
        byte=x[i-2:i]

        #check carry flag
        if carry:
            carry = byte == "ff"
            num=int(byte,16)
            byte=format(num+1, 'x').rjust(2,'0')[-2:] #if carry comes from the previous iteration -> add 1 to current byte

        if byte == "ff": #byte is ff -> set carry for next iteration before computation
            carry= True

        if byte not in ['09','0c','ff']: 
            num = int(byte,16)
            y=format(num+1, 'x').rjust(2,'0')+y
            z = "01"+z
        else: #predecesor of blacklisted values-> instead of add 1, add 2
            num = int(byte,16)
            y=format(num+2, 'x').rjust(2,'0')[-2:]+y
            z = "02"+z
    
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
    print("All tests passed")

if __name__ == "__main__":
    tester()