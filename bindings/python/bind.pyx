
class FSDB_Error(Exception):
    pass

cdef extern from "fsdb.h":
    """
    int c_store(const char * id, const char * buffer, size_t len) { return store(id, buffer, len); }
    int c_load(const char * id, char ** res, size_t * len) { return load(id, res, len); }
    """
    int c_store(const char * id, const char * buffer, size_t len)
    int c_load(const char * id, char ** res, size_t * len)


cdef extern from "stdlib.h":
    void free(void * ptr)


cdef extern from "Python.h":
    const char* PyUnicode_AsUTF8(object unicode)
    const int PyBytes_AsStringAndSize(object obj, char **buffer, Py_ssize_t *length)
    object PyBytes_FromStringAndSize(const char *v, Py_ssize_t len)


def store(id: str, buffer: bytes):
    cdef char* buffer_
    cdef Py_ssize_t size
    cdef int err

    PyBytes_AsStringAndSize(buffer, &buffer_, &size)
 
    err = c_store(
        PyUnicode_AsUTF8(id),
        buffer_,
        size,
    )

    if err != 0:
        raise FSDB_Error("Error during stores")


def load(id: str) -> bytes:
    cdef char * buffer
    cdef size_t len
    cdef int err

    err = c_load(
        PyUnicode_AsUTF8(id),
        &buffer,
        &len
    )

    if err != 0:
        raise FSDB_Error("Error during load")

    res = PyBytes_FromStringAndSize(buffer, len)

    free(buffer)

    return res

