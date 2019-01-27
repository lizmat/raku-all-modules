#ifndef _PHI_H
#define _PHI_H

struct phi_model {
    int num_sub_topic;
    int num_word_type;
    double beta;
    double sigma_beta;
    int* np;
    int** npw;
};

struct phi_model* lda_create_phi(int num_sub_topic, int num_word_type, double beta);
void lda_delete_phi(struct phi_model* model);
void lda_phi_allocate(struct phi_model* model, int sub_topic, int word_type);
void lda_phi_deallocate(struct phi_model* model, int sub_topic, int word_type);
void lda_phi_update(struct phi_model* model);
double lda_phi_weight(struct phi_model* model, int sub_topic, int word_type);
double lda_phi_pdf(struct phi_model* model);
int lda_phi_num_word_type(struct phi_model* model);
int lda_phi_num_sub_topic(struct phi_model* model);

#endif /* _PHI_H */
