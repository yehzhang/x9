OCAML_C	  = ocamlc

OCAML_LEX	= ocamllex
OCAML_YACC   = ocamlyacc

OCAML_LIB_OBJ  = nano nanoParse nanoLex
OCAML_EXE_OBJ  = $(OCAML_LIB_OBJ) main
OCAML_EXE	   = translator

MLYS		   = nanoParse.mly
MLLS		   = nanoLex.mll


all: $(OCAML_EXE)

$(OCAML_EXE): $(OCAML_EXE_OBJ:%=%.cmo)
	$(OCAML_C) -o $@ $(OCAML_EXE_OBJ:%=%.cmo)

%.cmi: %.mli
	$(OCAML_C) -c $<

%.cmo: %.ml
	$(OCAML_C) -c $<

%.ml: %.mll
	$(OCAML_LEX) $<

%.ml %.mli: %.mly
	$(OCAML_YACC) $<
	$(OCAML_C) -c $(@:%.ml=%.mli)

# ocamllex nanoLex.mll
# ocamlyacc nanoParse.mly
# ocamlc -c nano.ml
# ocamlc -c nanoParse.mli
# ocamlc -c nanoLex.ml
# ocamlc -c nanoParse.ml
# ocamlc -c main.ml
# ocamlc -o translator nano.cmo nanoLex.cmo nanoParse.cmo main.cmo

clean:
	rm -f *~ *.o *.cmo *.cmx .*.depend *.cmi

distclean: clean
	rm -f *.cmi *.annot $(TODO) $(MLYS:%.mly=%.mli) $(MLYS:%.mly=%.ml) \
	$(MLLS:%.mll=%.ml) *.output $(OCAML_EXE)

.PHONY : all clean distclean


# ifdef C_EXE
# $(C_EXE): $(C_CPP_EXE_OBJ:%=%.o)
# 	@echo Linking C program $@
# 	$(C_LD) $(C_CPP_LD_FLAGS) -o $@ $(C_CPP_EXE_OBJ:%=%.o) $(C_CPP_LD_LIBS)
# endif

# ifdef CPP_EXE
# $(CPP_EXE): $(C_CPP_EXE_OBJ:%=%.o)
# 	@echo Linking C++ program $@
# 	$(CPP_LD) $(C_CPP_LD_FLAGS) -o $@ $(C_CPP_EXE_OBJ:%=%.o) $(C_CPP_LD_LIBS)
# endif

# ifdef C_CPP_LIB
# $(C_CPP_LIB).a: $(C_CPP_LIB_OBJ:%=%.o)
# 	@echo Creating C/C++ library $@
# 	$(AR) r $@ $?
# 	$(RANLIB) $@
# endif

# ifdef OCAML_EXE
# $(OCAML_EXE).byte: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
# 	@echo Linking OCAML \(byte code\) program $@
# 	$(OCAML_LD) $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)

# $(OCAML_EXE).opt: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmx)
# 	@echo Linking OCAML \(native code\) program $@
# 	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -o $@ $(OCAML_LD_LIBS:%=%.cmxa) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmx)

# $(OCAML_EXE).top: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
# 	@echo Linking OCAML \(top level\) program $@
# 	$(OCAML_MKTOP)   $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)

# endif

# ifdef OCAML_TPL_EXE
# $(OCAML_TPL_EXE).byte: $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo)
# 	@echo Linking OCAML \(byte code\) toplevel $@
# 	$(OCAML_MKTOP) $(OCAML_LD_FLAGS) -o $@ -custom $(OCAML_LD_LIBS:%=%.cma) $(C_CPP_EXE_OBJ:%=%.o) $(OCAML_EXE_OBJ:%=%.cmo) \
# 	-cc $(CPP_C) -cclib '$(C_CPP_LD_FLAGS) $(C_CPP_LD_LIBS)'
# endif

# ifdef OCAML_LIB
# $(OCAML_LIB).cma: $(OCAML_LIB_OBJ:%=%.cmo)
# 	@echo Creating OCAML \(byte code\) library $@
# 	$(OCAML_LD) $(OCAML_LD_FLAGS) -a -o $@ $(OCAML_LIB_OBJ:%=%.cmo)

# $(OCAML_LIB).cmxa $(OCAML_LIB).a: $(OCAML_LIB_OBJ:%=%.cmx)
# 	@echo Creating OCAML \(native code\) library $@
# 	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -a -o $@ $(OCAML_LIB_OBJ:%=%.cmx)
# endif

# ifdef OCAML_CINTF
# ifdef OCAML_BYTECODE_CINTF
# $(OCAML_CINTF).o: $(OCAML_CINTF_OBJ:%=%.cmo)
# 	@echo Creating OCAML \(native code\) C interface library $@
# 	$(OCAML_LD) $(OCAML_LD_FLAGS) -output-obj -o $@ $(OCAML_LD_LIBS:%=%.cma) $(OCAML_CINTF_OBJ:%=%.cmo)

# $(OCAML_CINTF_LIB).a: $(OCAML_CINTF).o $(C_CPP_CINTF_OBJ:%=%.o)
# 	@echo Creating C/C++ interface library $@
# 	$(AR) r $@ $?
# 	$(RANLIB) $@
# else
# $(OCAML_CINTF).o: $(OCAML_CINTF_OBJ:%=%.cmx)
# 	@echo Creating OCAML \(native code\) C interface library $@
# 	$(OCAML_OPT_LD) $(OCAML_LD_FLAGS) -output-obj -o $@ $(OCAML_LD_LIBS:%=%.cmxa) $(OCAML_CINTF_OBJ:%=%.cmx)

# $(OCAML_CINTF_LIB).a: $(OCAML_CINTF).o $(C_CPP_CINTF_OBJ:%=%.o)
# 	@echo Creating C/C++ interface library $@
# 	$(AR) r $@ $?
# 	$(RANLIB) $@
# endif
# endif



# # Generic dependencies creation rules

# .%.mli.depend: %.mli
# 	@echo Generating dependencies for OCAML interface $<
# 	$(OCAML_DEP) $< > $@

# .%.ml.depend: %.ml
# 	@echo Generating dependencies for OCAML module $<
# 	$(OCAML_DEP) $< > $@


# # Dependencies

# -include $(MODULES:%=.%.ml.depend) $(MODULES:%=.%.mli.depend)
