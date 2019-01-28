use v6;

use NativeCall;
use Math::FFT::Libfftw3::Raw;
use Math::FFT::Libfftw3::Constants;
use Math::FFT::Libfftw3::Common;
use Math::FFT::Libfftw3::Exception;

unit class Math::FFT::Libfftw3::C2C:ver<0.1.2>:auth<cpan:FRITH> does Math::FFT::Libfftw3::FFTRole;

has num64     @.out;
has num64     @!in;
has int32     $.rank;
has int32     @.dims;
has int32     $.direction;
has fftw_plan $!plan;

# Shaped Array
multi method new(:@data! where @data ~~ Array && @data.shape[0] ~~ Int,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE)
{
  # .Array flattens a shaped array since Rakudo 2018.09
  die 'This module needs at least Rakudo v2018.09 in order to use shaped arrays'
    if $*PERL.compiler.version < v2018.09;
  self.bless(:data(@data.Array), :direction($direction), :dims(@data.shape), :flag($flag));
}

# Array of arrays
multi method new(:@data! where @data ~~ Array && @data[0] ~~ Array,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE)
{
  fail X::Libfftw3.new: errno => NO-DIMS, error => 'Array of arrays: you must specify the dims array'
    if @dims.elems == 0;
  self.bless(:data(do { gather @data.deepmap(*.take) }), :direction($direction), :dims(@dims), :flag($flag));
}

# Plain array or Positional
multi method new(:@data! where @data !~~ Array || @data.shape[0] ~~ Whatever,
                 :@dims?,
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE)
{
  self.bless(:data(@data), :direction($direction), :dims(@dims), :flag($flag));
}

# Math::Matrix object
multi method new(:$data! where .^name eq 'Math::Matrix',
                 Int :$direction? = FFTW_FORWARD,
                 Int :$flag? = FFTW_ESTIMATE)
{
  self.bless(:data($data.list-rows.flat.list), :direction($direction), :dims($data.size), :flag($flag));
}

submethod BUILD(:@data!, :@dims?, :$!direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE)
{
  if $!direction !~~ FFTW_FORWARD|FFTW_BACKWARD {
    fail X::Libfftw3.new: errno => DIRECTION-ERROR, error => 'Wrong direction. Try FFTW_FORWARD or FFTW_BACKWARD';
  }
  # What kind of data type?
  given @data[0] {
    when Complex {
      @!in := CArray[num64].new: @data.map(|*)».reals.List.flat;
    }
    when Int | Rat | Num {
      @!in := CArray[num64].new: (@data Z 0 xx @data.elems).flat».Num;
    }
    default {
      fail X::Libfftw3.new: errno => TYPE-ERROR, error => 'Wrong type. Try Int, Rat, Num or Complex';
    }
  }
  # Initialize @!dims and $!rank when @data is not shaped or when is not an array
  if @data !~~ Array || @data.shape[0] ~~ Whatever {
    with @dims[0] {
      @!dims := CArray[int32].new: @dims;
      $!rank  = @dims.elems;
    } else {
      @!dims := CArray[int32].new: (@!in.elems / 2).Int;
      $!rank  = 1;
    }
  } elsif @data ~~ Array && @data.shape[0] ~~ Int {
    @!dims := CArray[int32].new: @dims;
    $!rank  = @!dims.elems;
  }
  self.plan: $flag;
}

submethod DESTROY
{
  fftw_destroy_plan($!plan) with $!plan;
  fftw_cleanup;
}

method plan(Int $flag --> Nil)
{
  # Create a plan. The FFTW_MEASURE flag destroys the input array; save it.
  my @savein := CArray[num64].new: @!in.list;
  @!out      := CArray[num64].new: 0e0 xx @!in.elems;
  $!plan      = fftw_plan_dft($!rank, @!dims, @!in, @!out, $!direction, $flag);
  @!in       := CArray[num64].new: @savein.list;
}

method execute(Int :$output? = OUT-COMPLEX --> Positional)
{
  fftw_execute($!plan);
  given $!direction {
    when FFTW_FORWARD {
      given $output {
        when OUT-COMPLEX {
          return @!out.map(-> $r, $i { Complex.new($r, $i) }).list;
        }
        when OUT-REIM {
          return @!out.list;
        }
        when OUT-NUM {
          return @!out.list[0,2 … *];
        }
      }
    }
    when FFTW_BACKWARD {
      my @out := @!out.list »/» [*] @!dims.list; # backward trasforms are not normalized
      given $output {
        when OUT-COMPLEX {
          return @out.map(-> $r, $i { Complex.new($r, $i) }).list;
        }
        when OUT-REIM {
          return @out;
        }
        when OUT-NUM {
          return @out[0,2 … *];
        }
      }
    }
  }
}

method in(Int :$output? = OUT-COMPLEX --> Positional)
{
  given $output {
    when OUT-COMPLEX {
      return @!in.map(-> $r, $i { Complex.new($r, $i) }).list;
    }
    when OUT-REIM {
      return @!in.list;
    }
    when OUT-NUM {
      return @!in.list[0,2 … *];
    }
  }
}

=begin pod

=head1 NAME

Math::FFT::Libfftw3::C2C - High-level bindings to libfftw3 Complex-to-Complex transform

=head1 SYNOPSIS
=begin code

use v6;

use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

my @in = (0, π/100 … 2*π)».sin;
put @in».Complex».round(10⁻¹²); # print the original array as complex values rounded to 10⁻¹²
my Math::FFT::Libfftw3::C2C $fft .= new: data => @in;
my @out = $fft.execute;
put @out; # print the direct transform output
my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²); # print the backward transform output rounded to 10⁻¹²

=end code

=begin code

use v6;

use Math::FFT::Libfftw3::C2C;
use Math::FFT::Libfftw3::Constants; # needed for the FFTW_BACKWARD constant

# direct 2D transform
my Math::FFT::Libfftw3::C2C $fft .= new: data => 1..18, dims => (6, 3);
my @out = $fft.execute;
put @out;
# reverse 2D transform
my Math::FFT::Libfftw3::C2C $fftr .= new: data => @out, dims => (6,3), direction => FFTW_BACKWARD;
my @outr = $fftr.execute;
put @outr».round(10⁻¹²);

=end code

=head1 DESCRIPTION

B<Math::FFT::Libfftw3::C2C> provides an OO interface to libfftw3 and allows you to perform Complex-to-Complex
Fast Fourier Transforms.

=head2 new(:@data!, :@dims?, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE)
=head2 new(:$data!, Int :$direction? = FFTW_FORWARD, Int :$flag? = FFTW_ESTIMATE)

The first constructor accepts any Positional of type Int, Rat, Num, Complex (and IntStr, RatStr, NumStr, ComplexStr);
it allows List of Ints, Array of Complex, Seq of Rat, shaped arrays of any base type, etc.

The only mandatory argument is B<@data>.
Multidimensional data are expressed in row-major order (see L<C Library Documentation|#clib>) and the array B<@dims> must be
passed to the constructor, or the data will be interpreted as a 1D array.
If one uses a shaped array, there's no need to pass the B<@dims> array, because the dimensions will be read
from the array itself.

The B<$direction> parameter is used to specify a direct or backward transform; it defaults to FFTW_FORWARD.

The B<$flag> parameter specifies the way the underlying library has to analyze the data in order to create a plan
for the transform; it defaults to FFTW_ESTIMATE (see L<#Documentation>).

The second constructor accepts a scalar: an object of type B<Math::Matrix> (if that module is installed, otherwise
it returns a B<Failure>), a B<$direction>, and a B<$flag>; the meaning of the last two parameters is the same as in
the other constructor.

=head2 execute(Int :$output? = OUT-COMPLEX --> Positional)

Executes the transform and returns the output array of values as a normalized row-major array.
The parameter B<$output> can be optionally used to specify how the array is to be returned:

=item OUT-COMPLEX
=item OUT-REIM
=item OUT-NUM

The default (B<OUT-COMPLEX>) is to return an array of Complex.
B<OUT-REIM> makes the C<execute> method return the native representation of the data: an array of couples of
real/imaginary values.
B<OUT-NUM> makes the C<execute> method return just the real part of the complex values.

=head2 in(Int :$output? = OUT-COMPLEX --> Positional)

Returns the input array, same options as per the output array.

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

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
