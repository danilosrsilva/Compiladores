%{ 

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

int yyerror(const char *s); // Função de erro
int yylex(void); //Invoca o Analisador Léxico
int errorc = 0, linhas = 1; //Contar o número de erros no inicio do programa

typedef struct{
	char *nome;
	int token;
} simbolo;


int simbolo_qtd=0;
simbolo tsimbolo[100];
simbolo *simbolo_novo(char *nome, int token);
bool simbolo_existe(char *nome);
void debug();
void contaLinha(void);
void crf(void);
void deuErrado(void);

%}




%define parse.error verbose

/* Atributos dos tokens*/
%union {
	char *nome;
	int iargs;
	float fargs;
}

/*TOKENS - Terminais da Gramática*/
%token FLAMAIN VARMENGO VAR GOL IMPEDIDO FLAPRINT OR AND QL ZICO MENGO
%token <iargs> INT 
%token <fargs> FLT

%type <nome> VARMENGO

%start prog //Simbolo inicial da gramática

%%

prog : flamain {
		if (errorc > 0){
			printf("%d Gol(s) Contra\n", errorc);
			deuErrado();
		}else{
			printf("programa reconhecido\n");
			crf();
			debug();
		}
		
		}
     ;
	
flamain : FLAMAIN '[' stmts ']'
	;

stmts 	: stmts stmt 
		| stmt 
      	;

stmt 	: print ';'
		| varmengo ';' 
		| expr
		| var
		| quebraLinha
		| zico
		| error
     	;

varmengo : VARMENGO '=' expr {
								if(!simbolo_existe($1)) simbolo_novo($1, VARMENGO);
							}
	;

 //Implentando o Print
print : FLAPRINT '[' expr ']'
	;

 //Implementando o IF ELSE
var : VAR  decisao GOL stmts MENGO
	| VAR decisao GOL stmts IMPEDIDO stmts MENGO
	;

decisao : decisao OR outroAngulo
	| outroAngulo
	;

outroAngulo : outroAngulo AND cameraLenta
	| cameraLenta
	;

cameraLenta : '(' decisao ')'
	| expr '>' expr
	| expr '<' expr
	| expr '=''=' expr
	| expr '<''=' expr
	| expr '>''=' expr
	| expr '!''=' expr
	;

 //While
zico : ZICO decisao GOL stmts MENGO
	;

 // Expressões aritmeticas
expr : expr '+' term
     | expr '-' term
     | term
     ;

term : term '*' factor
     | term '/' factor
	 | term '%' factor
     | factor
     ;

factor : '(' expr ')'
       | INT 
	   | FLT
       | VARMENGO {
       		if(!simbolo_existe($1))
       			yyerror("Flariável nao declarada");;
			}
       ;

 // Reconhece \n para contar as linhas
quebraLinha : QL {contaLinha();}
	;

%%

int yywrap() {
	return 1;
}

void contaLinha(){
	linhas++;
}

int yyerror(const char *s) {
	errorc++;
	printf("Gol contra %d: %s | Linha %d\n",errorc, s, linhas);
	return 1;
}

simbolo *simbolo_novo(char *nome, int token){
	tsimbolo[simbolo_qtd].nome = nome;
	tsimbolo[simbolo_qtd].token = token;
	simbolo *result = &tsimbolo[simbolo_qtd];
	simbolo_qtd++;
	if( simbolo_qtd == 100) simbolo_qtd = 99;
	return result;
}

bool simbolo_existe(char *nome){
	//busca lienar não eficiente
	for(int i=0; i < simbolo_qtd; i++){
		if(strcmp(tsimbolo[i].nome, nome) == 0)
			return true;
	}
	return false;
}

void debug() {
	printf("\n\nFlasimbolos: \n");
	for(int i=0; i < simbolo_qtd; i++){
		printf("\t%s\n", tsimbolo[i].nome);
	}
}

void crf(){
	printf("\n\n");
	printf("⠀⠀⠀⠀⠀⠱⣶⣶⣶⣶⣶⣦⣤⣀⠀⠀⠀⠀⠀⠀\n");
    printf("⠀⠀⠀⠀⢀⣤⣵⣶⣾⣷⣀⠈⠛⢿⣷⡄⠀⠀⠀⣠\n");
    printf("⠀⠀⢀⣾⠟⠋⣭⣯⠙⠿⠸⣿⣿⠎⣿⣿⣎⠿⣿⡿\n");
    printf("⠀⢰⣿⠏⠀⠀⣿⣿⠀⠀⠀⣿⣿⠀⣿⣿⠋⠀⠙⠁\n");
    printf("⣤⣿⣿⠀⠀⠀⣿⣿⠀⠀⠀⣿⣿⢀⣿⠏⠀⠀⠀⠀\n");
    printf("⠸⣿⣿⡀⠀⠀⣿⣿⣶⣦⣤⣛⢿⣾⣷⣶⣶⣾⠀⠀\n");
    printf("⠀⠙⣿⣷⡀⠀⣿⣿⠀⠈⠙⢿⣷⡄⠀⠈⢻⠏⠀⠀\n");
    printf("⠀⠀⠈⠛⢿⣷⣯⣭⣤⣤⡆⣷⡝⣿⣆⠀⠀⠀⠀⠀\n");
    printf("⠀⠀⠀⠀⠀⠀⣯⣭⠉⠉⢀⣿⣿⠈⢿⣷⣤⣤⡴⠀\n");
    printf("⠀⠀⠀⠀⠀⠰⢿⣿⣆⠀⠼⣿⣿⡄⠈⠻⠿⠟⠁⠀\n\n");
}

void deuErrado(){
	printf("\n\n");
	printf("__________████████_____██████\n");
    printf("_________█░░░░░░░░██_██░░░░░░█\n");
    printf("________█░░░░░░░░░░░█░░░░░░░░░█\n");
    printf("_______█░░░░░░░███░░░█░░░░░░░░░█\n");
    printf("_______█░░░░███░░░███░█░░░████░█\n");
    printf("______█░░░██░░░░░░░░███░██░░░░██\n");
    printf("_____█░░░░░░░░░░░░░░░░░█░░░░░░░░███\n");
    printf("____█░░░░░░░░░░░░░██████░░░░░████░░█\n");
    printf("____█░░░░░░░░░█████░░░████░░██░░██░░█\n");
    printf("___██░░░░░░░███░░░░░░░░░░█░░░░░░░░███\n");
    printf("__█░░░░░░░░░░░░░░█████████░░█████████\n");
    printf("_█░░░░░░░░░░█████_████___████_█████___█\n");
    printf("_█░░░░░░░░░░█______█_███__█_____███_█___█\n");
    printf("█░░░░░░░░░░░░█___████_████____██_██████\n");
    printf("░░░░░░░░░░░░░█████████░░░████████░░░█\n");
    printf("░░░░░░░░░░░░░░░░█░░░░░█░░░░░░░░░░░░█\n");
    printf("░░░░░░░░░░░░░░░░░░░░██░░░░█░░░░░░██\n");
    printf("░░░░░░░░░░░░░░░░░░██░░░░░░░███████\n");
    printf("░░░░░░░░░░░░░░░░██░░░░░░░░░░█░░░░░█\n");
    printf("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█\n");
    printf("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█\n");
    printf("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█\n");
    printf("░░░░░░░░░░░█████████░░░░░░░░░░░░░░██\n");
    printf("░░░░░░░░░░█▒▒▒▒▒▒▒▒███████████████▒▒█\n");
    printf("░░░░░░░░░█▒▒███████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█\n");
    printf("░░░░░░░░░█▒▒▒▒▒▒▒▒▒█████████████████\n");
    printf("░░░░░░░░░░████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█\n");
    printf("░░░░░░░░░░░░░░░░░░██████████████████\n");
    printf("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█\n");
    printf("██░░░░░░░░░░░░░░░░░░░░░░░░░░░██\n");
    printf("▓██░░░░░░░░░░░░░░░░░░░░░░░░██\n");
    printf("▓▓▓███░░░░░░░░░░░░░░░░░░░░█\n");
    printf("▓▓▓▓▓▓███░░░░░░░░░░░░░░░██\n");
    printf("▓▓▓▓▓▓▓▓▓███████████████▓▓█\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n");

}

int main() {
	yyparse();
	// Print para facilitar a visualização dos testes
	printf("\n===================================================================================\n");
	return 0;
}




