
%{ 
#include "nodes.h"
int yyerror(const char *s); // Função de erro
int yylex(void); //Invoca o Analisador Léxico
%}

%define parse.error verbose
/*TOKENS - Terminais da Gramática*/
%token TOK_FLAMAIN TOK_IDENT TOK_VAR TOK_GOL TOK_IMPEDIDO TOK_FLAPRINT TOK_OR TOK_AND TOK_QL TOK_ZICO TOK_MENGO
%token <interger> TOK_INT 
%token <flt> TOK_FLT
%token <name> TOK_IDENT

%type <node> prog flamain stmts stmt expr term factor print if id caso outroCaso logico while quebraLinha

%start prog //Simbolo inicial da gramática

/* Atributos dos tokens*/
%union {
	int interger;
	float flt;
	char *name;
	Node *node;
}

%%

prog
  : flamain {
        // $1 é a lista de statements (Node*), vindo de flamain
        Program *p = new Program($1);

        // imprime a AST (opcional, pra debug/graphviz)
        p->printAst();

        // roda o analisador semântico igual ao do professor
        SemanticVarDecl sem;
        sem.check(p);
    }
  ;

flamain
  : TOK_FLAMAIN '[' stmts ']' {
        // Ignora o nome do bloco, só passa os statements
        $$ = $3;   // Node* vindo de stmts
    }
  ;

  stmts
  : stmts stmt {
        // adiciona stmt na lista já existente
        $1->append($2);
        $$ = $1;
    }
  | stmt {
        // cria a lista com o primeiro statement
        $$ = new Stmts($1);
    }
  ;

stmt
  : print ';'    { $$ = $1; }
  | id ';' 		 { $$ = $1; }
  | expr ';'     { $$ = $1; }  /* expressão solta */
  | if           { $$ = $1; }  /* IF */
  | while        { $$ = $1; }  /* WHILE  */
  | quebraLinha  { $$ = $1; }  /* pode só repassar ou até ignorar */
  ;

id : TOK_IDENT '=' expr {
								if(!simbolo_existe($1)) simbolo_novo($1, id);
							}
	;

 //Implentando o Print
print : TOK_FLAPRINT '[' expr ']'
	;

  // Implementando o IF ELSE
if : TOK_VAR boolExpr TOK_GOL stmts TOK_MENGO
    | TOK_VAR boolExpr TOK_GOL stmts TOK_IMPEDIDO stmts TOK_MENGO
    ;

// While
while : TOK_ZICO boolExpr TOK_GOL stmts TOK_MENGO
    ;

boolExpr : boolExpr TOK_OR boolTerm
    | boolTerm
    ;

boolTerm : boolTerm TOK_AND boolFactor
    | boolFactor
    ;

boolFactor : '(' boolExpr ')'
    | expr '>' expr
    | expr '<' expr
    | expr '=''=' expr
    | expr '<''=' expr
    | expr '>''=' expr
    | expr '!''=' expr
    ;




 // Expressões aritmeticas
expr : expr[e1] '+' term{
		$$ = new BinaryOp($e1, '+', $term);
	 }
     | expr[e1] '-' term{
		$$ = new BinaryOp($e1, '-', $term);
	 }
     | term{
		$$ = $term;
	 }
     ;

term : term[t1] '*' factor{
		$$ = new BinaryOp($t1, '*', $factor);
	 }
     | term[t1] '/' factor{
		$$ = new BinaryOp($t1, '/', $factor);
	 }
     | factor{
		$$ = $factor;
	 }
     ;

factor : TOK_INT[interger]{
			$$ = new ConstInteger($integer);
		}
	   | TOK_FLT[flt]{
			$$ = new ConstDouble($flt);
	   }
	   | TOK_IDENT[id] {
			$$ = new Load($id);
	   }
	   ;

 // Reconhece \n para contar as linhas
quebraLinha : TOK_QL {contaLinha();}
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




