%{
(* See this for a tutorial on ocamlyacc
 * http://plus.kaist.ac.kr/~shoh/ocaml/ocamllex-ocamlyacc/ocamlyacc-tutorial/ *)
open Nano
%}

%token EOF
%token <int> Num
%token <string> Id
%token TRUE FALSE
%token PLUS MINUS MUL DIV EQ NE LT LE AND OR
%token LPAREN RPAREN
%token LBRAC RBRAC COLONCOLON SEMI
%token IF THEN ELSE
%token LET REC IN
%token FUN ARROW

%nonassoc LET FUN
%right SEMI
%left IF
%left OR
%left AND
%left EQ NE LT LE
%right COLONCOLON
%left PLUS MINUS
%left MUL DIV
%nonassoc Id Num TRUE FALSE
%left APP
%nonassoc LPAREN LBRAC

%start exp
%type <Nano.expr> exp

%%

exp:
  | Num                                   { Const $1 }
  | Id                                    { Var $1 }
  | TRUE                                  { True }
  | FALSE                                 { False }
       
  | exp PLUS exp                          { Bin ($1, Plus, $3) }
  | exp MINUS exp                         { Bin ($1, Minus, $3) }
  | exp MUL exp                           { Bin ($1, Mul, $3) }
  | exp DIV exp                           { Bin ($1, Div, $3) }
  | exp EQ exp                            { Bin ($1, Eq, $3) }
  | exp NE exp                            { Bin ($1, Ne, $3) }
  | exp LT exp                            { Bin ($1, Lt, $3) }
  | exp LE exp                            { Bin ($1, Le, $3) }
  | exp AND exp                           { Bin ($1, And, $3) }
  | exp OR exp                            { Bin ($1, Or, $3) }

  | exp COLONCOLON exp                    { Bin ($1, Cons, $3) }
  | LBRAC list_exp                        { $2 }
     
  | LPAREN exp RPAREN %prec LPAREN        { $2 }

  | LET Id EQ exp IN exp %prec LET        { Let ($2, $4, $6) }
  | LET REC Id EQ exp IN exp %prec LET    { Letrec ($3, $5, $7) }
  | FUN Id ARROW exp %prec FUN            { Fun ($2, $4) }
  | IF exp THEN exp ELSE exp %prec IF     { If ($2, $4, $6) }
  | exp exp %prec APP                     { App ($1, $2) }

list_exp:
  | exp SEMI list_exp                     { Bin ($1, Cons, $3) }
  | exp RBRAC                             { Bin ($1, Cons, NilExpr) }
  | RBRAC                                 { NilExpr }
