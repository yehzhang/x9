let to_program lexbuf =
  try
    NanoParse.program NanoLex.token lexbuf
  with exn -> (
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    let _ = Printf.printf "Error: %s. Invalid token: '%s' at line %d column %d\n"
        (Printexc.to_string exn) tok line cnum in
      exit 1
  )

let filename_to_program f = to_program (Lexing.from_channel (open_in f))

let string_to_program s = to_program (Lexing.from_string s)

let translate f = Nano.program_to_string (filename_to_program f)

let _ = Printf.printf "%s\n" (translate Sys.argv.(1))
