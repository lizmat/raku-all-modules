#ifndef _UTIL_H
#define _UTIL_H

void hpam_update_parameter(int num_parameter, int num_observed, int** n, double* sigma_alpha, double* alpha);
double hpam_digamma(double x);
double hpam_lgamma(double x);
double hpam_log_sum(double log_a, double log_b);

#endif /* _UTIL_H */
