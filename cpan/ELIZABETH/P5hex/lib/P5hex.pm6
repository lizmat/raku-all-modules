use v6.c;

unit module P5hex:ver<0.0.5>:auth<cpan:ELIZABETH>;

proto sub hex(|) is export {*}
multi sub hex() { hex CALLERS::<$_> }
multi sub hex(Str() $s) {
    $s ~~ / ^ <[a..f A..F 0..9]>* $ /
      ?? ($s ?? $s.parse-base(16) !! 0)
      !! +$s  # let numerification handle parse errors
}

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

P5hex - Implement Perl 5's hex() / ord() built-ins

=head1 SYNOPSIS

  use P5hex; # exports hex() and ord()

  print hex '0xAf'; # prints '175'
  print hex 'aF';   # same

  $val = oct($val) if $val =~ /^0/;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<hex> and C<oct> functions of
Perl 5 as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    hex EXPR
    hex     Interprets EXPR as a hex string and returns the corresponding
            value. (To convert strings that might start with either 0, "0x",
            or "0b", see "oct".) If EXPR is omitted, uses $_.

                print hex '0xAf'; # prints '175'
                print hex 'aF';   # same

            Hex strings may only represent integers. Strings that would cause
            integer overflow trigger a warning. Leading whitespace is not
            stripped, unlike oct(). To present something as hex, look into
            "printf", "sprintf", and "unpack".


    oct EXPR
    oct     Interprets EXPR as an octal string and returns the corresponding
            value. (If EXPR happens to start off with "0x", interprets it as a
            hex string. If EXPR starts off with "0b", it is interpreted as a
            binary string. Leading whitespace is ignored in all three cases.)
            The following will handle decimal, binary, octal, and hex in
            standard Perl notation:

                $val = oct($val) if $val =~ /^0/;

            If EXPR is omitted, uses $_. To go the other way (produce a number
            in octal), use sprintf() or printf():

                $dec_perms = (stat("filename"))[2] & 07777;
                $oct_perm_str = sprintf "%o", $perms;

            The oct() function is commonly used when a string such as 644
            needs to be converted into a file mode, for example. Although Perl
            automatically converts strings into numbers as needed, this
            automatic conversion assumes base 10.

            Leading white space is ignored without warning, as too are any
            trailing non-digits, such as a decimal point ("oct" only handles
            non-negative integers, not negative integers or floating point).

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5hex . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
