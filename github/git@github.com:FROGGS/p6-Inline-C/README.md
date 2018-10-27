p6-Inline-C
===========

USAGE
-----

    #!/usr/bin/env perl6

    use soft; # for now
    use Inline;
    
    my sub a_plus_b( Int $a, Int $b ) is inline('C') returns Int {'
        DLLEXPORT int a_plus_b (int a, int b) {
            return a + b;
        }
    '}
