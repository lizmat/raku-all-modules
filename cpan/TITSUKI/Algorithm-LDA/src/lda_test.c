#define DEBUG 1

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "lda.h"
#include "theta.h"
#include "phi.h"
#include "path.h"
#include "document.h"

static double best_qstar(struct document_model* document, struct phi_model* phi, double alpha, int topic, int word_i) {
  return log(alpha) + lda_phi_weight(phi, topic, document->words[word_i]);
}

// NOTE: This test is a characterization test.
static void test_heldout_log_likelihood() {
  struct phi_model* phi = lda_create_phi(3, 3, 0.1); // num_topic x num_word_type
  int words[10] = {1, 2, 3};
  struct document_model* document = lda_create_document(3, words);
  double actual = _lda_heldout_log_likelihood(document, phi, &best_qstar);
  double expected = -3.29;
  double EPS = 0.05;

  if (actual < expected + EPS && actual > expected - EPS) {
    fprintf(stderr, "Passed test_heldout_log_likelihood\n");
  } else {
    fprintf(stderr, "Failed test_heldout_log_likelihood\n");
    fprintf(stderr, "expected: %lf but actual: %lf\n", expected, actual);
    exit(-1);
  }
}

int main() {
  test_heldout_log_likelihood();
  return 0;
}
