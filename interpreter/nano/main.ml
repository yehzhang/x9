let to_program buf = NanoParse.program NanoLex.token buf

let filename_to_program f = to_program (Lexing.from_channel (open_in f))

let string_to_program s = to_program (Lexing.from_string s)

let translate f =
  try
    Nano.program_to_string (filename_to_program f)
  with exn -> "Error: " ^ (Printexc.to_string exn) ^ "\n"


let _ =
  try
    Printf.printf "%s\n" (translate Sys.argv.(1))
  with _ -> ()
