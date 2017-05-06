exception MLFailure of string

type operand =
  | Imm of int
  | Reg of string
  | LabelRef of string

type statement =
  | Label of string
  | Instruction of string * operand list

type alias = string * operand

type section =
  | AliasSection of alias list
  | StatementSection of statement list

type program = section list


let operand_to_string op =
  match op with
  | Imm      i -> string_of_int i
  | Reg      n -> n
  | LabelRef n -> n

let stmt_to_string stmt =
  match stmt with
  | Label       n       -> Printf.sprintf "label %s" n
  | Instruction (m, os) -> String.concat " " (m :: List.map operand_to_string os)

let decl_to_string decl =
  match decl with
  | Alias     (a, o) -> Printf.sprintf "alias %s %s" a (operand_to_string o)
  | Statement s      -> stmt_to_string s

let program_to_string sections =
  let alias_section, stmt_section = sections in
  let section = String.concat "\n" (List.map decl_to_string stmts)

(*
  let rec format_and_partition locs labels insts =
    match locs with
    | l :: ls ->
      let labels', insts' = match l with
        | i, Label l ->
          let str = Printf.sprintf "%d label %s" i l in
            str :: labels, insts
        | i, Instruction (m, os) ->
          let arg_strs = List.map operand_to_string os in
          let i_str = string_of_int i in
          let str = String.concat " " (i_str :: m :: arg_strs) in
            labels, str :: insts
        | i, Alias (l, o) ->
          let str = Printf.sprintf "alias %s" i l in
            str :: labels, insts
      in
        format_and_partition ls labels' insts'
    | _       -> labels, insts
  in
  let labels, insts = format_and_partition (localize stmts) [] [] in
  let rev_join ss = String.concat "\n" (List.rev ss) in
    rev_join labels ^ "\n\n" ^ rev_join insts


    type location = int * statement

    let localize stmts =
      let rec localize' i stmts =
        match stmts with
        | s :: ss ->
          let curr_i = match s with
            | Label _ -> i - 1
            | Instruction _ -> i
          in
            (curr_i, s) :: localize' (curr_i + 1) ss
        | _       -> []
      in
      (* Padding for the potential label before the first instruction *)
      let init_inst_loc = 0, Instruction("nop", []) in
        init_inst_loc :: localize' 1 stmts

 *)