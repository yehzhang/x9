{
  open Nano        (* nano.ml *)
  open NanoParse   (* nanoParse.ml from nanoParse.mly *)
}

let letter = ['A'-'Z' 'a'-'z']
let digit = ['0'-'9']
let alnum = letter | digit

rule token = parse
  | eof                           { EOF }
  | [' ' '\n' '\r' '\t']          { token lexbuf }
  | "#" [^'\n']*                  { token lexbuf }

  | ":"                           { COLON }
  | ","                           { COMMA }

  | digit+ as l                   { Num (int_of_string l) }
  | letter alnum* as l            { Id l }

  | _                             { raise (MLFailure ("Illegal Character '"^(Lexing.lexeme lexbuf)^"'")) }
