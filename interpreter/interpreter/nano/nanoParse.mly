%{
open Nano
%}

%token EOF
%token <int> Num
%token <string> Id
%token COLON
%token COMMA
%token EQUAL

%start program
%type <Nano.program> program

%%

program:
  | maybe_section_list { $1, $2 }

maybe_section_list:
  |                                       { [] }
  | section_list                          { $1 }

section_list:
  | maybe_alias_list section_list         { AliasSection $1 :: $2 }
  | maybe_statement_list                  { [StatementSection $1] }

maybe_alias_list:
  |                                       { [] }
  | alias_list                            { $1 }

alias_list:
  | alias alias_list                      { $1 :: $2 }
  | alias                                 { [$1] }

alias:
  | Id EQUAL operand                      { Alias ($1, $3) }

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
  | Num                                   { Imm $1 }
  | Id                                    { Reg $1 }
  | label_symbol                          { LabelRef $1 }

label_symbol:
  | Id COLON                              { $1 }
