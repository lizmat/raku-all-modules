unit module Native::Exec;

use NativeCall;

sub strerror(int32 $errno --> Str)
    is native {}

my $errno := cglobal('libc.so.6', 'errno', int32);

sub execvp(Str $file, CArray[Str] $argv --> int32)
    is native {}

sub execv(Str $file, CArray[Str] $argv --> int32)
    is native {}

sub execve(Str $file, CArray[Str] $argv, CArray[Str] $envp --> int32)
    is native {}

sub execvpe(Str $file, CArray[Str] $argv, CArray[Str] $envp --> int32)
    is native {}

class X::Native::Exec is Exception
{
    has $.errno;
    method Numeric() { $.errno }
    method message() { strerror($!errno) }
}

sub exec(Str:D $file, *@args, Bool :$nopath, *%env) is export
{
    my $argv = CArray[Str].new($file, @args, Str);

    if %env
    {
        my $env = CArray[Str].new(%env.map({ .key ~ '=' ~ .value }), Str);

        $nopath ?? execve($file, $argv, $env)
                !! execvpe($file, $argv, $env)
    }
    else
    {
        $nopath ?? execv($file, $argv)
                !! execvp($file, $argv)
    }

    die X::Native::Exec.new(:$errno);
}

=begin pod

=head1 NAME

Native::Exec -- NativeCall bindings for Unix exec*() calls

=head1 SYNOPSIS

  use Native::Exec;

  # Default searches PATH for executable
  exec 'echo', 'hi';

  # Specify :nopath to avoid PATH searching
  exec :nopath, '/bin/echo', 'hi';

  # Override ENV entirely by passing in named params
  exec 'env', HOME => '/my/home', PATH => '/bin:/usr/bin';

=head1 DESCRIPTION

Very basic wrapper around NativeCall bindings for the Unix C<execv>(),
C<execve>(), C<execvp>(), and C<execvpe>() Unix calls.

C<exec> defaults to the 'p' variants that search your PATH for the
specified executable.  If you include the C<:nopath> option, it will
use the non 'p' variants and avoid the PATH search.  You can also
include a '/' in your specified executable and that will also avoid
the PATH search within the C<exec*> routines.

Including any named parameters OTHER THAN C<:nopath> will build a new
environment for the C<exec>ed program, replacing the existing
environment entirely, using the 'e' variants.

=head1 EXCEPTIONS

C<exec> does NOT return.  On success, the C<exec>ed program will
replace your Perl 6 program entirely.  If there are any errors, such
as not finding the specified program, it will throw C<X::Native::Exec>
with the native error code.  You can access the native error code with
C<.errno>, and the native error message with C<.message>.

  exec 'non-existant';

  CATCH {
      when X::Native::Exec {
        say "Native Error Code: ", .errno;
        say "Native Error Message: ", .message;
      }
  }

=head1 NOTE

The C<exec>* family are Unix specific, and are unlikely to work on
other architectures.

=end pod
