#ifndef _UTIL_H
#define _UTIL_H

void lda_update_parameter(int num_parameter, int num_observed, int** n, double* sigma_alpha, double* alpha);
double lda_digamma(double x);
double lda_lgamma(double x);
double lda_log_sum(double log_a, double log_b);

#endif /* _UTIL_H */
