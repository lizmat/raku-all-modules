use v6.c;
unit module Pod::Load:ver<0.5.2>;

=begin pod

=head1 NAME

Pod::Load - Loads and compiles the Pod documentation from a string or file.

=head1 SYNOPSIS

    use Pod::Load;

    # Read a file handle.
    my $pod = load("file-with.pod6".IO);
    say $pod.perl; # Process it as a Pod

    # Or use simply the file name (it should exist)
    my @pod = load("file-with.pod6");
    say .perl for @pod;

    my $string-with-pod = q:to/EOH/;
    =begin pod
    This ordinary paragraph introduces a code block:
    =end pod
    EOH

    say load( $string-with-pod ).perl;

=head1 DESCRIPTION

Pod::Load is a module with a simple task:
obtaining the documentation of an external file in a standard,
straighworward way. Its mechanism (using EVAL) is inspired by
L<C<Pod::To::BigPage>|https://github.com/perl6/perl6-pod-to-bigpage>.

=head1 CAVEATS

The pod is obtained from the file or string via EVAL. That means that
it's going to run what is actually there. If you don't want that to
happen, strip all runnable code from the string (or file) before
submitting it to this module.
              
=head1 AUTHOR

JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018,2019 JJ Merelo

This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0. 

=end pod

use MONKEY-SEE-NO-EVAL;

#| Loads a string, returns a Pod.
multi sub load ( Str $string ) is export {
    my $module-name = "m{rand}";
    my $copy = $string;
    $module-name ~~ s/\.//;
    $copy ~~ s/"use" \s+ "v6;"//;
    my @pod;
    if $copy ~~ /"="output/ {
        my @chunks = $copy.split( /"="output/ );
        @pod = (EVAL ("module $module-name \{\n" ~ @chunks[0] ~ "\}\n\$=pod;\n\n=output@chunks[1]"));
    } else {
        @pod = (EVAL ("module $module-name \{\n" ~ $copy ~ "\}\n\$=pod"));
    }
    return @pod;
}

#| If it's an actual filename, loads a file and returns the pod
multi sub load( Str $file where .IO.e ) {
    return load( $file.IO );
}

#| Loads a IO::Path, returns a Pod. (Originally) from pod2onepage
multi sub load ( IO::Path $io ) is export {
    return load($io.slurp);
}
