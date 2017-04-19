exception MLFailure of string

type operand =
  | Imm of int
  | Reg of string

type statement =
  | Label of string
  | Instruction of string * operand list

type program = statement list


type location = int * statement

let localize stmts =
  let rec localize' i stmts =
    match stmts with
    | s :: ss ->
      let curr_i = match s with
        | Label       _ -> i - 1
        | Instruction _ -> i
      in
        (curr_i, s) :: localize' (curr_i + 1) ss
    | _       -> []
  in
    localize' 0 stmts


let operand_to_string op =
  match op with
  | Imm i -> string_of_int i
  | Reg n -> n

let program_to_string stmts =
  let rec format_and_partition locs labels insts =
    match locs with
    | l :: ls ->
      let labels', insts' = match l with
        | i, Label l ->
          let str = Printf.sprintf "%d __label %s" i l in
            str :: labels, insts
        | i, Instruction (m, os) ->
          let arg_strs = List.map operand_to_string os in
          let i_str = string_of_int i in
          let str = String.concat " " (i_str :: m :: arg_strs) in
            labels, str :: insts
      in
        format_and_partition ls labels' insts'
    | _       -> labels, insts
  in
  let labels, insts = format_and_partition (localize stmts) [] [] in
  let rev_join ss = String.concat "\n" (List.rev ss) in
    rev_join labels ^ "\n\n" ^ rev_join insts
