%{ 

#include <stdio.h>

class Node;

#include "flapilador.tab.h"
int yyerror(const char *s);

char *build_file_name;
int errorcount = 0;

    // "FLAMAIN"		           { return TOK_FLAMAIN; }
    // "VAR"                       { return TOK_IF; }
    // "GOL"                       { return TOK_IBLC; }
    // "IMPEDIDO"                  { return TOK_ELSE; }
    // "MENGO"                     { return TOK_FBLC; }
    // "AND"                       { return TOK_AND; }
    // "OR"                        { return TOK_OR; }
    // "ZICO"                      { return TOK_WHILE; }
    // "["					        { return '['; }
    // "]"					        { return ']'; }

%}

%option yylineno

%%

[ \n\t\r]		            { }
"DIDI".*                    { }


";"                         { return ';'; }
"+"					        { return '+'; }
"-"					        { return '-'; }
"*"					        { return '*'; }
"/"					        { return '/'; }
"("					        { return '('; }
")"					        { return ')'; }
"="					        { return '='; }


"print"		                { return TOK_PRINT; }



[0-9]+				        {
                            yylval.integer = atoi(yytext); 
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


int yyerror(const char *s) {
    fprintf(stderr, "%d:%d: %s\n", 
        yylineno, 0, s);
    errorcount++;
    return 1;
}

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    
    if (argc <= 1) {
        fprintf(stderr, "Sintaxe: %s nome_do_programa\n",
            argv[0]);
        return 1;
    }

    build_file_name = argv[1];
    yyin = fopen(build_file_name, "r");
    if (yyin == NULL) {
        fprintf(stderr, "Não foi possível abrir o arquivo %s.\n", build_file_name);
        return 1;
    }

    //yydebug = 1;
    yyparse();

    if (yyin)
        fclose(yyin);
    
    return errorcount;
}