
%{
#include "nodes.h"
int yyerror(const char *s);
int yylex (void);
void crf();
void deuRuim();
%}

%define parse.error verbose

%token TOK_PRINT TOK_WHILE TOK_IBLC TOK_FBLC TOK_IF TOK_ELSE TOK_AND TOK_OR
%token TOK_MAQ TOK_MEQ TOK_EQL TOK_DDQ
%token TOK_TPINT TOK_TPFLT TOK_TPSTR
%token<integer> TOK_INT
%token<flt> TOK_FLT
%token<name> TOK_IDENT
%token<str> TOK_STR

%type<node> factor term expr logico condicional stmt stmts program
%type<name> tipo 

%start program

%union {
   int integer;
   float flt;
   char *name;
   char *str;
   Node *node;
}

%%

program : TOK_IBLC stmts TOK_FBLC {
	Program pg($stmts);
	pg.printAst();
    // crf();
	
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
      $$ = new LoadComValor($id,$e);
  }
  | TOK_IDENT[id] tipo[tp] '=' expr[e] ';'{
      $$ = new Store($id,$tp,$e);
  }
  | TOK_IDENT[id] tipo[tp] ';'{
      $$ = new StoreSemValor($id,$tp);
  }
  | TOK_PRINT '[' expr[e] ']' ';'{
      $$ = new Print($e);
  }
  | TOK_WHILE '[' logico ']' TOK_IBLC stmts TOK_FBLC {
      $$ = new While($logico, $stmts);
  } 
  | TOK_IF '[' logico ']' TOK_IBLC stmts TOK_FBLC {
        $$ = new IF($logico, $stmts);
  }
  ;


tipo
    : TOK_TPINT { $$ = (char*)"int"; }
    | TOK_TPFLT { $$ = (char*)"float"; }
    | TOK_TPSTR { $$ = (char*)"string"; }
    ;

logico: '(' condicional[c1] ')' TOK_AND '(' condicional[c2]')' {
      $$ = new Logico($c1,"AND",$c2);
    }
    |  '(' condicional[c1] ')' TOK_OR '(' condicional[c2] ')' {
      $$ = new Logico($c1,"OR",$c2);
    }
    | condicional{
        $$ = $condicional;
    }
    ;

condicional :  expr[le] TOK_MAQ expr[re] {
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
  | TOK_STR[str] {
      $$ = new ConstString($str);
  }
  ;

%%
