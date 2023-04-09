#ifndef FSDB_H
#define FSDB_H

#include <stdlib.h>

/**
 * @brief Store data.
 *
 * This function stores the given buffer in a file with the specified id.
 * If the id does not exist, it is created. If it exists, the old data is
 * replaced with the new data.
 *
 * @param[in] id The unique identifier for the data.
 * @param[in] buffer The buffer containing the data to store.
 * @param[in] len The length of the buffer.
 * @return 0 on success, non-zero on failure.
 */
int store(char const * id, char const * buffer, size_t len);

/**
 * @brief Load data.
 *
 * This function loads the data with the specified id into a
 * dynamically allocated buffer. The caller is responsible for freeing the
 * allocated buffer when it is no longer needed.
 *
 * @param[in] id The unique identifier for the file.
 * @param[out] res A pointer to the output buffer containing the loaded data.
 * @param[out] len A pointer to the length of the loaded data.
 * @return 0 on success, non-zero on failure.
 */
int load(char const * id, char ** res, size_t * len);

#endif /* FSDB_H */

