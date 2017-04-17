exception MLFailure of string

type binop =
  Plus
| Minus
| Mul
| Div
| Eq
| Ne
| Lt
| Le
| And
| Or
| Cons

type expr =
  Const of int
| True
| False
| NilExpr
| Var of string
| Bin of expr * binop * expr
| If  of expr * expr * expr
| Let of string * expr * expr
| App of expr * expr
| Fun of string * expr
| Letrec of string * expr * expr
  
type value =
  Int of int
| Bool of bool
| Closure of env * string option * string * expr
| Nil
| Pair of value * value
| BuiltinFunc of (value -> value)

and env = (string * value) list


let binopToString op =
  match op with
      Plus -> "+"
    | Minus -> "-"
    | Mul -> "*"
    | Div -> "/"
    | Eq -> "="
    | Ne -> "!="
    | Lt -> "<"
    | Le -> "<="
    | And -> "&&"
    | Or -> "||"
    | Cons -> "::"

let rec valueToString v =
  match v with
    Int i ->
      Printf.sprintf "%d" i
  | Bool b ->
      Printf.sprintf "%b" b
  | Closure (evn,fo,x,e) ->
      let fs = match fo with
      | None -> "Anon"
      | Some fs -> fs
      in
        Printf.sprintf "{%s,%s,%s,%s}" (envToString evn) fs x (exprToString e)
  | Pair (v1,v2) ->
      Printf.sprintf "(%s::%s)" (valueToString v1) (valueToString v2)
  | Nil ->
      "[]"
  | BuiltinFunc _ ->
      "<Builtin Function>"

and envToString evn =
  let xs = List.map (fun (x,v) -> Printf.sprintf "%s:%s" x (valueToString v)) evn in
  "["^(String.concat ";" xs)^"]"

and exprToString e =
  match e with
      Const i ->
        Printf.sprintf "%d" i
    | True ->
        "true"
    | False ->
        "false"
    | NilExpr ->
        "[]"
    | Var x ->
        x
    | Bin (e1,op,e2) ->
        Printf.sprintf "%s %s %s"
        (exprToString e1) (binopToString op) (exprToString e2)
    | If (e1,e2,e3) ->
        Printf.sprintf "if %s then %s else %s"
        (exprToString e1) (exprToString e2) (exprToString e3)
    | Let (x,e1,e2) ->
        Printf.sprintf "let %s = %s in \n %s"
        x (exprToString e1) (exprToString e2)
    | App (e1,e2) ->
        Printf.sprintf "(%s %s)" (exprToString e1) (exprToString e2)
    | Fun (x,e) ->
        Printf.sprintf "fun %s -> %s" x (exprToString e)
    | Letrec (x,e1,e2) ->
        Printf.sprintf "let rec %s = %s in \n %s"
        x (exprToString e1) (exprToString e2)

(*********************** Some helpers you might need ***********************)

let rec fold f base args =
  match args with [] -> base
    | h::t -> fold f (f(base,h)) t

let listAssoc (k,l) =
  fold (fun (r,(t,v)) -> if r = None && k=t then Some v else r) None l

(*********************** Your code starts here ****************************)

let mlfailwith m = raise (MLFailure m)

let lookup (x,evn) =
  match listAssoc (x, evn) with
  | None -> mlfailwith "not found"
  | e -> e

let rec eval ((evn,e): env * expr): value =
  let mlFailWithType () = mlfailwith "invalid type" in
  let bin2int f (v1,v2) =
    match v1, v2 with
    | Int v1', Int v2' -> f v1' v2'
    | _ ->  mlFailWithType()
  in
  let bin2bool f (v1,v2) =
    match v1, v2 with
    | Bool v1', Bool v2' -> f v1' v2'
    | _ ->  mlFailWithType()
  in
  let bin2boolint f (v1,v2) =
    match v1, v2 with
    | Bool _, Bool _ | Int _, Int _ -> f v1 v2
    | _ ->  mlFailWithType()
  in
  let lib = [
    ("hd", BuiltinFunc (
      fun v -> (
        match v with
        | Pair (v1,_) -> v1
        | _ -> mlFailWithType())
    ));
    ("tl", BuiltinFunc (
      fun v -> (
        match v with
        | Pair (_,v2) -> v2
        | _ -> mlFailWithType())
    ))
  ] in

  let rec eval evn e =
    let eval1 e = eval evn e in
    let eval2 e1 e2 = eval1 e1, eval1 e2 in
    let evalLet fn (x,e1,e2) =
      let v =
        match e1 with
        | Fun (fx,fe) -> Closure (evn, fn, fx, fe)
        | _ -> eval1 e1
      in
        eval ((x, v) :: evn) e2
    in
      match e with
      | Const i -> Int i
      | True -> Bool true
      | False -> Bool false
      | Var x -> (
        try
          match lookup (x, evn) with
          | Some v -> v
          | None -> assert false
        with
        | MLFailure _ -> mlfailwith ("variable not bound: " ^ x))
      | NilExpr -> Nil
      | Bin (e1,op,e2) ->
        let res = eval2 e1 e2 in (
          match op with
          | Plus -> Int (bin2int (+) res)
          | Minus -> Int (bin2int (-) res)
          | Mul -> Int (bin2int ( * ) res)
          | Div -> Int (bin2int (fun x y -> if y = 0 then mlfailwith "divide by zero" else x / y) res)
          | Eq -> Bool (bin2boolint (=) res)
          | Ne -> Bool (bin2boolint (!=) res)
          | Lt -> Bool (bin2int (<) res)
          | Le -> Bool (bin2int (<=) res)
          | And -> Bool (bin2bool (&&) res)
          | Or -> Bool (bin2bool (||) res)
          | Cons -> let v1, v2 = res in Pair (v1, v2))
      | If (e1,e2,e3) -> (
        match eval1 e1 with
        | Bool cond -> eval1 (if cond then e2 else e3)
        | _ -> mlFailWithType())
      | Let (x,e1,e2) -> evalLet None (x,e1,e2)
      | Letrec (x,e1,e2) -> evalLet (Some x) (x,e1,e2)
      | App (e1,e2) ->
        let v1, v2 = eval2 e1 e2 in (
          match v1 with
          | Closure (evn,x,fx,fe) ->
            let evn' = (fx, v2) :: evn in
            let evn' =
              match x with
              | Some fn -> (fn, v1) :: evn'
              | None -> evn'
            in
              eval evn' fe
          | BuiltinFunc f -> f v2
          | _ -> mlFailWithType())
      | Fun (x,e) -> Closure (evn, None, x, e)
  in
    eval (lib @ evn) e

(**********************     Testing Code  ******************************)

   
let evn = [("z1",Int 0);("x",Int 1);("y",Int 2);("z",Int 3);("z1",Int 4)]

let e1  = Bin(Bin(Var "x",Plus,Var "y"), Minus, Bin(Var "z",Plus,Var "z1"))

let _   = eval (evn, e1)        (* EXPECTED: Nano.value = Int 0 *)

(* let _   = eval (evn, Var "p")   (* EXPECTED:  Exception: Nano.MLFailure "variable not bound: p". *) *)




let evn = [("z1",Int 0);("x",Int 1);("y",Int 2);("z",Int 3);("z1",Int 4)]
 
let e1  = If(Bin(Var "z1",Lt,Var "x"),Bin(Var "y",Ne,Var "z"),False)
  
let _   = eval (evn,e1)         (* EXPECTED: Nano.value = Bool true *)

let e2  = If(Bin(Var "z1",Eq,Var "x"),
                Bin(Var "y",Le,Var "z"),
                Bin(Var "z",Le,Var "y")
            )

let _   = eval (evn,e2)         (* EXPECTED: Nano.value = Bool false *)




let e1 = Bin(Var "x",Plus,Var "y")

let e2 = Let("x",Const 1, Let("y", Const 2, e1))

let _  = eval ([], e2)          (* EXPECTED: Nano.value = Int 3 *)

let e3 = Let("x", Const 1,
           Let("y", Const 2,
             Let("z", e1,
               Let("x", Bin(Var "x",Plus,Var "z"),
                 e1)
             )
           )
         )

let _  = eval ([],e3)           (* EXPCETED: Nano.value = Int 6 *)





let _ = eval ([], Fun ("x",Bin(Var "x",Plus,Var "x")))

(* EXPECTED: Nano.value = Closure ([], None, "x", Bin (Var "x", Plus, Var "x")) *)

let _ = eval ([],App(Fun ("x",Bin(Var "x",Plus,Var "x")),Const 3));;

(* EXPECTED: Nano.value = Int 6 *)

let e3 = Let ("h", Fun("y", Bin(Var "x", Plus, Var "y")),
               App(Var "f",Var "h"))
 
let e2 = Let("x", Const 100, e3)
 
let e1 = Let("f",Fun("g",Let("x",Const 0,App(Var "g",Const 2))),e2)

let _  = eval ([], e1)
    (* EXPECTED: Nano.value = Int 102 *)

let _ = eval ([],Letrec("f",Fun("x",Const 0),Var "f"))
    (* EXPECTED: Nano.value = Closure ([], Some "f", "x", Const 0) *)



 
let _ = eval ([],
              Letrec("fac",
                        Fun("n", If (Bin (Var "n", Eq, Const 0),
                                    Const 1,
                                    Bin(Var "n", Mul, App(Var "fac",Bin(Var "n",Minus,Const 1))))),
              App(Var "fac", Const 10)))

(* EXPECTED: Nano.value = Int 3628800 *)



 
let _ = eval ([],Bin(Const 1,Cons,Bin(Const 2,Cons,NilExpr)))

    (* EXPECTED: Nano.value = Pair (Int 1, Pair (Int 2, Nil)) *)

let _ = eval ([],App(Var "hd",Bin(Const 1,Cons,Bin(Const 2,Cons,NilExpr))))

    (* EXPECTED: Nano.value = Int 1 *)

let _ = eval ([],App(Var "tl",Bin(Const 1,Cons,Bin(Const 2,Cons,NilExpr))))
    
    (* EXPECTED: Nano.value = Pair (Int 2, Nil) *)

let e1 = Let ("f",
 Fun ("x",
  Fun ("y", Bin (Var "x", Plus, Var "y"))),
 Let ("g", App (Var "f", Const 10),
  App (Var "g", Const 100)))

