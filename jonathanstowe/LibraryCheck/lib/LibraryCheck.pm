use v6;

=begin pod

=head1 NAME

LibraryCheck - check for the existence of a shared library

=head1 SYNOPSIS

=begin code

     use LibraryCheck;

     if !library-exists('sndfile', v1) {
         die "Cannot load libsndfile";
     }

=end code

=head1 DESCRIPTION

This module provides a mechanism that will determine whether a named
shared library is available and can be used by NativeCall.

It exports a single function 'library-exists' that returns a boolean to
indicate whether the named shared library can be loaded and used. 
The library name should be supplied without any (OS dependent,) "lib"
prefix and no extension, (so e.g. 'crypt' for 'libcrypt.so' etc.)

The second positional argument is a L<Version> object that indicates the
version of the library that is required, it defaults to C<v1>, if you don't
care which version exists then it possible to pass a new Version object
without an version parts (i.e. C<Version.new()>.)

If the ':exception' adverb is passed to C<library-exists> then an
exception (C<X::NoLibrary>) will be thrown if the library isn't availabe
rather than returning False.

This can be used in a builder to determine whether a module has a chance
of working (and possibly aborting the build,) or in tests to cause the
tests that may rely on a shared library to be skipped, but other use-cases
are possible.


The implementation is somewhat of a hack currently and definitely shouldn't
be taken as an example of nice Perl 6 code.

=end pod

module LibraryCheck {
   use NativeCall; 

   class X::NoLibrary is Exception {
       has Str $.library;

       method message() returns Str {
           "library { $!library } was not found";
       }
   }

    sub library-exists(Str $lib, Version $v = v1, :$exception --> Bool) is export {
        my $rc = True;  

        use MONKEY-SEE-NO-EVAL;
        my $name = ("a".."z","A".."Z").flat.pick(15).join("");
        my $f = EVAL("sub $name\(\) is native('$lib', { $v.gist }) \{ * \}");
        try { 
                $f(); 
                CATCH { 
                    when /'Cannot locate native library'/  { $rc = False } 
                    default { $rc = True } 
                } 
        }

        if not $rc and $exception {
            X::NoLibrary.new(library => $lib).throw;
        }
        no MONKEY-SEE-NO-EVAL;
        $rc; 
    } 
}
