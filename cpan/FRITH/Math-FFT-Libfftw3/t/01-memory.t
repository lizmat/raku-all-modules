#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;

my $p;
lives-ok { $p = fftw_malloc(1024) }, 'allocate memory';
lives-ok { fftw_free($p) }, 'free memory';
lives-ok { $p = fftw_alloc_complex(1024) }, 'allocate memory for complex numbers';
fftw_free($p);
lives-ok { $p = fftw_alloc_real(1024) }, 'allocate memory for real numbers';
fftw_free($p);
done-testing
