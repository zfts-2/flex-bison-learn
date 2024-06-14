cd /d %~dp0
start cmd /k "bash -c "dos2unix test.asm;gcc -m32 -no-pie -x assembler test.asm -o test;./test;"  "
