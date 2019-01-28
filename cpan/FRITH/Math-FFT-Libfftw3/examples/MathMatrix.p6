#!/usr/bin/env perl6

use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants;
use Math::Matrix;

my $matrix = Math::Matrix.new: [[1,2,3],[4,5,6],[7,8,9],[10,11,12],[13,14,15],[16,17,18]];
say $matrix;
my ($rows, $cols) = $matrix.size;
my Math::FFT::Libfftw3::C2C $fft .= new: data => $matrix;
my @out = $fft.execute;
say @out;
my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, dims => ($rows, $cols), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
say @outr».round(10⁻¹²);
