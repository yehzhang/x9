{
  open Nano        (* nano.ml *)
  open NanoParse   (* nanoParse.ml from nanoParse.mly *)
}

let letter = ['A'-'Z' 'a'-'z' '_']
let digit = ['0'-'9']
let alnum = letter | digit

let dec = digit+
let bin = '0' ['b' 'B'] ['0'-'1']+
let oct = '0' ['o' 'O'] ['0'-'7']+
let hex = '0' ['x' 'X'] (digit | ['a'-'f' 'A'-'F'])+
let number_literal = dec | bin | oct | hex

rule token = parse
  | eof                           { EOF }
  | [' ' '\r' '\t']               { token lexbuf }
  | "#" [^'\n']*                  { token lexbuf }
  | ['\n']                        { let _ = Lexing.new_line lexbuf in token lexbuf }

  | ":"                           { COLON }
  | ","                           { COMMA }

  | "define"                      { DEFINE }

  | number_literal as l           { Num (int_of_string l) }
  | letter alnum* as l            { Id l }

  | _                             { raise (MLFailure ("Illegal Character '"^(Lexing.lexeme lexbuf)^"'")) }
