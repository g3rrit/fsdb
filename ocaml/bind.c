
#include "stdlib.h"

//#include <caml/mlvalues.h>
//#include <caml/memory.h>
#include "/Users/pear/.opam/default/lib/ocaml/caml/mlvalues.h"
#include "/Users/pear/.opam/default/lib/ocaml/caml/memory.h"
#include "/Users/pear/.opam/default/lib/ocaml/caml/alloc.h"

#include "../include/fsdb.h"

#define Val_none Val_int(0)

static value
Val_some( value v ) {
    CAMLparam1( v );
    CAMLlocal1( some );
    some = caml_alloc(1, 0);
    Store_field( some, 0, v );
    CAMLreturn( some );
}

CAMLprim value store_wrapper(value id, value buffer, value len) {
    char const * _id = String_val(id);
    unsigned char const * _buffer = Bytes_val(buffer);
    size_t const _len = Int_val(len);

    int err = store(_id, (char*)_buffer, _len);

    return Val_bool(!err);
}

CAMLprim value load_wrapper(value id) {
    CAMLparam1(id);
    CAMLlocal1(ml_data);
    char const * _id = String_val(id);
    char * res = NULL;
    size_t len = 0;

    int err = load(_id, &res, &len);

    if (err) {
        CAMLreturn(Val_none);
        //ml_data = caml_alloc_initialized_string(0, NULL);
    } else {
        int _len = len;
        ml_data = caml_alloc_initialized_string(_len, res);
        free(res);
        CAMLreturn(Val_some(ml_data));
    }
}
