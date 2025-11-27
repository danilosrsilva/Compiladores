%{ 
#include <stdio.h>

class Node;

#include "flapilador.tab.h"   /* gera YYSTYPE e tokens */
int yyerror(const char *s); // Função de erro

char *build_file_name;
int errorcount = 0;

%}

%option yylineno

%%

[ \t\r]		                { }
"DIDI".*                   { }
[\n]                        { return QL; }

";"                         { return ';'; }
"+"					        { return '+'; }
"-"					        { return '-'; }
"*"					        { return '*'; }
"/"					        { return '/'; }
"("					        { return '('; }
")"					        { return ')'; }
"="					        { return '='; }
"["					        { return '['; }
"]"					        { return ']'; }

"FLAMAIN"		            { return TOK_FLAMAIN; }
"FLAPRINT"		            { return TOK_FLAPRINT; }
"VAR"                       { return TOK_VAR; }
"GOL"                       { return TOK_GOL; }
"IMPEDIDO"                  { return TOK_IMPEDIDO; }
"MENGO"                     { return TOK_MENGO; }
"AND"                       { return TOK_AND; }
"OR"                        { return TOK_OR; }
"ZICO"                      { return TOK_ZICO; }



[0-9]+				        {
                            yylval.interger = atoi(yytext); 
                            return TOK_INT; 
                            }
[0-9]+\.[0-9]*              { 
                            yylval.flt = atoi(yytext); 
                            return TOK_FLT;
                            }
[fF][lL][aA][a-zA-Z0-9_]*	{ 
                            yylval.name = strdup(yytext);
                            return TOK_IDENT; 
                            }

.					    { printf("Flactere não presente no alfabeto %c \n", yytext[0]);}

%%

int yyerror(const char *s){
    fprintf(stderr, "%d: %d: %s\n", yylineno, 0, s);
    errorcount++;
    return 1;
}
