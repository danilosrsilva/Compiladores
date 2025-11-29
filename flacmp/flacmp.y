
%{
#include "nodes.h"
int yyerror(const char *s);
int yylex (void);
void crf();
void deuRuim();
%}

%define parse.error verbose

%token TOK_PRINT TOK_WHILE TOK_IBLC TOK_FBLC
%token TOK_MAQ TOK_MEQ TOK_EQL TOK_DDQ
%token<integer> TOK_INT
%token<flt> TOK_FLT
%token<name> TOK_IDENT

%type<node> factor term expr condicional stmt stmts program

%start program

%union {
   int integer;
   float flt;
   char *name;
   Node *node;
}

%%

program : stmts {
	Program pg($stmts);
	pg.printAst();
    crf();
	
	SemanticVarDecl vd;
	vd.check(&pg);
	//vd.printFoundVars();
}

stmts : stmts[ss] stmt {
      $ss->append($stmt);
      $$ = $ss;
  }
  | stmt {
      $$ = new Stmts($stmt);
  }
  ;

stmt : TOK_IDENT[id] '=' expr[e] ';'{
      $$ = new Store($id,$e);
  }
  | TOK_PRINT '[' expr[e] ']' ';'{
      $$ = new Print($e);
  }
  | TOK_WHILE '[' condicional ']' TOK_IBLC stmts TOK_FBLC {
      $$ = new While($condicional, $stmts);
  } 
  ;

condicional : expr[le] TOK_MAQ expr[re] {
      $$ = new Condicional($le,">",$re);
    }
    |  expr[le] TOK_MEQ expr[re] {
      $$ = new Condicional($le,"<",$re);
    }
    |  expr[le] TOK_EQL expr[re] {
      $$ = new Condicional($le,"==",$re);
    }
    |  expr[le] TOK_DDQ expr[re] {
      $$ = new Condicional($le,"!=",$re);
    }
    ;
     
expr : expr[e1] '+' term {
      $$ = new BinaryOp($e1, '+', $term);
  }

  | expr[e1] '-' term {
      $$ = new BinaryOp($e1, '-', $term);
  }

  | term {
      $$ = $term;
  }
  ;

term : term[t1] '*' factor {
      $$ = new BinaryOp($t1, '*', $factor);
  }

  | term[t1] '/' factor {
      $$ = new BinaryOp($t1, '/', $factor);
  }

  | factor {
      $$ = $factor;
  }
  ;

factor : '(' expr ')' {
      $$ = $expr;
  }
  | TOK_INT[integer] {
      $$ = new ConstInteger($integer);
  }
  | TOK_FLT[flt] {
      $$ = new ConstDouble($flt);
  }
  | TOK_IDENT[id] {
      $$ = new Load($id);
  }
  ;

%%

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


void deuRuim(){
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