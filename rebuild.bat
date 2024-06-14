cd /d %~dp0
start cmd /k "rd /s /q build & mkdir build & cd build & cmake .. & cmake --build . & Compilerlab4  ../test.c"