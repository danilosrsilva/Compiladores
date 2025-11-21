%{
#include <stdio.h>

class Node;

#include "calc.tab.h"
int yyerror(const char *s);

char *build_file_name;
int errorcount = 0;

%}

%option yylineno

%%

[ \t\r\n]               { }

"print"                 { return TOK_PRINT; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; } 
"/"                     { return '/'; }
"("                     { return '('; }
")"                     { return ')'; }
";"                     { return ';'; }
"="                     { return '='; }

[0-9]+ {
    yylval.integer = atoi(yytext);
    return TOK_INT;
}

[0-9]+\.[0-9]+ {
    yylval.flt = atof(yytext);
    return TOK_FLT;
}

[a-zA-Z_][a-zA-Z_0-9]* {
    yylval.name = strndup(yytext, yyleng);
    return TOK_IDENT;
}

.                       { printf("Caractere não presente no alfabeto %c\n", yytext[0] ); }

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

