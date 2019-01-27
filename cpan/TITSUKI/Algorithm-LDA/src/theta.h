#ifndef _THETA_H
#define _THETA_H

struct theta_model {
  int num_super_topic;
  int num_sub_topic;
  int num_doc;
  int*** nkp;
  int** nk;
  double** akp;
  double* ak;
};

struct theta_model* lda_create_theta(int num_super_topic, int num_sub_topic, int num_doc, double alpha);
void lda_delete_theta(struct theta_model* model);
void lda_theta_allocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
void lda_theta_deallocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
void lda_theta_update(struct theta_model* model);
double lda_theta_weight(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
double lda_theta_pdf(struct theta_model* model);
int lda_theta_num_super_topic(struct theta_model* model);
int lda_theta_num_sub_topic(struct theta_model* model);
int lda_theta_num_doc(struct theta_model* model);

#endif /* _THETA_H */
