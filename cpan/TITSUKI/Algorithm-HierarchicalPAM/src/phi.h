#ifndef _PHI_H
#define _PHI_H

struct phi_model {
    int num_topic;
    int num_word_type;
    double beta;
    double sigma_beta;
    int* np;
    int** npw;
};

struct phi_model* hpam_create_phi(int num_sub_topic, int num_word_type, double beta);
void hpam_delete_phi(struct phi_model* model);
void hpam_phi_allocate(struct phi_model* model, int sub_topic, int word_type);
void hpam_phi_deallocate(struct phi_model* model, int sub_topic, int word_type);
void hpam_phi_update(struct phi_model* model);
double hpam_phi_weight(struct phi_model* model, int sub_topic, int word_type);
double hpam_phi_pdf(struct phi_model* model);
int hpam_phi_num_word_type(struct phi_model* model);
int hpam_phi_num_topic(struct phi_model* model);

#endif /* _PHI_H */
