use v6;

unit role Math::FFT::Libfftw3::FFTRole;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use Math::FFT::Libfftw3::Exception;

method execute() { … }

method plan-save(Str $filename --> True)
{
  fftw_export_wisdom_to_filename($filename) ||
    fail X::Libfftw3.new: errno => FILE-ERROR, error => "Can't create file $filename";
}

method plan-load(Str $filename --> True)
{
  fftw_import_wisdom_from_filename($filename) ||
    fail X::Libfftw3.new: errno => FILE-ERROR, error => "Can't read file $filename";
}
