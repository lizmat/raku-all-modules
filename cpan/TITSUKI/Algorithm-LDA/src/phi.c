#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "phi.h"
#include "util.h"

struct phi_model* lda_create_phi(int num_sub_topic, int num_word_type, double beta) {
  struct phi_model* model;

  model = (struct phi_model*)malloc(sizeof(struct phi_model));
  model->num_sub_topic = num_sub_topic;
  model->num_word_type = num_word_type;
  model->np = (int*)malloc(sizeof(int) * num_sub_topic);
  model->npw = (int**)malloc(sizeof(int*) * num_sub_topic);
  model->beta = beta;
  model->sigma_beta = model->beta * (double)model->num_word_type;

  for (int sub_i = 0; sub_i < num_sub_topic; sub_i++) {
    model->np[sub_i] = 0;
    model->npw[sub_i] = (int*)malloc(sizeof(int) * num_word_type);
    for (int word_i = 0; word_i < num_word_type; word_i++) {
      model->npw[sub_i][word_i] = 0;
    }
  }
  return model;
}

void lda_delete_phi(struct phi_model* model) {
  if (model != NULL) {
    for (int sub_i = 0; sub_i < model->num_sub_topic; sub_i++) {
      free(model->npw[sub_i]);
    }
    free(model->np);
    free(model->npw);
    free(model);
  }
}

void lda_phi_allocate(struct phi_model* model, int sub_topic, int word_type) {
  model->np[sub_topic]++;
  model->npw[sub_topic][word_type]++;
}

void lda_phi_deallocate(struct phi_model* model, int sub_topic, int word_type) {
  model->np[sub_topic]--;
  model->npw[sub_topic][word_type]--;
}

double lda_phi_weight(struct phi_model* model, int sub_topic, int word_type) {
  double weight = log((double)(model->npw[sub_topic][word_type] + model->beta))
    - log((double)(model->np[sub_topic] + model->sigma_beta));
  if (isnan(weight) || !isfinite(weight)) {
    return -100.0;
  } else {
    return weight;
  }
}

double lda_phi_pdf(struct phi_model* model) {
  double weight = 0.0;

  for (int topic = 0; topic < model->num_sub_topic; topic++) {
    weight += lgamma(model->sigma_beta);
    weight -= lgamma((double)((double)model->np[topic] + model->sigma_beta));
    for (int word_type = 0; word_type < model->num_word_type; word_type++) {
      if (model->npw[topic][word_type] == 0) continue;
      weight -= lgamma(model->beta);
      weight += lgamma((double)((double)model->npw[topic][word_type] + model->beta));
    }
  }
  return weight;
}

int lda_phi_num_word_type(struct phi_model* model) {
  return model->num_word_type;
}

int lda_phi_num_sub_topic(struct phi_model* model) {
  return model->num_sub_topic;
}

