
%{
#include "nodes.h"
int yyerror(const char *s);
int yylex (void);
%}

%define parse.error verbose
//TOK_IF TOK_ELSE TOK_IBLC TOK_FBLC TOK_WHILE

%token TOK_PRINT 
%token<integer> TOK_INT
%token<flt> TOK_FLT
%token<name> TOK_IDENT

%type<node> factor term expr stmt stmts program

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
  | TOK_PRINT expr[e] ';'{
      $$ = new Print($e);
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

