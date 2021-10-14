#!/bin/bash

# MIT License - Copyright 2020
# David Reguera Garcia aka Dreg - dreg@fr33project.org
# -
# http://github.com/David-Reguera-Garcia-Dreg/ - http://www.fr33project.org/
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


IP="127.0.0.1" # change
PORT="4444" # change

# Test NULL:
# IP="127.0.255.1"
# PORT="255"
# Test 0A:
# PORT="501"

# IP="127.0.0.1"
# PORT="4444"

echo "ip: $IP"
echo "port: $PORT"

check_invalid_chars () {
    if `echo -n ${1} | fold -w2  | grep -q 00`; then
        echo -e "\nWARNING!! found 00 NULL in coded output, try other number please!\n"
    fi
    if `echo -n ${1} | fold -w2  | grep -q 0A`; then
        echo -e "\nWARNING!! found new line 0A NULL in coded output, try other number please!\n"
    fi
}

out=""

endian () {
    out=""
    v=${1}
    echo "converting: ${v}"
    i=${#v}

    while [ $i -gt 0 ]
    do
        i=$[$i-2]
        out+=${v:$i:2}
    done
}

sudo apt-get install syslinux-utils

echo "converting IP...."
endian $(gethostip -x $IP)
echo "endian: ${out}"
ip_converted=$(printf '%08X\n' "$(( ( 0x${out} ^ 0xFFFFFFFF ) & 0xFFFFFFFF ))")
echo "IP converted: ${ip_converted}"
check_invalid_chars ${ip_converted}

echo "converting PORT...."
endian $(gethostip -x $PORT | sed -r 's/^.{4}//')
echo "endian: ${out}"
port_converted=$(printf '%04X\n' "$(( ( ~ 0x${out} ) & 0xFFFF ))")
echo "port converted: ${port_converted}"
check_invalid_chars ${port_converted}


