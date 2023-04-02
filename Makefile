
CC = gcc
CFLAGS = -Werror -Wall -Wextra -pedantic -O3 -std=c11
BUILD_DIR := build
SRC_DIR := src

LIB_ = libfsdb.a
OBJS_ = fsdb.o

LIB = $(addprefix $(BUILD_DIR)/, $(LIB_))
OBJS = $(addprefix $(BUILD_DIR)/, $(OBJS_))

all: build $(LIB) binding_python

binding_python: build $(LIB)
	cd bindings/python && \
		python3 setup.py sdist --dist-dir=../../$(BUILD_DIR)/python && \
		rm -rf fsdb.egg-info fsdb.c ../src ../include fsdb.c fsdb.h bind.c

clean:
	rm -rf build/*

$(LIB): $(OBJS)
	ar -r $@ $?

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $^

#%.so:
#	ocamlc -a -o $@ $^
#
#%.o: %.ml
#	ocamlc -c -o $@ $^

build:
	mkdir -p build
	mkdir -p build/python


.PHONY: all clean build
