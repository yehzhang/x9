exception MLFailure of string

type operand =
  | Imm of string
  | Var of string
  | LabelRef of string

type statement =
  | Label of string
  | Instruction of string * operand list

type section =
  | AliasHeader of (string * operand) list
  | Body of statement list

type program = section list


let operand_to_string op =
  match op with
  | Imm      i -> i
  | Var      n -> n
  | LabelRef n -> n

let stmt_to_string stmt =
  match stmt with
  | Label       n       -> Printf.sprintf "label %s" n
  | Instruction (m, os) -> String.concat " " (m :: List.map operand_to_string os)

let alias_to_string (a, o) =
  Printf.sprintf "alias %s %s" a (operand_to_string o)

let section_to_string sec =
  let lns = match sec with
    | AliasHeader als -> List.map alias_to_string als
    | Body        ss  -> List.map stmt_to_string ss
  in
    String.concat "\n" lns

let program_to_string secs =
  String.concat "\n\n" (List.map section_to_string secs)
