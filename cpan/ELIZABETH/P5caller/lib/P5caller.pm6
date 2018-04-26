use v6.c;
unit module P5caller:ver<0.0.3>;

proto sub caller(|) is export {*}
multi sub caller(            --> List:D) { backtrace(1)     }
multi sub caller(Int() $down --> List:D) { backtrace($down) }

my sub backtrace($down is copy --> List:D) {
    $down += 3;  # offset heuristic
    my $backtrace := Backtrace.new;
    my $index = 0;
    $index = $backtrace.next-interesting-index($index, :named, :noproto)
      for ^$down;
    my $frame := Backtrace.new.AT-POS($index);
    ($frame.code.package.^name,$frame.file,$frame.line,$frame.subname,$frame.code)
}

=begin pod

=head1 NAME

P5caller - Implement Perl 5's caller() built-in

=head1 SYNOPSIS

  use P5caller;

  sub foo { bar }
  sub bar { say caller[3] } # foo

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<caller> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

In Perl 5, C<caller> can return an 11 element list.  In the Perl 6 implementation
only the first 4 elements are the same as in Perl 5: package, filename, line,
subname.  The fifth element is actually the C<Sub> or C<Method> object and as
such provides further introspection possibilities not found in Perl 5.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5caller . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
