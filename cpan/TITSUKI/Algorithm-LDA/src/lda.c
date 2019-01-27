#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "lda.h"
#include "theta.h"
#include "phi.h"
#include "util.h"
#include "path.h"
#include "document.h"

void lda_fit(struct document_model** documents, struct phi_model* phi, struct theta_model** theta, int num_topics, int doc_size, int num_iteration) {
  struct path_model** paths = malloc(sizeof(struct path_model*) * doc_size);
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    paths[doc_i] = lda_create_path(documents[doc_i]->length);
  }
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    for (int word_i = 0; word_i < documents[doc_i]->length; word_i++) {
      int current_topic = rand() % num_topics;
      lda_theta_allocate(theta[0], 0, current_topic, doc_i);
      lda_phi_allocate(phi, current_topic, documents[doc_i]->words[word_i]);
      paths[doc_i]->topics[word_i] = current_topic;
    }
  }
  for (int iter_i = 0; iter_i < num_iteration; iter_i++) {
    for (int doc_i = 0; doc_i < doc_size; doc_i++) {
      for (int word_i = 0; word_i < documents[doc_i]->length; word_i++) {
        double* weights = (double*)calloc(num_topics, sizeof(double));
        double all_log_sum = -10000.0;
        double partial_log_sum = -10000.0;
        double pivot = 0.0;
        int sampled_topic = 0;

        lda_theta_deallocate(theta[0], 0, paths[doc_i]->topics[word_i], doc_i);
        lda_phi_deallocate(phi, paths[doc_i]->topics[word_i], documents[doc_i]->words[word_i]);

        for (int current_topic = 0; current_topic < num_topics; current_topic++) {
          double phi_weight = lda_phi_weight(phi, current_topic, documents[doc_i]->words[word_i]);
          double theta_weight = lda_theta_weight(theta[0], 0, current_topic, doc_i);
          weights[current_topic] = phi_weight + theta_weight;
        }

        for (int i = 0; i < num_topics; i++) {
          all_log_sum = lda_log_sum(weights[i], all_log_sum);
        }

        pivot = all_log_sum + log((double)rand() / (double)RAND_MAX);

        while (sampled_topic < num_topics && lda_log_sum(weights[sampled_topic], partial_log_sum) < pivot) {
          partial_log_sum = lda_log_sum(weights[sampled_topic], partial_log_sum);
          sampled_topic++;
        }

        lda_theta_allocate(theta[0], 0, sampled_topic, doc_i);
        lda_phi_allocate(phi, sampled_topic, documents[doc_i]->words[word_i]);
        paths[doc_i]->topics[word_i] = sampled_topic;

        free(weights);
      }
    }
    if (iter_i != 0 && iter_i % 100 == 0) {
       lda_theta_update(theta[0]);
    }
  }
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    lda_delete_path(paths[doc_i]);
  }
  free(paths);
}

double lda_log_likelihood(struct phi_model* phi, struct theta_model** theta) {
  return lda_phi_pdf(phi) + lda_theta_pdf(theta[0]);
}

// Note: This heldout_log_likelihood function is highly experimental
// This implementation is based on the IS-PZW method in:
// Wallach, Hanna M., et al. "Evaluation methods for topic models." Proceedings of the 26th annual international conference on machine learning. ACM, 2009.
double lda_is_pzw(struct document_model* document, struct phi_model* phi, double alpha, int topic, int word_i) {
  return log(alpha) + lda_phi_weight(phi, topic, document->words[word_i]);
}

double _lda_heldout_log_likelihood(struct document_model* document, struct phi_model* phi, double (*qstar)(struct document_model*, struct phi_model*, double, int, int)) {
  int num_topics = lda_phi_num_sub_topic(phi);
  double alpha = 1.0; // TODO
  int num_sample = 200000;
  double doc_likelihood = -100.0;

  double** qq = (double**)malloc(sizeof(double*) * num_topics);
  int** samples = (int**)malloc(sizeof(int*) * document->length);
  int** topic_count = (int**)malloc(sizeof(int*) * num_topics);
  double* log_z = (double*)malloc(sizeof(double) * num_sample);
  double* log_w_given_z = (double*)malloc(sizeof(double) * num_sample);
  double* log_wz = (double*)malloc(sizeof(double) * num_sample);
  double* log_qq = (double*)malloc(sizeof(double) * num_sample);
  double* log_w = (double*)malloc(sizeof(double) * num_sample);
  double log_sum_w = -100.0;

  for (int topic = 0; topic < num_topics; topic++) {
    qq[topic] = (double*)malloc(sizeof(double) * document->length);
  }
  for (int word_i = 0; word_i < document->length; word_i++) {
    double sum = -100.0;
    for (int topic = 0; topic < num_topics; topic++) {
      sum = lda_log_sum(qstar(document, phi, alpha, topic, word_i), sum);
    }
    for (int topic = 0; topic < num_topics; topic++) {
      qq[topic][word_i] = qstar(document, phi, alpha, topic, word_i) - sum;
    }
  }

  for (int word_i = 0; word_i < document->length; word_i++) {
    samples[word_i] = (int*)malloc(sizeof(int) * num_sample);
  }
  for (int topic = 0; topic < num_topics; topic++) {
    topic_count[topic] = (int*)calloc(num_sample, sizeof(int));
  }

  for (int word_i = 0; word_i < document->length; word_i++) {
    for (int iter = 0; iter < num_sample; iter++) {
      double partial_log_sum = -100.0;
      double pivot = log((double)rand() / (double)RAND_MAX);
      int sample_topic = 0;

      while (sample_topic < num_topics
             && lda_log_sum(qq[sample_topic][word_i], partial_log_sum) < pivot) {
        partial_log_sum = lda_log_sum(partial_log_sum, qq[sample_topic][word_i]);
        sample_topic++;
      }
      samples[word_i][iter] = sample_topic;
      topic_count[sample_topic][iter]++;
    }
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    log_z[sample_i] = lgamma(alpha * (double)num_topics) - lgamma((double)document->length + alpha * (double)num_topics);
    for (int topic = 0; topic < num_topics; topic++) {
      log_z[sample_i] += lgamma((double)topic_count[topic][sample_i] + alpha) - lgamma(alpha);
    }
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    log_w_given_z[sample_i] = 0.0;
    for (int word_i = 0; word_i < document->length; word_i++) {
      int topic = samples[word_i][sample_i];
      log_w_given_z[sample_i] += lda_phi_weight(phi, topic, document->words[word_i]);
    }
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    log_qq[sample_i] = 0.0;
    for (int word_i = 0; word_i < document->length; word_i++) {
      int topic = samples[word_i][sample_i];
      log_qq[sample_i] += qq[topic][word_i];
    }
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    log_w[sample_i] = log_w_given_z[sample_i] - log_qq[sample_i];
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    log_sum_w = lda_log_sum(log_w[sample_i], log_sum_w);
  }

  for (int sample_i = 0; sample_i < num_sample; sample_i++) {
    doc_likelihood = lda_log_sum(log_w[sample_i] - log_sum_w + log_z[sample_i], doc_likelihood);
  }

  free(qq);
  free(samples);
  free(topic_count);
  free(log_z);
  free(log_w_given_z);
  free(log_wz);
  free(log_qq);
  free(log_w);

  return doc_likelihood;
}

double lda_heldout_log_likelihood(struct document_model** documents, struct phi_model* phi, int num_topics, int doc_size) {
  double weight = 0.0;
  for (int doc_i = 0; doc_i < doc_size; doc_i++) {
    weight += _lda_heldout_log_likelihood(documents[doc_i], phi, &lda_is_pzw);
  }
  return weight;
}

void lda_set_srand(int seed) {
  srand(seed);
}
