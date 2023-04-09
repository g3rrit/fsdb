CC = gcc
CFLAGS = -Werror -Wall -Wextra -pedantic -O3 -std=c11
BUILD_DIR := build
SRC_DIR := src

LIB_ = libfsdb.a
OBJS_ = fsdb.o

LIB = $(addprefix $(BUILD_DIR)/, $(LIB_))
OBJS = $(addprefix $(BUILD_DIR)/, $(OBJS_))

all: build $(LIB) python ocaml

$(LIB): $(OBJS)
	ar -r $@ $?
	gcc -shared -o $(BUILD_DIR)/libfsdb.so $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

# BINDINGS
PYTHON_DIR = python
PYTHON_BUILD_DIR = $(BUILD_DIR)/python

OCAML_DIR = ocaml
OCAML_BUILD_DIR = $(BUILD_DIR)/ocaml
OCAML_INC ?= $(HOME)/.opam/default/lib/ocaml

# PYTHON
python: build
	cp src/fsdb.c $(PYTHON_DIR)/fsdb.c
	cp include/fsdb.h $(PYTHON_DIR)/fsdb.h
	cd $(PYTHON_DIR) && python3 setup.py sdist --dist-dir=../$(PYTHON_BUILD_DIR)
	rm -rf $(PYTHON_DIR)/fsdb.egg-info 
	rm -rf $(PYTHON_DIR)/bind.c
	rm -rf $(PYTHON_DIR)/fsdb.c
	rm -rf $(PYTHON_DIR)/fsdb.h

# OCAML
ocaml: build $(OCAML_BUILD_DIR)/fsdb.cmxa

$(OCAML_BUILD_DIR)/fsdb.cmxa: $(OCAML_DIR)/fsdb.ml $(OCAML_DIR)/fsdb.ml $(OCAML_DIR)/bind.c
	cd $(OCAML_BUILD_DIR) && ocamlc -c -o fsdb.cmi ../../$(OCAML_DIR)/fsdb.mli
	cd $(OCAML_BUILD_DIR) && ocamlc -c -ccopt -I$(OCAML_INC) -o bind.o ../../$(OCAML_DIR)/bind.c
	cd $(OCAML_BUILD_DIR) && ocamlmklib -o bind bind.o
	cd $(OCAML_BUILD_DIR) && ocamlopt -c -o fsdb.cmx ../../$(OCAML_DIR)/fsdb.ml
	cd $(OCAML_BUILD_DIR) && ocamlopt -linkall -a -o fsdb.cmxa $(abspath $(BUILD_DIR)/libfsdb.a) $(abspath $(OCAML_BUILD_DIR)/libbind.a) fsdb.cmx

# Link with:
# ocamlopt -I ../build/ocaml -o a.out ../build/ocaml/fsdb.cmxa example.ml

# OTHER

build:
	mkdir -p build
	mkdir -p build/python
	mkdir -p build/ocaml

clean:
	rm -rf build/*

.PHONY: all clean build python ocaml
