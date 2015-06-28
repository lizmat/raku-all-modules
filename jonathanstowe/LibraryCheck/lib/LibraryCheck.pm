use v6;

=begin pod

=head1 NAME

LibraryCheck - check for the existence of a shared library

=head1 SYNOPSIS

=begin code

     use LibraryCheck;

     if !library-exists('libsndfile') {
         die "Cannot load libsndfile";
     }

=end code

=head1 DESCRIPTION

This module provides a mechanism that will determine whether a named
shared library is available and can be used by NativeCall.

It exports a single function 'library-exists' that returns a boolean to
indicate whether the named shared library can be loaded and used.

This can be used in a builder to determine whether a module has a chance
of working (and possibly aborting the build,) or in tests to cause the
tests that may rely on a shared library to be skipped, but other use-cases
are possible.


The implementation is somewhat of a hack currently and definitely shouldn't
be taken as an example of nice Perl 6 code.

=end pod

module LibraryCheck {
   use NativeCall; 

    sub library-exists(Str $lib --> Bool) is export {
        my $rc = True;  

        my $name = ("a".."z","A".."Z").pick(15).join("");
        my $f = EVAL("sub $name\(\) is native(\{'$lib'\}) \{ * \}");
        try { 
                $f(); 
                CATCH { 
                    when /'Cannot locate native library'/  { $rc = False } 
                    default { $rc = True } 
                } 
        }
        $rc; 
    } 
}
