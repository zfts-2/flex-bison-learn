.intel_syntax noprefix
.global main
.global myprint
.data
format_str:
.asciz "%d\n"
.extern printf
.text
main:
  push ebp
  mov ebp, esp
  sub esp, 8
  push 0
  pop eax
  mov DWORD PTR [ebp-4], eax
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  push eax
  push offset format_str
  call printf
  add esp, 8
  .L_while_condit_1:
  mov eax, DWORD PTR[ebp-4]
  push eax
  push 11
  pop ebx
  pop eax
  cmp eax, ebx
  SETL al
  movzx eax, al
  push eax
  pop eax
  cmp eax, 0
  je .L_while_end_1
  push 7
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  pop ebx
  cdq
  idiv ebx
  mov eax, edx
  push eax
  push 3
  pop ebx
  pop eax
  cmp eax, ebx
  SETE al
  movzx eax, al
  push eax
  pop eax
  cmp eax, 0
  je .L_if_end_1
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  push eax
  push offset format_str
  call printf
  add esp, 8
  jmp .L_while_end_2
  .L_if_end_1:
  push 2
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  pop ebx
  cdq
  idiv ebx
  mov eax, edx
  push eax
  push 0
  pop ebx
  pop eax
  cmp eax, ebx
  SETE al
  movzx eax, al
  push eax
  pop eax
  cmp eax, 0
  je .L_if_end_2
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  push eax
  push offset format_str
  call printf
  add esp, 8
  .L_if_end_2:
  mov eax, DWORD PTR[ebp-4]
  push eax
  push 1
  pop ebx
  pop eax
  add eax, ebx
  push eax
  pop eax
  mov DWORD PTR [ebp-4], eax
  jmp .L_while_condit_1
  .L_while_end_1:
  mov eax, DWORD PTR[ebp-4]
  push eax
  pop eax
  push eax
  push offset format_str
  call printf
  add esp, 8
  push 0
  pop eax
  leave
  ret