#include <sys/file.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#define FILE_PATH_SIZE 512
#define DEFAULT_DIR ".fsdb/"


int get_file_path(char const * const id, char * const path, size_t const path_len)
{
  if (path_len <= 1) {
    return 1;
  }

  size_t const id_len = strlen(id);
  size_t remaining_len = path_len - 1;
  int root_in_home = 0;

  char const * root_dir = NULL;

  root_dir = getenv("FSDB_ROOT");

  if (root_dir == NULL) {
    root_dir = getenv("HOME");
    root_in_home = 1;
  }

  if (root_dir == NULL) {
    return 1;
  }

  size_t const root_dir_len = strlen(root_dir);

  if (root_dir_len >= remaining_len) {
    return 1;
  }

  strncpy(path, root_dir, remaining_len);
  remaining_len -= strlen(root_dir);

  if (remaining_len <= 1) {
    return 1;
  }

  strncat(path, "/", 1);
  remaining_len -= 1;

  if (root_in_home) {
    size_t default_dir_len = strlen(DEFAULT_DIR);
    if (remaining_len <= default_dir_len) {
      return 1;
    }

    strncat(path, DEFAULT_DIR, default_dir_len);
    remaining_len -= default_dir_len;
  }

  if (remaining_len <= id_len) {
    return 1;
  }

  strncat(path, id, remaining_len);

  return 0;
}

int store(char const * const id, char const * const buffer, size_t const len)
{
  char file_path[FILE_PATH_SIZE] = { 0 };

  if (get_file_path(id, file_path, FILE_PATH_SIZE)) {
    return 1;
  }

  int fd = open(file_path, O_CREAT | O_WRONLY, 0666);

  if (!fd) {
    return 1;
  }

  if (flock(fd, LOCK_EX)) {
    close(fd);
    return 1;
  }

  if (ftruncate(fd, len)) {
    close(fd);
    flock(fd, LOCK_UN);
    return 1;
  }

  for (size_t total_bytes_written = 0; total_bytes_written < len;) {
    ssize_t bytes_written = write(fd, (char*)buffer + total_bytes_written, len - total_bytes_written);
    if (bytes_written <= 0) {
      flock(fd, LOCK_UN);
      close(fd);
      return 1;
    }
    total_bytes_written += bytes_written;
  }

  flock(fd, LOCK_UN);
  close(fd);
  return 0;
}

int load(char const * const id, char ** const res, size_t * const len) {

  *res = NULL;
  *len = 0;

  char file_path[FILE_PATH_SIZE] = { 0 };

  if (get_file_path(id, file_path, FILE_PATH_SIZE)) {
    return 1;
  }

  int fd = open(file_path, O_RDONLY);

  if (!fd) {
    return 1;
  }

  if (flock(fd, LOCK_EX)) {
    close(fd);
    return 1;
  }

  off_t const _len = lseek(fd, 0, SEEK_END);
  lseek(fd, 0, SEEK_SET);

  if (_len <= 0) {
    flock(fd, LOCK_UN);
    close(fd);
    return 1;
  }

  *len = _len;

  *res = malloc((size_t) _len);

  if (res == NULL) {
    flock(fd, LOCK_UN);
    close(fd);
    return 1;
  }

  for (size_t total_bytes_read = 0; total_bytes_read < *len;) {
    ssize_t bytes_read = read(fd, (char*)*res + total_bytes_read, *len - total_bytes_read);
    if (bytes_read < 0) {
      flock(fd, LOCK_UN);
      close(fd);
      free(*res);
      *res = NULL;
      return 1;
    }
    total_bytes_read += bytes_read;
  }

  flock(fd, LOCK_UN);
  close(fd);

  return 0;
}
