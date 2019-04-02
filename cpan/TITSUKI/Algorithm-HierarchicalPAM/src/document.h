#ifndef _DOCUMENT_H
#define _DOCUMENT_H

struct document_model {
  int length;
  int* words;
};

struct document_model* hpam_create_document(int length, int* words);

#endif /* _DOCUMENT_H */
