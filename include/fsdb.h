#ifndef FSDB_H
#define FSDB_H

#include <stdlib.h>

int store(char const * id, char const * buffer, size_t len);

int load(char const * id, char ** res, size_t * len);

#endif /* FSDB_H */

