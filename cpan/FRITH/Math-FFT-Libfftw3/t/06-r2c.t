#!/usr/bin/env perl6

use lib 'lib';
use Test;
use Math::FFT::Libfftw3::R2C;
use Math::FFT::Libfftw3::Constants;
use NativeCall;

dies-ok { my $fft = Math::FFT::Libfftw3::R2C.new }, 'dies if no data passed';
throws-like
  { Math::FFT::Libfftw3::R2C.new: data => <a b c> },
  X::Libfftw3,
  message => /Wrong ' ' type/,
  'fails with wrong data';
subtest {
  my Math::FFT::Libfftw3::R2C $fft1 .= new: data => 1..6;
  isa-ok $fft1, Math::FFT::Libfftw3::R2C, 'object type';
  isa-ok $fft1.in, 'List', 'internal input array - Real';
  is-deeply $fft1.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'input array';
  cmp-ok $fft1.rank,    '==', 1, 'rank of data vector/matrix';
  cmp-ok $fft1.dims[0], '==', 6, 'dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft1.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [21e0 + 0e0i,
     -3e0 + 5.196152422706632e0i,
     -3e0 + 1.7320508075688772e0i,
     -3e0 + 0e0i]».round(10⁻¹²),
    'direct transform - Complex output';
  my @outreim = $fft1.execute: output => OUT-REIM;
  is-deeply @outreim».round(10⁻¹²),
    [21e0, 0e0,
     -3e0, 5.196152422706632e0,
     -3e0, 1.7320508075688772e0,
     -3e0, 0e0]».round(10⁻¹²),
    'direct transform - Re Im output';
  my @outnum = $fft1.execute: output => OUT-NUM;
  is-deeply @outnum».round(10⁻¹²),
    [21e0, -3e0, -3e0, -3e0]».round(10⁻¹²),
    'direct transform - Num output';
  my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²)».Num, [1e0, 2e0, 3e0, 4e0, 5e0, 6e0], 'inverse transform - Complex output';
  my @outrnum = $fftr.execute: output => OUT-NUM;
  is-deeply @outrnum».round(10⁻¹²), [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], 'inverse transform - Num output';
  my Math::FFT::Libfftw3::R2C $fft2 .= new: data => 1..6, flag => FFTW_MEASURE;
  my @out2 = $fft1.execute;
  is-deeply @out2».round(10⁻¹²),
    [21e0 + 0e0i,
     -3e0 + 5.196152422706632e0i,
     -3e0 + 1.7320508075688772e0i,
     -3e0 + 0e0i]».round(10⁻¹²),
    'using FFTW_MEASURE';
}, 'Range of Int - 1D transform';
subtest {
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1, 2 … 6);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Sequence of Int';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1..6).list;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of Int';
  }
  {
    my @data = 1..6;
    my Math::FFT::Libfftw3::R2C $fft .= new: data => @data;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Array of Int';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => 1/1..6/1;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Range of Rat';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1/1, 2/1 … 6/1);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Sequence of Rat';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1/1, 2/1, 3/1, 4/1, 5/1, 6/1);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of Rat';
  }
  {
    my @data = 1/1, 2/1, 3/1, 4/1, 5/1, 6/1;
    my Math::FFT::Libfftw3::R2C $fft .= new: data => @data;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Array of Rat';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => 1e0..6e0;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Range of Num';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1e0, 2e0 … 6e0);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Sequence of Num';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (1e0..6e0).list;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of Num';
  }
  {
    my @data = 1e0..6e0;
    my Math::FFT::Libfftw3::R2C $fft .= new: data => @data;
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'Array of Num';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (<1>, <2>, <3>, <4>, <5>, <6>);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of IntStr';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (<1/1>, <2/1>, <3/1>, <4/1>, <5/1>, <6/1>);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of RatStr';
  }
  {
    my Math::FFT::Libfftw3::R2C $fft .= new: data => (<1e0>, <2e0>, <3e0>, <4e0>, <5e0>, <6e0>);
    is-deeply $fft.in, (1e0, 2e0, 3e0, 4e0, 5e0, 6e0), 'List of NumStr';
  }
}, 'Other data types - 1D transform';
subtest {
  my Math::FFT::Libfftw3::R2C $fft .= new: data => 1..18, dims => (6, 3);
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Range of Int - 2D transform';
subtest {
  my @array = [1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15], [16, 17, 18];
  throws-like
    { Math::FFT::Libfftw3::R2C.new: data => @array },
    X::Libfftw3, message => /Array ' ' of ' ' arrays/,
    'fails if no dims present';
  my Math::FFT::Libfftw3::R2C $fft .= new: data => @array, dims => (6,3);
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  is-deeply $fft.in,
    (1e0, 2e0, 3e0, 4e0, 5e0, 6e0, 7e0, 8e0, 9e0, 10e0, 11e0, 12e0, 13e0, 14e0, 15e0, 16e0, 17e0, 18e0),
    'data read correctly';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Array of arrays of Int - 2D transform';
subtest {
  my @array[6,3] = (1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12; 13, 14, 15; 16, 17, 18);
  my Math::FFT::Libfftw3::R2C $fft .= new: data => @array;
  cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
  cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
  cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
  is-deeply $fft.in(:output(OUT-REIM)),
    (1e0, 2e0, 3e0, 4e0, 5e0, 6e0, 7e0, 8e0, 9e0, 10e0, 11e0, 12e0, 13e0, 14e0, 15e0, 16e0, 17e0, 18e0),
    'data read correctly';
  my @out;
  lives-ok { @out = $fft.execute }, 'execute transform';
  is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i]».round(10⁻¹²),
    'direct transform';
  my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
  my @outr = $fftr.execute;
  is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
}, 'Shaped matrix of Int - 2D transform';
subtest {
  if (try require Math::Matrix) !=== Nil {
    my $matrix = Math::Matrix.new: [[1,2,3],[4,5,6],[7,8,9],[10,11,12],[13,14,15],[16,17,18]];
    my Math::FFT::Libfftw3::R2C $fft .= new: data => $matrix;
    cmp-ok $fft.rank,    '==', 2, 'rank of data vector/matrix';
    cmp-ok $fft.dims[0], '==', 6, 'first dimension of vector/matrix';
    cmp-ok $fft.dims[1], '==', 3, 'second dimension of vector/matrix';
    my @out;
    lives-ok { @out = $fft.execute }, 'execute transform';
    is-deeply @out».round(10⁻¹²),
    [171e0 + 0e0i,
      -9e0 + 5.196152422706632e0i,
     -27e0 + 46.76537180435968e0i,
       0e0 + 0e0i,
     -27e0 + 15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + 0e0i,
       0e0 + 0e0i,
     -27e0 + -15.588457268119894e0i,
       0e0 + 0e0i,
     -27e0 + -46.76537180435968e0i,
       0e0 + 0e0i]».round(10⁻¹²),
      'direct transform';
    my Math::FFT::Libfftw3::R2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
    my @outr = $fftr.execute;
    is-deeply @outr».round(10⁻¹²), [1.0, 2.0 … 18.0], 'inverse transform';
    throws-like
      { my $now = DateTime.new(now); Math::FFT::Libfftw3::R2C.new: data => $now },
      X::TypeCheck::Binding::Parameter,
      message => /Type ' ' check ' ' failed/,
      'fails with wrong data';
  } else {
    plan 1;
    skip-rest 'Math::Matrix not found';
  }
}, 'Math::Matrix';
subtest {
  my $fileout;
  ENTER {
    my $path = $*PROGRAM-NAME.subst(/ <-[/]>+$/, '');
    $fileout = $path ~ 'wisdom.dat';
    $fileout.IO.unlink if $fileout.IO.e;
  }
  LEAVE { $fileout.IO.unlink if $fileout.IO.e }
  my Math::FFT::Libfftw3::R2C $fft1 .= new: data => 1..6, flag => FFTW_MEASURE;
  throws-like
    { $fft1.plan-save("nonexistent/$fileout") },
    X::Libfftw3, message => /Can\'t ' ' create ' ' file/,
    "fails if can't create output file";
  lives-ok { $fft1.plan-save($fileout) }, 'save plan to file';
  throws-like
    { $fft1.plan-load("nonexistent/$fileout") },
    X::Libfftw3, message => /Can\'t ' ' read ' ' file/,
    "fails if can't read input file";
  my Math::FFT::Libfftw3::R2C $fft2 .= new: data => 1..6;
  lives-ok { $fft2.plan-load($fileout) }, 'read plan from file';
  lives-ok { $fft2.execute }, 'execute transform on saved plan';
}, 'Wisdom interface';

done-testing;
