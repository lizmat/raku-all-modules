#ifndef _LDA_H
#define _LDA_H

#include "theta.h"
#include "phi.h"
#include "document.h"

void lda_fit(struct document_model** documents, struct phi_model* phi, struct theta_model** theta, int num_topics, int doc_size, int num_iteration);

void lda_set_srand(int seed);

double lda_log_likelihood(struct phi_model* phi, struct theta_model** theta);

double lda_heldout_log_likelihood(struct document_model** documents, struct phi_model* phi, int num_topics, int doc_size);

#if(DEBUG == 1)
  double _lda_heldout_log_likelihood(struct document_model* document, struct phi_model* phi, double (*qstar)(struct document_model*, struct phi_model*, double, int, int));
#endif

#endif /* _LDA_H */
