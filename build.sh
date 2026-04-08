#!/bin/bash
set -ex
cd /d/Games/Compressed/bongoscript_project
bison -d parser.y
flex lexer.l
gcc parser.tab.c lex.yy.c -o banglish.exe
ls -la banglish.exe
