#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "util.h"

// This implementation is based on Eq. 31 in:
// Minka, Thomas. "Estimating a Dirichlet distribution." (2000): 4.
void lda_update_parameter(int num_parameter, int num_observed, int** n, double* sigma_alpha, double* alpha) {
  int* sum_n = (int*)malloc(sizeof(int) * num_observed);
  double sum_alpha = 0.0;

  for (int iter_i = 0; iter_i < 100; iter_i++) {
    for (int i = 0; i < num_observed; i++) {
      sum_n[i] = 0;
    }
    sum_alpha = 0.0;

    for (int k = 0; k < num_parameter; k++) {
      sum_alpha += alpha[k];
      for (int i = 0; i < num_observed; i++) {
        sum_n[i] += n[k][i];
      }
    }
    for (int k = 0; k < num_parameter; k++) {
      double numerator = 0.0;
      double denominator = 0.0;
      double prev_alpha;
      double coeff;
      for (int i = 0; i < num_observed; i++) {
        numerator += lda_digamma(n[k][i] + alpha[k]) - lda_digamma(alpha[k]);
      }

      for (int i = 0; i < num_observed; i++) {
        denominator += lda_digamma(sum_n[i] + sum_alpha) - lda_digamma(sum_alpha);
      }

      coeff = numerator / denominator;
      if (isnan(coeff)) {
        continue;
      }
      prev_alpha = alpha[k];
      alpha[k] = alpha[k] * coeff;
      sum_alpha += alpha[k] - prev_alpha;
      *sigma_alpha = sum_alpha;
    }
  }
  free(sum_n);
}

double lda_digamma(double x) {
  double p;
  x=x+6;
  p=1/(x*x);
  p=(((0.004166666666667*p-0.003968253986254)*p+
      0.008333333333333)*p-0.083333333333333)*p;
  p=p+log(x)-0.5/x-1/(x-1)-1/(x-2)-1/(x-3)-1/(x-4)-1/(x-5)-1/(x-6);
  return p;
}

double lda_log_sum(double log_a, double log_b) {
  double v;

  if (log_a < log_b) {
    v = log_b + log(1 + exp(log_a - log_b));
  } else {
    v = log_a + log(1 + exp(log_b - log_a));
  }
  return v;
}
