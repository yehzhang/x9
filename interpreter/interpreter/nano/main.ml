let to_program lexbuf =
  try
    NanoParse.program NanoLex.token lexbuf
  with exn -> (
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    let _ = Printf.printf "Invalid token: '%s' at line %d column %d\n" tok line cnum in
      raise exn
  )

let filename_to_program f = to_program (Lexing.from_channel (open_in f))

let string_to_program s = to_program (Lexing.from_string s)

let translate f =
  try
    Nano.program_to_string (filename_to_program f)
  with exn -> "Error: " ^ (Printexc.to_string exn)

let _ =
  try
    Printf.printf "%s\n" (translate Sys.argv.(1))
  with _ -> ()
