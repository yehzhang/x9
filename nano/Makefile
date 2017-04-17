DEBUG = 1

SHELL        = /bin/sh

C_C          = gcc
CPP_C        =
ifdef GPROF
C_CPP_FLAGS = -pg -O3
else
ifndef DEBUG
C_CPP_FLAGS  = -O3
else
C_CPP_FLAGS  = -g
endif
endif
C_LD         = $(C_C)
CPP_LD       = $(CPP_C)

C_YACC       = bison
C_LEX        = flex

AR           = ar
RANLIB       = ranlib

OCAML_C      = ocamlc
OCAML_OPT_C  = ocamlopt
ifdef GPROF
OCAML_C_FLAGS     = -dtypes
OCAML_OPT_C_FLAGS = -dtypes
OCAML_LD     = $(OCAML_C) -g
OCAML_OPT_LD = $(OCAML_OPT_C) -p
else
ifndef DEBUG
OCAML_C_FLAGS     = -dtypes
OCAML_OPT_C_FLAGS = -dtypes
OCAML_LD     = $(OCAML_C) -g
OCAML_OPT_LD = $(OCAML_OPT_C)
else
OCAML_C_FLAGS     = -dtypes
OCAML_OPT_C_FLAGS = -dtypes
OCAML_LD     = $(OCAML_C) -g
OCAML_OPT_LD = $(OCAML_OPT_C)
endif
endif
OCAML_MKTOP  = ocamlmktop
OCAML_CP     = ocamlcp
OCAML_DEP    = ocamldep
OCAML_LEX    = ocamllex
OCAML_YACC   = ocamlyacc

OCAML_C_CPP_INC = -I $(shell $(OCAML_C) -v | tail -1 | sed -e \
                             's/^Standard library directory: //')


OCAML_LIB_OBJ  = nano \
                 nanoLex \
                 nanoParse
OCAML_EXE_OBJ  = $(OCAML_LIB_OBJ) main
OCAML_EXE      = nanoml

MODULES        = $(OCAML_EXE_OBJ)
MLYS           = nanoParse.mly
MLLS           = nanoLex.mll

#TODO           = $(OCAML_EXE).top $(OCAML_EXE).byte $(OCAML_EXE).opt
TODO           = $(OCAML_EXE).top $(OCAML_EXE).byte

all:: $(TODO)

mactop: $(OCAML_EXE).byte
	ocamlmktop -o nanoml.top -custom nano.cmo nanoLex.cmo nanoParse.cmo main.cmo

clean: default-clean

distclean: clean
	rm -f *.cmi *.annot $(TODO) $(MLYS:%.mly=%.mli) $(MLYS:%.mly=%.ml) \
	$(MLLS:%.mll=%.ml)

turnin: distclean
	zip pa4-soln.zip *
	turnin -c cs130f -p pa4 pa4-soln.zip

.SECONDARY: $(MLYS:%.mly=%.mli) $(MLYS:%.mly=%.ml) $(MLLS:%.mll=%.ml)

.PHONY : all clean distclean

# Implicit rules

# Generic compilation rules

%.o : %.c
	@echo Compiling C file $<
	$(C_C) $(C_CPP_FLAGS) $(C_CPP_INCLUDES) -c $< -o $@

%.o : %.cc
	@echo Compiling C++ file $<
	$(CPP_C) $(C_CPP_FLAGS) $(C_CPP_INCLUDES) -c $< -o $@

%.o : %.cpp
	@echo Compiling C++ file $<
	$(CPP_C) $(C_CPP_FLAGS) $(C_CPP_INCLUDES) -c $< -o $@

%.cmi: %.mli
	@echo Compiling OCAML interface $<
	$(OCAML_C) $(OCAML_C_FLAGS) $(OCAML_INCLUDES) -c $< -o $@

%.cmo: %.ml
	@echo Compiling \(to byte code\) OCAML module $<
	$(OCAML_C) $(OCAML_C_FLAGS) $(OCAML_INCLUDES) -c $< -o $@

%.cmx: %.ml
	@echo Compiling \(to native code\) OCAML module $<
	$(OCAML_OPT_C) $(OCAML_OPT_C_FLAGS) $(OCAML_INCLUDES) -c $< -o $@

%.ml: %.mll
	@echo Lexing OCAML file $<
	$(OCAML_LEX) $<

%.ml %.mli: %.mly
	@echo Yaccing OCAML file $<
	$(OCAML_YACC) $<



# Generic cleaning rules

default-clean:
	rm -f *~ *.o *.cmo *.cmx .*.depend *.cmi

.PHONY:	default-clean



# Generic link rules and library creation rules
#
# These rules assume that the following variables are set (when necessary):
#
# - C_EXE          : name of the C executable
# - CPP_EXE        : name of the C++ executable
# - OCAML_EXE      : name of the OCaml executable (without suffix)
# - OCAML_TPL_EXE  : name of the OCaml custom toplevel (without suffix)
# - C_CPP_LIB      : name of the C/C++ library
# - OCAML_LIB      : name of the OCaml library (without suffix)
# - C_CPP_EXE_OBJ  : list of C/C++ objects (without suffix) to build exe
# - OCAML_EXE_OBJ  : list of OCaml modules (without suffix) to build exe
# - C_CPP_LIB_OBJ  : list of C/C++ objects (without suffix) to build lib
# - OCAML_LIB_OBJ  : list of OCaml modules (without suffix) to build lib
# - C_CPP_LD_FLAGS : C and C++ linker flags
# - OCAML_LD_FLAGS : OCaml linker (both native and bytecode) flags
# - C_CPP_LD_LIBS  : C and C++ linker libraries
# - OCAML_LD_LIBS  : OCaml linker (both native and bytecode) libraries

ifdef C_EXE
$(C_EXE): $(C_CPP_EXE_OBJ:%=%.o)
	@echo Linking C program $@
	$(C_LD) $(C_CPP_LD_FLAGS) -o $@ $(C_CPP_EXE_OBJ:%=%.o) $(C_CPP_LD_LIBS)
endif

ifdef CPP_EXE
$(CPP_EXE): $(C_CPP_EXE_OBJ:%=%.o)
	@echo Linking C++ program $@
	$(CPP_LD) $(C_CPP_LD_FLAGS) -o $@ $(C_CPP_EXE_OBJ:%=%.o) $(C_CPP_LD_LIBS)
endif

ifdef C_CPP_LIB
$(C_CPP_LIB).a: $(C_CPP_LIB_OBJ:%=%.o)
	@echo Creating C/C++ library $@
	$(AR) r $@ $?
	$(RANLIB) $@
endif

ifdef OCAML_EXE
$(OCAML_EXE).byte: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
	@echo Linking OCAML \(byte code\) program $@
	$(OCAML_LD) $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)

$(OCAML_EXE).opt: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmx)
	@echo Linking OCAML \(native code\) program $@
	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -o $@ $(OCAML_LD_LIBS:%=%.cmxa) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmx)

$(OCAML_EXE).top: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
	@echo Linking OCAML \(top level\) program $@
	$(OCAML_MKTOP)   $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)

endif

ifdef OCAML_TPL_EXE
$(OCAML_TPL_EXE).byte: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
	@echo Linking OCAML \(byte code\) toplevel $@
	$(OCAML_MKTOP) $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo) \
	-cc $(CPP_C) -cclib '$(C_CPP_LD_FLAGS) $(C_CPP_LD_LIBS)'
endif

ifdef OCAML_LIB
$(OCAML_LIB).cma: $(OCAML_LIB_OBJ:%=%.cmo)
	@echo Creating OCAML \(byte code\) library $@
	$(OCAML_LD) $(OCAML_LD_FLAGS) -a -o $@ $(OCAML_LIB_OBJ:%=%.cmo)

$(OCAML_LIB).cmxa $(OCAML_LIB).a: $(OCAML_LIB_OBJ:%=%.cmx)
	@echo Creating OCAML \(native code\) library $@
	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -a -o $@ $(OCAML_LIB_OBJ:%=%.cmx)
endif

ifdef OCAML_CINTF
ifdef OCAML_BYTECODE_CINTF
$(OCAML_CINTF).o: $(OCAML_CINTF_OBJ:%=%.cmo)
	@echo Creating OCAML \(native code\) C interface library $@
	$(OCAML_LD) $(OCAML_LD_FLAGS) -output-obj -o $@ $(OCAML_LD_LIBS:%=%.cma) $(OCAML_CINTF_OBJ:%=%.cmo)

$(OCAML_CINTF_LIB).a: $(OCAML_CINTF).o $(C_CPP_CINTF_OBJ:%=%.o)
	@echo Creating C/C++ interface library $@
	$(AR) r $@ $?
	$(RANLIB) $@
else
$(OCAML_CINTF).o: $(OCAML_CINTF_OBJ:%=%.cmx)
	@echo Creating OCAML \(native code\) C interface library $@
	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -output-obj -o $@ $(OCAML_LD_LIBS:%=%.cmxa) $(OCAML_CINTF_OBJ:%=%.cmx)

$(OCAML_CINTF_LIB).a: $(OCAML_CINTF).o $(C_CPP_CINTF_OBJ:%=%.o)
	@echo Creating C/C++ interface library $@
	$(AR) r $@ $?
	$(RANLIB) $@
endif
endif



# Generic dependencies creation rules

.%.mli.depend: %.mli
	@echo Generating dependencies for OCAML interface $<
	$(OCAML_DEP) $< > $@

.%.ml.depend: %.ml
	@echo Generating dependencies for OCAML module $<
	$(OCAML_DEP) $< > $@


# Dependencies

-include $(MODULES:%=.%.ml.depend) $(MODULES:%=.%.mli.depend)
