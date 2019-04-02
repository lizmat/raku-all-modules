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

struct theta_model* hpam_create_theta(int num_super_topic, int num_sub_topic, int num_doc, double alpha);
void hpam_delete_theta(struct theta_model* model);
void hpam_theta_allocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
void hpam_theta_deallocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
void hpam_theta_update(struct theta_model* model);
double hpam_theta_weight(struct theta_model* model, int super_topic, int sub_topic, int doc_index);
double hpam_theta_pdf(struct theta_model* model);
int hpam_theta_num_super_topic(struct theta_model* model);
int hpam_theta_num_sub_topic(struct theta_model* model);
int hpam_theta_num_doc(struct theta_model* model);

#endif /* _THETA_H */
