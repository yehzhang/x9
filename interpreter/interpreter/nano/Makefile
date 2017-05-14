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

main.cmo: $(OCAML_EXE_OBJ:%=%.cmo)
	$(OCAML_C) -c main.ml

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

debug:
	$(OCAML_YACC) -v nanoParse.mly
	cat nanoParse.output

.PHONY : all clean distclean
