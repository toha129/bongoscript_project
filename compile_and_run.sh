#!/bin/bash
cd /d/Games/Compressed/bongoscript_project
gcc output.c -o runme.exe 2>&1
if [ $? -ne 0 ]; then
    echo "COMPILE_ERROR"
    exit 1
fi
./runme.exe < user_input.txt 2>&1
