#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my $in = CArray[num64].new(1e0, 2e0 … 6e0);
  my $out = CArray[num64].allocate(8);
  my fftw_plan $pland = fftw_plan_dft_r2c_1d(6, $in, $out, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (21e0, 0e0, -3e0, 5.196152422706632e0, -3e0, 1.7320508075688772e0, -3e0, 0e0)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(8);
  my fftw_plan $planr = fftw_plan_dft_c2r_1d(6, $out, $back, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 6)[^6]».round(10⁻¹²),
    (1.0, 2.0 … 6.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'r2c & c2r 1d transform';

done-testing;
