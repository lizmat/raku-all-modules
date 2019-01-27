#ifndef _PATH_H
#define _PATH_H

struct path_model {
  int* topics;
};

struct path_model* lda_create_path(int length);
void lda_delete_path(struct path_model*);

#endif /* _PATH_H */

