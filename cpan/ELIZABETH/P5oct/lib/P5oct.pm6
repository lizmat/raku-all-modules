use v6.c;
unit module P5oct:ver<0.0.3>;

proto sub oct(|) is export {*}
multi sub oct() { oct CALLERS::<$_> }
multi sub oct(Str() $s is copy) {
    $s .= trim-leading;
    if $s ~~ / \D / {                            # something non-numeric there
        with $s ~~ / ^0 <[xob]> \d+ $/ {           # standard 0x string
            +$_
        }
        else {                                     # not a standard 0x string
            with $s ~~ /^ \d+ / {                    # numeric with trailing
                .Str.parse-base(8)
            }
            else {                                   # garbage
                +$_                                   # throw numification error
            }
        }
    }
    else {                                       # just digits
        $s.parse-base(8)
    }
}

=begin pod

=head1 NAME

P5oct - Implement Perl 5's oct() built-in

=head1 SYNOPSIS

  use P5oct; # exports oct()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<oct> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5oct . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
