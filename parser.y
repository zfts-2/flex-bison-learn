%{
#include <bits/stdc++.h>

using namespace std;

int yylex(void);
void yyerror(const char*);
#define YYSTYPE char*
extern FILE *yyin;

int variable_num = 0;
int para_num = 0;
int if_count = 0;
int else_count = 0;
int para_new   = 0;

unordered_map <string, string> variable_offsets;

%}

%token T_Constant T_Id T_Int T_Void T_Return T_Print T_If T_Else T_While T_Continue T_Break T_Le T_Ge T_Eq T_Ne T_And T_Or

%left T_Or
%left T_And
%left '|'
%left '^'
%left '&' 
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge
%left '+' '-'
%left '*' '/' '%'
%right '!' '~' 

%%
CODE: function  { }
    | CODE function { };

function: Type T_Id '(' ')' '{' PARAGRAPH '}'           {
                                                                    stringstream tmp_string;
                                                                    tmp_string << $2 << ":\n  push ebp\n  mov ebp, esp\n  sub esp, " << 4*(1+variable_num) << "\n" << $6 << "  leave\n  ret\n\n";
                                                                    printf(tmp_string.str().c_str());
                                                                    variable_num = 0;
                                                                }
        | Type T_Id '(' Parameter ')' '{' PARAGRAPH '}' { 
                                                                    stringstream tmp_string;
                                                                    tmp_string<< $2 << ":\n  push ebp\n  mov ebp, esp\n  sub esp, " << 4*(1+variable_num) << "\n" << $7 << "  leave\n  ret\n\n";
                                                                    printf(tmp_string.str().c_str());
                                                                    variable_num = 0;
                                                                    para_num = 0;
                                                                }
        ;

Parameter   : T_Int T_Id {para_num +=1;variable_offsets[$2] = "+" + to_string(4 * (1+para_num));}
            | Parameter ',' Parameter    { }
            ;

Type: T_Int     { }
    | T_Void    { }
    ;

PARAGRAPH   : Stmt { }
            | PARAGRAPH Stmt { stringstream tmp_string; tmp_string << $1 << $2; $$ = strdup(tmp_string.str().c_str());}
            ;

Stmt: T_Id '=' E ';'            { 
                                    stringstream tmp_string;
                                    tmp_string << $3 << "  pop eax\n  mov DWORD PTR [ebp" << variable_offsets[$1] << "], eax\n";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | New_Variable              { $$ = $1; }
    | T_Return E ';'            {   
                                    stringstream tmp_string;
                                    tmp_string << $2 << "  pop eax\n" ;
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | Use_Fuction ';'           { $$ = $1; }
    | T_Continue ';'            {
                                    stringstream tmp_string;
                                    tmp_string << "  jmp .L_while_condit_" << *$1 - '0' << "\n" ;
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | T_Break ';'               {
                                    stringstream tmp_string;
                                    tmp_string << "  jmp .L_while_end_" << *$1 - '0' << "\n" ;
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    |T_If '(' E ')' '{' PARAGRAPH '}'   {
                                            stringstream tmp_string;
                                            tmp_string << $3 << "  pop eax\n  cmp eax, 0\n" << "  je .L_if_end_" << ++if_count << "\n" << $6 << "  .L_if_end_" << if_count << ":\n";
                                            $$ = strdup(tmp_string.str().c_str());
                                        }
    |T_If '(' E ')' '{' PARAGRAPH '}' T_Else '{' PARAGRAPH '}'  {
                                                                    stringstream tmp_string;
                                                                    tmp_string << $3 <<"  pop eax\n  cmp eax, 0\n" << "  je .L_else_start_" << ++else_count << "\n"
                                                                    << $6 << "  jmp .L_if_end_" << ++if_count << "\n  .L_else_start_" << else_count << ":\n" << $10
                                                                    << "  .L_if_end_" << if_count << ":\n";
                                                                    $$ = strdup(tmp_string.str().c_str());
                                                                }

    |T_While '(' E ')' '{' PARAGRAPH '}'    {
                                                stringstream tmp_string;
                                                tmp_string << "  .L_while_condit_" << $1 << ":\n" << $3 << "  pop eax\n  cmp eax, 0\n" << "  je .L_while_end_" << $1 << "\n"
                                                << $6 << "  jmp .L_while_condit_" << $1 << "\n  .L_while_end_" << $1 << ":\n";
                                                $$ = strdup(tmp_string.str().c_str());
                                            }
    ;

Use_Fuction : T_Print '(' E ')'             {   
                                                stringstream tmp_string;
                                                tmp_string << $3 << "  pop eax\n  push eax\n  push offset format_str\n  call printf\n  add esp, 8\n";
                                                $$ = strdup(tmp_string.str().c_str());
                                            }
            | T_Id '(' Input ')'    {
                                        stringstream tmp_string;
                                        tmp_string << $3 << "  call " << $1 << "\n  add esp, " << para_new * 4 << "\n";
                                        para_new = 0;
                                        $$ = strdup(tmp_string.str().c_str());
                                    }
            | T_Id '(' ')'          {
                                        stringstream tmp_string;
                                        tmp_string << "  call "<< $1 <<"\n  add esp, 0\n";
                                        $$ = strdup(tmp_string.str().c_str());
                                    }
            ;

Input   : E                 { para_new ++;$$ = $1;}
        | Input ',' Input   { stringstream tmp_string; tmp_string << $3 << $1; $$ = strdup(tmp_string.str().c_str());}
        ;

New_Variable : T_Int New_Int ';'  { $$ = $2;}

New_Int : T_Id                  {   
                                    variable_offsets[$1] = to_string(-4 * ++variable_num);
                                    stringstream tmp_string;tmp_string << "";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
        | T_Id '=' E            {   
                                    variable_offsets[$1] = to_string(-4 * ++variable_num);
                                    stringstream tmp_string;
                                    tmp_string << $3 << "  pop eax\n  mov DWORD PTR [ebp" << variable_offsets[$1] << "], eax\n";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
        | New_Int ',' New_Int   {   
                                    stringstream tmp_string;
                                    tmp_string << $1 << $3;
                                    $$ = strdup(tmp_string.str().c_str());
                                }
        ;

E   : '(' E ')'                 { $$ = $2; }
    | '-' '(' E ')'             {
                                    stringstream tmp_string; 
                                    tmp_string << $3 << "  pop eax\n  neg eax\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '+' E                   {   
                                    
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  add eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '-' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  sub eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }    
    | E '*' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  imul eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '/' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cdq\n  idiv ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '%' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $3 << $1 << "  pop eax\n  pop ebx\n  cdq\n  idiv ebx\n  mov eax, edx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '<' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETL al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_Le E                  {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETLE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '>' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETG al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_Ge E                  {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETGE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_Eq E                  {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_Ne E                  {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  cmp eax, ebx\n  SETNE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '&' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  and eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '|' E                   {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << $3 << "  pop ebx\n  pop eax\n  or eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E '^' E                   {
                                    stringstream tmp_string; 
                                    tmp_string <<$1<<$3<<"  pop ebx\n  pop eax\n  xor eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_And E                 {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << "  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETNE al\n  movzx eax, al\n  push eax\n"<<
                                    $3 << "  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETNE al\n  movzx eax, al\n  push eax\n  pop eax\n  pop ebx\n  and eax, ebx\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | E T_Or E                  {
                                    stringstream tmp_string; 
                                    tmp_string << $1 << "  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETE al\n  movzx eax, al\n  push eax\n" <<
                                    $3 <<"  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETE al\n  movzx eax, al\n  push eax\n  pop eax\n  pop ebx\n  and eax, ebx\n  push eax\n  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }

    | '-' T_Constant            {
                                    stringstream tmp_string; 
                                    tmp_string <<"  push "<< $2 <<"\n  pop eax\n  neg eax\n  push eax\n";      
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | '-' T_Id                  {
                                    stringstream tmp_string;
                                    tmp_string << "  mov eax, DWORD PTR[ebp" << variable_offsets[$2] << "]\n  push eax\n  pop eax\n  neg eax\n  push eax\n";      
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | '-' Use_Fuction           {
                                    stringstream tmp_string;
                                    tmp_string << $2 <<"  push eax\n  pop eax\n  neg eax\n  push eax\n";      
                                    $$ = strdup(tmp_string.str().c_str());
                                } 
    | '!' E                     {
                                    stringstream tmp_string; 
                                    tmp_string << $2 <<"  push 0\n  pop eax\n  pop ebx\n  cmp eax, ebx\n  SETE al\n  movzx eax, al\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | '~' E                     {
                                    stringstream tmp_string; 
                                    tmp_string <<$2<<"  pop eax\n  not eax\n  push eax\n";  
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | T_Id                      {
                                    stringstream tmp_string;
                                    tmp_string << "  mov eax, DWORD PTR[ebp" << variable_offsets[$1] << "]\n  push eax\n";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | T_Constant                {
                                    stringstream tmp_string;
                                    tmp_string <<"  push " << $1 << "\n";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    | Use_Fuction               {
                                    stringstream tmp_string;
                                    tmp_string << $1 << "  push eax\n";
                                    $$ = strdup(tmp_string.str().c_str());
                                }
    ;

%%

int main(int argc, char **argv) {
    FILE *input = fopen(argv[1], "r");
    yyin = input;
    printf(".intel_syntax noprefix\n.global main\n.global myprint\n.data\nformat_str:\n.asciz \"%sd\\n\"\n.extern printf\n.text\n", "%");
    yyparse();
    fclose(input);
    return 0;
}