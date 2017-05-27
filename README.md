# x9
x9 is an instruction set architecture for a 9-bit processor. x9 is especially designed to run three programs in `targets/`: `cordic_x9.s`, `string_match_x9.s`, and `div_x9.s`.


## Components
+ An interpreter at `python/interpreter/`: Python module that executes x9 assembly code. The entry point to run the interpreter on each of the three programs is `python/interpreter_runner.py`.
+ An assembler at `python/interpreter/assembler.py`: Python module that translates x9 assembly code into machine code suitable for the processor. This module is built upon the framework of the interpreter. The entry point to run the assembler is `python/assembler_runner.py`.
+ `Nano` at `python/interpreter/nano/`: OCaml module that translates x9 assembly code into an intermediate representation that can be easily parsed with several lines of Python code. This modules is used by the framework that underlies the interpreter.
+ `verilog/`: SystemVerilog modules defining the processor.
+ `targets/`: machine code, assembly code, and their corresponding c code.


## Green Sheet
TODO
