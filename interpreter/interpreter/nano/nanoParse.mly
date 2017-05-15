%{
open Nano
%}

%token EOF
%token <string> Num
%token <string> Id
%token COLON
%token COMMA
%token DEFINE

%start program
%type <Nano.program> program

%%

program:
  | section_list                          { $1 }

section_list:
  | maybe_alias_list post_alias_section_list { AliasHeader $1 :: $2 }

post_alias_section_list:
  | maybe_statement_list                  { [Body $1] }

maybe_alias_list:
  |                                       { [] }
  | alias_list                            { $1 }

alias_list:
  | alias alias_list                      { $1 :: $2 }
  | alias                                 { [$1] }

alias:
  | DEFINE Id base_operand                { $2, $3 }

maybe_statement_list:
  |                                       { [] }
  | statement_list                        { $1 }

statement_list:
  | statement statement_list              { $1 :: $2 }
  | statement                             { [$1] }

statement:
  | label_symbol                          { Label $1 }
  /* Instruction contains at least one argument */
  | Id operand_list                       { Instruction ($1, $2) }

operand_list:
  | operand COMMA operand_list            { $1 :: $3 }
  | operand                               { [$1] }

operand:
  | base_operand                          { $1 }
  | label_symbol                          { LabelRef $1 }

base_operand:
  | Num                                   { Imm $1 }
  | Id                                    { Var $1 }

label_symbol:
  | Id COLON                              { $1 }
