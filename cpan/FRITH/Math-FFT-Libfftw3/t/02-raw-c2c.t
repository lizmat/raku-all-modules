#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

subtest {
  my $in = CArray[num64].new: (1..6)».Complex».reals.flat;
  my $out = CArray[num64].allocate(12);
  my fftw_plan $pland = fftw_plan_dft_1d(6, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (21e0, 0e0,
     -3e0, 5.196152422706632e0,
     -3e0, 1.7320508075688772e0,
     -3e0, 0e0,
     -3e0, -1.7320508075688772e0,
     -3e0, -5.196152422706632e0)».round(10⁻¹²),
    'direct transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
  my $back = CArray[num64].allocate(12);
  my fftw_plan $planr = fftw_plan_dft_1d(6, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 6)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 6.0),
    'inverse transform';
  fftw_destroy_plan($planr);
  my fftw_plan $planip = fftw_plan_dft_1d(6, $in, $in, FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute($planip);
  is-deeply $in.list».round(10⁻¹²),
    (21e0, 0e0,
     -3e0, 5.196152422706632e0,
     -3e0, 1.7320508075688772e0,
     -3e0, 0e0,
     -3e0, -1.7320508075688772e0,
     -3e0, -5.196152422706632e0)».round(10⁻¹²),
    'direct transform in place';
  fftw_destroy_plan($planip);
}, 'c2c 1d transform';

subtest {
  my $in = CArray[num64].new: (1..18)».Complex».reals.flat;
  my $out = CArray[num64].allocate(36);
  my fftw_plan $pland = fftw_plan_dft_2d(6, 3, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (171e0, 0e0, -9e0, 5.196152422706632e0, -9e0, -5.196152422706632e0, -27e0, 46.76537180435968e0, 0e0, 0e0, 0e0, 0e0,
     -27e0, 15.588457268119894e0, 0e0, 0e0, 0e0, 0e0, -27e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     -27e0, -15.588457268119894e0, 0e0, 0e0, 0e0, 0e0, -27e0, -46.76537180435968e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(36);
  my fftw_plan $planr = fftw_plan_dft_2d(6, 3, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 18)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 18.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'c2c 2d transform';

subtest {
  my $in = CArray[num64].new: (1..54)».Complex».reals.flat;
  my $out = CArray[num64].allocate(108);
  my fftw_plan $pland = fftw_plan_dft_3d(6, 3, 3, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (1485e0, 0e0, -27e0, 15.588457268119896e0, -27e0, -15.588457268119896e0, -81e0, 46.76537180435968e0, 0e0, 0e0,
     0e0, 0e0, -81e0, -46.76537180435968e0, 0e0, 0e0, 0e0, 0e0, -243e0, 420.88834623923714e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, 140.29611541307906e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, -140.29611541307906e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, -420.88834623923714e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(108);
  my fftw_plan $planr = fftw_plan_dft_3d(6, 3, 3, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 54)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 54.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'c2c 3d transform';

subtest {
  my $in  = CArray[num64].new: (1..54)».Complex».reals.flat;
  my $out = CArray[num64].allocate(108);
  my $n   = CArray[int32].new: 6, 3, 3;
  my fftw_plan $pland = fftw_plan_dft(3, $n, $in, $out, FFTW_FORWARD, FFTW_ESTIMATE);
  isa-ok $pland, fftw_plan, 'create plan';
  lives-ok { fftw_execute($pland) }, 'execute plan';
  is-deeply $out.list».round(10⁻¹²),
    (1485e0, 0e0, -27e0, 15.588457268119896e0, -27e0, -15.588457268119896e0, -81e0, 46.76537180435968e0, 0e0, 0e0, 0e0,
     0e0, -81e0, -46.76537180435968e0, 0e0, 0e0, 0e0, 0e0, -243e0, 420.88834623923714e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, 140.29611541307906e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, -243e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, -243e0, -140.29611541307906e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0, -243e0, -420.88834623923714e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0, 0e0,
     0e0, 0e0, 0e0, 0e0, 0e0)».round(10⁻¹²),
    'direct transform';
  my $back = CArray[num64].allocate(108);
  my fftw_plan $planr = fftw_plan_dft(3, $n, $out, $back, FFTW_BACKWARD, FFTW_ESTIMATE);
  fftw_execute($planr);
  is-deeply ($back.list »/» 54)[0, 2 … *]».round(10⁻¹²),
    (1.0, 2.0 … 54.0),
    'inverse transform';
  lives-ok { fftw_destroy_plan($pland) }, 'destroy plan';
}, 'c2c multidimensional transform';

lives-ok { fftw_cleanup }, 'cleanup';

done-testing;
