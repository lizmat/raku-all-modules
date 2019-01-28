#!/usr/bin/env perl6

use Math::FourierTransform;
use lib 'lib';
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

say "6 points, 10000 times";
my $begin1 = now;
my Complex @data = (1..6)».Complex;
my Complex @spectrum;
for ^10000 {
  @spectrum = discrete-fourier-transform @data;
}
say 'Math::FourierTransform:   ' ~ now - $begin1 ~ ' sec';

my $begin2 = now;
my $in = CArray[num64].new: (1..6)».Complex».reals.flat;
my $out = CArray[num64].allocate(12);
my fftw_plan $pland = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
for ^10000 {
  fftw_execute($pland);
}
say 'Math::FFT::Libfftw3::Raw: ' ~ now - $begin2 ~ ' sec';

say "\n10000 points";
my $begin3 = now;
my Complex @data1 = (1..10_000)».Complex;
my Complex @spectrum1;
@spectrum1 = discrete-fourier-transform @data1;
say 'Math::FourierTransform:   ' ~ now - $begin3 ~ ' sec';

my $begin4 = now;
my $in1 = CArray[num64].new: (1..10_000)».Complex».reals.flat;
my $out1 = CArray[num64].allocate(20_000);
my fftw_plan $pland1 = fftw_plan_dft_1d(10_000, $in1, $out1, FFTW_FORWARD, FFTW_ESTIMATE);
fftw_execute($pland1);
say 'Math::FFT::Libfftw3::Raw: ' ~ now - $begin4 ~ ' sec';
