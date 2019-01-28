#!/usr/bin/env perl6

use NativeCall;
use lib 'lib';
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;

my $in = CArray[num64].new: (1..6)».Complex».reals.flat;
my $out = CArray[num64].allocate(12);

my $begin1 = now;
my fftw_plan $pland1 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_MEASURE);
$in = CArray[num64].new: (1..6)».Complex».reals.flat;
for ^10000 {
  fftw_execute($pland1);
}
say 'measure 10000 ' ~ now - $begin1 ~ ' sec';

my $begin2 = now;
my fftw_plan $pland2 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
for ^10000 {
  fftw_execute($pland2);
}
say 'estimate 10000 ' ~ now - $begin2 ~ ' sec';

my $begin3 = now;
my fftw_plan $pland3 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_MEASURE);
$in = CArray[num64].new: (1..6)».Complex».reals.flat;
for ^100000 {
  fftw_execute($pland3);
}
say 'measure 100000 ' ~ now - $begin3 ~ ' sec';

my $begin4 = now;
my fftw_plan $pland4 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
for ^100000 {
  fftw_execute($pland4);
}
say 'estimate 100000 ' ~ now - $begin4 ~ ' sec';

my $begin5 = now;
my fftw_plan $pland5 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_MEASURE);
$in = CArray[num64].new: (1..6)».Complex».reals.flat;
for ^1000000 {
  fftw_execute($pland5);
}
say 'measure 1000000 ' ~ now - $begin5 ~ ' sec';

my $begin6 = now;
my fftw_plan $pland6 = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
for ^1000000 {
  fftw_execute($pland6);
}
say 'estimate 1000000 ' ~ now - $begin6 ~ ' sec';
