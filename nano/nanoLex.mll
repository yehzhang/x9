{
  open Nano        (* nano.ml *)
  open NanoParse   (* nanoParse.ml from nanoParse.mly *)
}

let alphabetic = ['A'-'Z' 'a'-'z']
let numeric = ['0'-'9']
let alnum = ['A'-'Z' 'a'-'z' '0'-'9']

rule token = parse
  | eof                           { EOF }
  | [' ' '\n' '\r' '\t']          { token lexbuf }
  
  | "("                           { LPAREN }
  | ")"                           { RPAREN }

  | "["                           { LBRAC }
  | "]"                           { RBRAC }
  | "::"                          { COLONCOLON }
  | ";"                           { SEMI }

  | "+"                           { PLUS }
  | "-"                           { MINUS }
  | "*"                           { MUL }
  | "/"                           { DIV }
  | "="                           { EQ }
  | "!="                          { NE }
  | "<"                           { LT }
  | "<="                          { LE }
  | "&&"                          { AND }
  | "||"                          { OR }

  | "let"                         { LET }
  | "rec"                         { REC }
  | "fun"                         { FUN }
  | "->"                          { ARROW }
  | "if"                          { IF }
  | "then"                        { THEN }
  | "else"                        { ELSE }
  | "in"                          { IN }

  | "true"                        { TRUE }
  | "false"                       { FALSE }
  | numeric+ as l                 { Num (int_of_string l) }
  | alphabetic alnum* as l        { Id l }

  | _                             { raise (MLFailure ("Illegal Character '"^(Lexing.lexeme lexbuf)^"'")) }
