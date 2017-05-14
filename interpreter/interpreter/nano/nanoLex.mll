{
  open Nano        (* nano.ml *)
  open NanoParse   (* nanoParse.ml from nanoParse.mly *)
}

let letter = ['A'-'Z' 'a'-'z' '_']
let digit = ['0'-'9']
let alnum = letter | digit

rule token = parse
  | eof                           { EOF }
  | [' ' '\r' '\t']               { token lexbuf }
  | "#" [^'\n']*                  { token lexbuf }
  | ['\n']                        { let _ = Lexing.new_line lexbuf in token lexbuf }

  | ":"                           { COLON }
  | ","                           { COMMA }

  | "define"                      { DEFINE }

  | ('0' ['b' 'x' 'o'])? digit+ as l { Num (int_of_string l) }
  | letter alnum* as l            { Id l }

  | _                             { raise (MLFailure ("Illegal Character '"^(Lexing.lexeme lexbuf)^"'")) }
