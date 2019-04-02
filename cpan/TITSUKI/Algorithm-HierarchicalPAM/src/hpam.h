#ifndef _HPAM_H
#define _HPAM_H

#include "theta.h"
#include "phi.h"
#include "document.h"

void hpam_fit(struct document_model** documents, struct phi_model* phi, struct theta_model** theta, int num_super_topics, int num_sub_topics, int doc_size, int num_iteration);

void hpam_set_srand(int seed);

double hpam_log_likelihood(struct phi_model* phi, struct theta_model** theta);

#endif /* _HPAM_H */
