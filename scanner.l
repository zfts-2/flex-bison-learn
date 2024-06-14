%{
#define YYSTYPE char *
#include "parser.tab.h"
#include <bits/stdc++.h>
using namespace std;
void yyerror(const char *msg);

int layer_count = 0;
int while_count = 0;
int while_flag = 0;
stack<int> layer_stack;
stack<int> while_stack;
%}

SINGLE_OPS       ([+*-/%&~=,;|^()!<>])
INTEGER         [0-9]+
IDENTIFIER      [_a-zA-Z][_a-zA-Z0-9]*
WHITESPACE      [ \t]*

%%

{SINGLE_OPS}        { return yytext[0];         }



"{"                 {
                        layer_count++;
                        if (while_flag == 1){
                            layer_stack.push(layer_count);
                            while_stack.push(while_count);
                        }
                        return yytext[0]; 
                    }
"}"                 {
                        if (!layer_stack.empty() && (layer_count == layer_stack.top())){
                            layer_stack.pop();
                            while_stack.pop();
                        }
                        layer_count--;
                        return yytext[0]; 
                    }
"<="                { return T_Le;              }
">="                { return T_Ge;              }
"=="                { return T_Eq;              }
"!="                { return T_Ne;              }
"&&"                { return T_And;             }
"||"                { return T_Or;              }
"void"              { return T_Void;            }
"int"               { return T_Int;             }
"return"            { return T_Return;          }
"println_int"       { return T_Print;           }
"if"                { return T_If;              }
"else"              { return T_Else;            }
"while"             { 
                        while_flag = 1;
                        char str[12];
                        sprintf(str, "%d", ++while_count);
                        yylval = strdup(str);
                        return T_While;           
                    }
"continue"          { 
                        char str[12];
                        sprintf(str, "%d", while_stack.top());
                        yylval = strdup(str);
                        return T_Continue;           
                    }
"break"             {                         
                        char str[12];
                        sprintf(str, "%d", while_stack.top());
                        yylval = strdup(str);
                        return T_Break;           
                    }

{INTEGER}           { yylval = strdup(yytext); return T_Constant; }
{IDENTIFIER}        { yylval = strdup(yytext); return T_Id; }
{WHITESPACE}        { }

\n                  { }
<<EOF>>             { return 0; }
.                   { }

%%

int yywrap(void) { 
    return 1;
}

void yyerror(const char *msg) {
    exit(1);
}