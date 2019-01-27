#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "theta.h"
#include "util.h"

// This implementation is based on three-level PAM (same as LDA):
// Li, Wei, and Andrew McCallum. "Pachinko allocation: DAG-structured mixture models of topic correlations." Proceedings of the 23rd international conference on Machine learning. ACM, 2006.
struct theta_model* lda_create_theta(int num_super_topic, int num_sub_topic, int num_doc, double alpha) {
  struct theta_model* model;

  model = (struct theta_model*)malloc(sizeof(struct theta_model));
  model->num_super_topic = num_super_topic;
  model->num_sub_topic = num_sub_topic;
  model->num_doc = num_doc;
  model->nkp = (int***)malloc(sizeof(int**) * num_super_topic);
  model->nk = (int**)malloc(sizeof(int*) * num_super_topic);
  model->akp = (double**)malloc(sizeof(double*) * num_super_topic);
  model->ak = (double*)calloc(num_super_topic, sizeof(double));

  for (int super_i = 0; super_i < num_super_topic; super_i++) {
    model->nk[super_i] = (int*)malloc(sizeof(int) * num_doc);
    model->nkp[super_i] = (int**)malloc(sizeof(int*) * num_sub_topic);
    model->akp[super_i] = (double*)malloc(sizeof(double) * num_sub_topic);
    for (int sub_i = 0; sub_i < num_sub_topic; sub_i++) {
      model->nkp[super_i][sub_i] = (int*)malloc(sizeof(int) * num_doc);
      model->akp[super_i][sub_i] = alpha;
      for (int doc_i = 0; doc_i < num_doc; doc_i++) {
        model->nkp[super_i][sub_i][doc_i] = 0;
        model->nk[super_i][doc_i] = 0;
      }
      model->ak[super_i] += model->akp[super_i][sub_i];
    }
  }
  return model;
}

void lda_delete_theta(struct theta_model* model) {
  if (model != NULL) {
    for (int super_i = 0; super_i < model->num_super_topic; super_i++) {
      for (int sub_i = 0; sub_i < model->num_sub_topic; sub_i++) {
        free(model->nkp[super_i][sub_i]);
      }
    }

    for (int super_i = 0; super_i < model->num_super_topic; super_i++) {
      free(model->nk[super_i]);
      free(model->nkp[super_i]);
      free(model->akp[super_i]);
    }

    free(model->nkp);
    free(model->nk);
    free(model->akp);
    free(model->ak);
    free(model);
  }
}

void lda_theta_allocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index) {
  model->nkp[super_topic][sub_topic][doc_index]++;
  model->nk[super_topic][doc_index]++;
}

void lda_theta_deallocate(struct theta_model* model, int super_topic, int sub_topic, int doc_index) {
  model->nkp[super_topic][sub_topic][doc_index]--;
  model->nk[super_topic][doc_index]--;
}

void lda_theta_update(struct theta_model* model) {
  for (int super_i = 0; super_i < model->num_super_topic; super_i++) {
    lda_update_parameter(model->num_sub_topic, model->num_doc, model->nkp[super_i], &(model->ak[super_i]), model->akp[super_i]);
  }
}

double lda_theta_weight(struct theta_model* model, int super_topic, int sub_topic, int doc_index) {
  double weight = log((double)(model->nkp[super_topic][sub_topic][doc_index] + model->akp[super_topic][sub_topic]))
    - log((double)(model->nk[super_topic][doc_index] + model->ak[super_topic]));
  if (isnan(weight) || !isfinite(weight)) {
    return -100.0;
  }
  return weight;
}

double lda_theta_pdf(struct theta_model* model) {
  double weight = 0.0;
  for (int doc_i = 0; doc_i < model->num_doc; doc_i++) {
    for (int super_topic = 0; super_topic < model->num_super_topic; super_topic++) {
      weight += lgamma((double)model->ak[super_topic]);
      weight -= lgamma((double)model->nk[super_topic][doc_i] + model->ak[super_topic]);
      for (int sub_topic = 0; sub_topic < model->num_sub_topic; sub_topic++) {
        if (model->nkp[super_topic][sub_topic][doc_i] == 0) continue;
        weight += lgamma((double)model->nkp[super_topic][sub_topic][doc_i] + model->akp[super_topic][sub_topic]);
        weight -= lgamma((double)model->akp[super_topic][sub_topic]);
      }
    }
  }
  return weight;
}

int lda_theta_num_super_topic(struct theta_model* model) {
  return model->num_super_topic;
}

int lda_theta_num_sub_topic(struct theta_model* model) {
  return model->num_sub_topic;
}
int lda_theta_num_doc(struct theta_model* model) {
  return model->num_doc;
}
