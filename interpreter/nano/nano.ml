exception MLFailure of string

type operand =
  | Imm of int
  | Reg of string

type statement =
  | Label of string
  | Instruction of string * operand list

type program = statement list


let operand_to_string op =
  match op with
  | Imm i -> string_of_int i
  | Reg n -> n

let statement_to_string s =
  match s with
  | Label l -> "__label " ^ l
  | Instruction (m, os) ->
    let arg_strs = List.map operand_to_string os in
      String.concat " " (m :: arg_strs)


let program_to_string ss = String.concat "\n" (List.map statement_to_string ss)
