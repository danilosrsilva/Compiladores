%{ 


#include "flapilador.tab.h"   /* gera YYSTYPE e tokens */
extern YYSTYPE yylval;

%}

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

"FLAMAIN"		            { return FLAMAIN; }
"FLAPRINT"		            { return FLAPRINT; }
"VAR"                       { return VAR; }
"GOL"                       { return GOL; }
"IMPEDIDO"                  { return IMPEDIDO; }
"MENGO"                     { return MENGO; }
"AND"                       { return AND; }
"OR"                        { return OR; }
"ZICO"                      { return ZICO; }



[0-9]+				        {
                            yylval.iargs = atoi(yytext); 
                            return INT; 
                            }
[0-9]+\.[0-9]*              { 
                            yylval.fargs = atoi(yytext); 
                            return FLT;
                            }
[fF][lL][aA][a-zA-Z0-9_]*	{ 
                            yylval.nome = strdup(yytext);
                            return VARMENGO; 
                            }

.					    {return yytext[0];}

%%
