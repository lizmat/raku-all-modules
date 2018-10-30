p6-IDNA-Punycode
===========

USAGE
-----

    #!/usr/bin/env perl6

    use v6;
    use IDNA::Punycode;
    
    say encode_punycode 'nice'  # nice
    say encode_punycode 'schön' # xn--schn-7qa
    
    say decode_punycode 'nice'         # nice
    say decode_punycode 'xn--schn-7qa' # schön
