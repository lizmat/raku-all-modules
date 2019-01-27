#include <stdlib.h>
#include <string.h>
#include "document.h"

struct document_model* lda_create_document(int length, int* words) {
  struct document_model* model = (struct document_model*)malloc(sizeof(struct document_model));

  model->length = length;
  model->words = (int*)malloc(sizeof(int) * length);
  memcpy(model->words, words, sizeof(int) * length);
  return model;
}
