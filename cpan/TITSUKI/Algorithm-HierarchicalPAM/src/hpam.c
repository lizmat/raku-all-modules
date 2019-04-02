#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "hpam.h"
#include "theta.h"
#include "phi.h"
#include "util.h"
#include "path.h"
#include "document.h"

void hpam_fit(struct document_model** documents, struct phi_model* phi, struct theta_model** theta, int num_super_topics, int num_sub_topics, int doc_size, int num_iteration) {
  struct path_model** paths = malloc(sizeof(struct path_model*) * doc_size);
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    paths[doc_i] = hpam_create_path(documents[doc_i]->length);
  }
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    for (int word_i = 0; word_i < documents[doc_i]->length; word_i++) {
      int exit_level = rand() % 2;
      if (exit_level == 0) {
        int topic = rand() % num_super_topics;
        hpam_theta_allocate(theta[0], 0, topic, doc_i);
        hpam_phi_allocate(phi, topic, documents[doc_i]->words[word_i]);
        paths[doc_i]->topics[word_i] = topic;
      } else {
        int topic = num_super_topics + (rand() % (num_super_topics * num_sub_topics));
        int super_topic = (topic - num_super_topics) % num_super_topics;
        int sub_topic = (topic - num_super_topics) / num_super_topics;
        hpam_theta_allocate(theta[1], super_topic, sub_topic, doc_i);
        hpam_phi_allocate(phi, topic, documents[doc_i]->words[word_i]);
        paths[doc_i]->topics[word_i] = topic;
      }
    }
  }
  for (int iter_i = 0; iter_i < num_iteration; iter_i++) {
    for (int doc_i = 0; doc_i < doc_size; doc_i++) {
      for (int word_i = 0; word_i < documents[doc_i]->length; word_i++) {
        double* weights = (double*)calloc(num_super_topics + (num_super_topics * num_sub_topics), sizeof(double));
        double all_log_sum = -10000.0;
        double partial_log_sum = -10000.0;
        double pivot = 0.0;
        int sampled_topic = 0;
        int prev_topic = paths[doc_i]->topics[word_i];

        if (prev_topic < num_super_topics) {
          hpam_theta_deallocate(theta[0], 0, prev_topic, doc_i);
        } else {
          int super_topic = (prev_topic - num_super_topics) % num_super_topics;
          int sub_topic = (prev_topic - num_super_topics) / num_super_topics;
          hpam_theta_deallocate(theta[0], 0, super_topic, doc_i);
          hpam_theta_deallocate(theta[1], super_topic, sub_topic, doc_i);
        }
        hpam_phi_deallocate(phi, paths[doc_i]->topics[word_i], documents[doc_i]->words[word_i]);

        for (int current_topic = 0; current_topic < num_super_topics + (num_super_topics * num_sub_topics); current_topic++) {
          if (current_topic < num_super_topics) {
            double phi_weight = hpam_phi_weight(phi, current_topic, documents[doc_i]->words[word_i]);
            double theta_weight = hpam_theta_weight(theta[0], 0, current_topic, doc_i);
            weights[current_topic] = phi_weight + theta_weight;
          } else {
            int super_topic = (current_topic - num_super_topics) % num_super_topics;
            int sub_topic = (current_topic - num_super_topics) / num_super_topics;
            double phi_weight = hpam_phi_weight(phi, current_topic, documents[doc_i]->words[word_i]);
            double super_theta_weight = hpam_theta_weight(theta[0], 0, super_topic, doc_i);
            double sub_theta_weight = hpam_theta_weight(theta[1], super_topic, sub_topic, doc_i);
            weights[current_topic] = phi_weight + super_theta_weight + sub_theta_weight;
          }
        }

        for (int i = 0; i < num_super_topics + (num_super_topics * num_sub_topics); i++) {
          all_log_sum = hpam_log_sum(weights[i], all_log_sum);
        }

        pivot = all_log_sum + log((double)rand() / (double)RAND_MAX);

        while (sampled_topic < num_super_topics + (num_super_topics * num_sub_topics)
               && hpam_log_sum(weights[sampled_topic], partial_log_sum) < pivot) {
          partial_log_sum = hpam_log_sum(weights[sampled_topic], partial_log_sum);
          sampled_topic++;
        }

        if (sampled_topic < num_super_topics) {
          hpam_theta_allocate(theta[0], 0, sampled_topic, doc_i);
        } else {
          int super_topic = (sampled_topic - num_super_topics) % num_super_topics;
          int sub_topic = (sampled_topic - num_super_topics) / num_super_topics;
          hpam_theta_allocate(theta[0], 0, super_topic, doc_i);
          hpam_theta_allocate(theta[1], super_topic, sub_topic, doc_i);
        }

        hpam_phi_allocate(phi, sampled_topic, documents[doc_i]->words[word_i]);
        paths[doc_i]->topics[word_i] = sampled_topic;

        free(weights);
      }
    }
    if (iter_i != 0 && iter_i % 100 == 0) {
      hpam_theta_update(theta[0]);
      hpam_theta_update(theta[1]);
    }
  }
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    hpam_delete_path(paths[doc_i]);
  }
  free(paths);
}

double hpam_log_likelihood(struct phi_model* phi, struct theta_model** theta) {
  return hpam_phi_pdf(phi) + hpam_theta_pdf(theta[0]) + hpam_theta_pdf(theta[1]);
}

void hpam_set_srand(int seed) {
  srand(seed);
}
