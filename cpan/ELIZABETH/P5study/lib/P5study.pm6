use v6.c;
unit module P5study:ver<0.0.1>;

proto sub study(|) is export {*}
multi sub study()   { }
multi sub study(\a) { }

=begin pod

=head1 NAME

P5study - Implement Perl 5's study() built-in

=head1 SYNOPSIS

  use P5study; # exports study()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<study> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

Currently, C<study> is a no-op in Perl 6.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5study . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
