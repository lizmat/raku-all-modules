use v6;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use Math::FFT::Libfftw3::Common;
use Math::FFT::Libfftw3::Exception;

unit class Math::FFT::Libfftw3::R2R:ver<0.1.2>:auth<cpan:FRITH> does Math::FFT::Libfftw3::FFTRole;

has num64     @.out;
has num64     @!in;
has int32     $.rank;
has int32     @.dims;
has int32     $.direction;
has int32     @.kind;
has fftw_plan $!plan;

# Shaped Array
multi method new(:@data! where @data ~~ Array && @data.shape[0] ~~ Int,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!)
{
  # .Array flattens a shaped array since Rakudo 2018.09
  die 'This module needs at least Rakudo v2018.09 in order to use shaped arrays'
    if $*PERL.compiler.version < v2018.09;
  self.bless(:data(@data.Array), :direction($direction), :dims(@data.shape), :flag($flag), :kind($kind));
}

# Array of arrays
multi method new(:@data! where @data ~~ Array && @data[0] ~~ Array,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!)
{
  fail X::Libfftw3.new: errno => NO-DIMS, error => 'Array of arrays: you must specify the dims array'
    if @dims.elems == 0;
  self.bless(:data(do { gather @data.deepmap(*.take) }), :direction($direction), :dims(@dims), :flag($flag), :kind($kind));
}

# Plain array or Positional
multi method new(:@data! where @data !~~ Array || @data.shape[0] ~~ Whatever,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!)
{
  self.bless(:data(@data), :direction($direction), :dims(@dims), :flag($flag), :kind($kind));
}

# Math::Matrix object
multi method new(:$data! where .^name eq 'Math::Matrix',
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE,
                 :$kind!)
{
  self.bless(:data($data.list-rows.flat.list), :direction($direction), :dims($data.size), :flag($flag), :kind($kind));
}

submethod BUILD(:@data!,
                :@dims?,
                Int :$!direction? = FFTW_FORWARD,
                Int :$flag? = FFTW_ESTIMATE,
                :$kind!)
{
  if $kind !~~ fftw_r2r_kind {
    fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Invalid value for argument kind';
  }
  if $!direction !~~ FFTW_FORWARD|FFTW_BACKWARD {
    fail X::Libfftw3.new: errno => DIRECTION-ERROR, error => 'Wrong direction. Try FFTW_FORWARD or FFTW_BACKWARD';
  }
  # What kind of data type?
  given @data[0] {
    when Int | Rat | Num {
      @!in := CArray[num64].new: @data».Num;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Rat or Num';
    }
  }
  # Initialize @!dims and $!rank when @data is not shaped or when is not an array
  if @data !~~ Array || @data.shape[0] ~~ Whatever {
    with @dims[0] {
      @!dims := CArray[int32].new: @dims;
      $!rank  = @dims.elems;
    } else {
      @!dims := CArray[int32].new: @!in.elems;
      $!rank  = 1;
    }
  } elsif @data ~~ Array && @data.shape[0] ~~ Int {
    @!dims := CArray[int32].new: @dims;
    $!rank  = @!dims.elems;
  }
  self.plan: $flag, $kind;
}

submethod DESTROY
{
  fftw_destroy_plan($!plan) with $!plan;
  fftw_cleanup;
}

method plan(Int $flag, $kind --> Nil)
{
  # Create a plan. The FFTW_MEASURE flag destroys the input array; save it.
  my @savein := CArray[num64].new: @!in.list;
  @!kind     := CArray[int32].new: $kind xx $!rank;
  @!out      := CArray[num64].new: 0e0 xx @!in.list.elems;
  $!plan      = fftw_plan_r2r($!rank, @!dims, @!in, @!out, @!kind, $flag);
  @!in       := CArray[num64].new: @savein.list;
}


method execute(--> Positional)
{
  fftw_execute($!plan);
  given @!kind[0] {
    when FFTW_R2HC {
      return @!out.list;
    }
    when FFTW_HC2R {
      return @!out.list »/» [*] @!dims.list;
    }
    when FFTW_REDFT00 {
      if $!direction == FFTW_BACKWARD { # backward trasforms are not normalized
        return @!out.list »/» (2 * (([*] @!dims.list) - 1));
      } else {
        return @!out.list;
      }
    }
    when FFTW_RODFT00 {
      if $!direction == FFTW_BACKWARD {
        return @!out.list »/» (2 * (([*] @!dims.list) + 1));
      } else {
        return @!out.list;
      }
    }
    when FFTW_REDFT01|FFTW_REDFT10|FFTW_REDFT11|FFTW_RODFT01|FFTW_RODFT10|FFTW_RODFT11 {
      if $!direction == FFTW_BACKWARD {
        return @!out.list »/» (2 * [*] @!dims.list);
      } else {
        return @!out.list;
      }
    }
    default {
      fail X::Libfftw3.new: errno => KIND-ERROR, error => 'Wrong value for the @kind argument';
    }
  }
}

method in(--> Positional)
{
  return @!in.list;
}

=begin pod

=head1 NAME

Math::FFT::Libfftw3::R2R - High-level bindings to libfftw3 Real-to-Complex transform

=head1 SYNOPSIS
=begin code

use v6;

use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_R2HC and FFTW_HC2R constants

my @in = (0, π/100 … 2*π)».sin;
put @in».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3::R2R $fft .= new: data => @in, kind => FFTW_R2HC;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, kind => FFTW_HC2R;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code

use v6;

use Math::FFT::Libfftw3::R2R;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_R2HC and FFTW_HC2R constants

# direct 2D transform
my Math::FFT::Libfftw3::R2R $fft .= new: data => 1..18, dims => (6, 3), kind => FFTW_R2HC;
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3::R2R $fftr .= new: data => @out, dims => (6, 3), kind => FFTW_HC2R;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3::R2R> provides an OO interface to libfftw3 and allows you to perform Real-to-Real
Halfcomplex Fast Fourier Transforms.

The direct transform accepts an array of real numbers and outputs a half-complex array of real numbers.
The reverse transform accepts a half-complex array of real numbers and outputs an array of real numbers.


=head2 new(:@data!, :@dims?, Int :$flag? = FFTW_ESTIMATE, :$kind!)
=head2 new(:$data!, Int :$flag? = FFTW_ESTIMATE, :$kind!)

The first constructor accepts any Positional of type Int, Rat, Num (and IntStr, RatStr, NumStr);
it allows List of Ints, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument are B<@data> and B<$kind>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation|#clib>) and the array B<@dims>
must be passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<kind> argument, of type B<fftw_r2r_kind>, specifies what kind of trasform will be performed on the input data.
B<fftw_r2r_kind> constants are defined as an B<enum> in B<Math::FFT::Libfftw3::Constants>.
The values of the B<fftw_r2r_kind> enum are:

=item FFTW_R2HC
=item FFTW_HC2R
=item FFTW_DHT
=item FFTW_REDFT00
=item FFTW_REDFT01
=item FFTW_REDFT10
=item FFTW_REDFT11
=item FFTW_RODFT00
=item FFTW_RODFT01
=item FFTW_RODFT10
=item FFTW_RODFT11

The Half-Complex transform uses the symbol FFTW_R2HC for a Real to Half-Complex (direct) transform, while
the corresponding Half-Complex to Real (reverse) transform is specified by the symbol FFTW_HC2R.
The reverse transform of FFTW_R*DFT10 is FFTW_R*DFT01 and vice versa, of FFTW_R*DFT11 is FFTW_R*DFT11,
and of FFTW_R*DFT00 is FFTW_R*DFT00.

The B<$flag> parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to FFTW_ESTIMATE (see L<#Documentation>).

The second constructor accepts a scalar: an object of type B<Math::Matrix> (if that module is installed, otherwise
it returns a B<Failure>), a B<$flag>, and a list of the kind of trasform one wants to be performed on each dimension;
the meaning of the last two parameters is the same as in the other constructor.

=head2 execute(--> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.

=head2 in(--> Positional)

Returns the input array.

=head2 Attributes

Some of this class' attributes are readable:

=item @.out
=item $.rank
=item @.dims
=item $.direction

=head2 Wisdom interface

This interface allows to save and load a plan associated to a transform (There are some caveats. See L<#Documentation>).

=head3 plan-save(Str $filename --> True)

Saves the plan into a file. Returns B<True> if successful and a B<Failure> object otherwise.

=head3 plan-load(Str $filename --> True)

Loads the plan from a file. Returns B<True> if successful and a B<Failure> object otherwise.


=head1 L<C Library Documentation|#clib>

For more details on libfftw see L<http://www.fftw.org/>.
The manual is available here L<http://www.fftw.org/fftw3.pdf>

=head1 Prerequisites

This module requires the libfftw3 library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libfftw3-double3
=end code

The module looks for a library called libfftw3.so.

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::FFT::Libfftw3
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Notes

Math::FFT::Libfftw3 relies on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl 6 module.
If you need a pure Perl 6 module, Math::FourierTransform works just fine.

This module needs Perl 6 ≥ 2018.09 only if one wants to use shaped arrays as input data. An attempt to feed a shaped
array to the C<new> method using C«$*PERL.compiler.version < v2018.09» results in an exception.

=head1 CAVEATS

There are some caveats regarding the way the various kind of R2R 1-dimensional transforms are computed and
their performances, and how the n-dimensional transforms are computed and why is probably a better idea to
use the R2C-C2R transform in case of multi-dimensional transforms.
Please refer to the documentation of the L<C Library Documentation|#clib>.

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
