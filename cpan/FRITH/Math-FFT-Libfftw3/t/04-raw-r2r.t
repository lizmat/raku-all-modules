#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my $in = CArray[num64].new(1e0, 2e0 … 6e0);
  my $out = CArray[num64].allocate(6);
  my fftw_plan $pland = fftw_plan_r2r_1d(6, $in, $out, FFTW_REDFT00, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (35e0, -10.47213595499958e0, 0e0, -1.5278640450004204e0, 0e0, -1e0)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(6);
  my fftw_plan $planr = fftw_plan_r2r_1d(6, $out, $back, FFTW_REDFT00, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 10)[^6]».round(10⁻¹²), # n=6, 2(n-1) = 10
    (1.0, 2.0 … 6.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'r2r 1d even transform';

subtest {
  my $in = CArray[num64].new(1e0, 2e0 … 6e0);
  my $out = CArray[num64].allocate(6);
  my fftw_plan $pland = fftw_plan_r2r_1d(6, $in, $out, FFTW_RODFT00, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (30.669003872744, -14.535649776006, 8.777722363639, -5.582313722177, 3.371022331653, -1.597704320731)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(6);
  my fftw_plan $planr = fftw_plan_r2r_1d(6, $out, $back, FFTW_RODFT00, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 14)[^6]».round(10⁻¹²), # n=6, 2(n+1) = 14
    (1.0, 2.0 … 6.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'r2r 1d odd transform';

done-testing;
