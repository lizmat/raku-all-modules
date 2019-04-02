#include <stdlib.h>
#include <string.h>
#include "path.h"

struct path_model* hpam_create_path(int length) {
  struct path_model* model = (struct path_model*)malloc(sizeof(struct path_model));
  model->topics = (int*)malloc(sizeof(int) * length);
  return model;
}

void hpam_delete_path(struct path_model* model) {
  if (model != NULL) {
    free(model->topics);
    free(model);
  }
}
