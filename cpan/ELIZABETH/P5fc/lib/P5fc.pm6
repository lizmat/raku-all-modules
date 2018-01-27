use v6.c;
unit class P5fc:ver<0.0.1>;

proto sub fc(|) is export {*}
multi sub fc(         --> Str:D) { (CALLERS::<$_>).fc }
multi sub fc(Str() $s --> Str:D) { $s.fc              }

=begin pod

=head1 NAME

P5fc - Implement Perl 5's fc() built-in

=head1 SYNOPSIS

  use P5fc;

  say fc("FOOBAR") eq fc("FooBar"); # true

  with "ZIPPO" {
      say fc();  # zippo, may need to use parens to avoid compilation error
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<fc> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5fc . Comments and
Pull Requests are wefcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
