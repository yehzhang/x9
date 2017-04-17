%{
open Nano
%}

%token EOF
%token <int> Num
%token <string> Id
%token COLON
%token COMMA

%start program
%type <Nano.program> program

%%

program:
  | maybe_statement_list                  { $1 }

maybe_statement_list:
  |                                       { [] }
  | statement_list                        { $1 }

statement_list:
  | statement statement_list              { $1 :: $2 }
  | statement                             { [$1] }

statement:
  | Id COLON                              { Label $1 }
  /* Instruction contains at least one argument */
  | Id operand_list                       { Instruction ($1, $2) }

operand_list:
  | operand COMMA operand_list            { $1 :: $3 }
  | operand                               { [$1] }

operand:
  | Num                                   { Imm $1 }
  | Id                                    { Reg $1 }
