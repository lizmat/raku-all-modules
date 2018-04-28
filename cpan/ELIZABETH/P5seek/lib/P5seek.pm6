use v6.c;

unit module P5seek:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub seek(|) is export {*}
multi sub seek(IO::Handle:D $handle, Int() $pos, Int() $whence --> True) {
    $handle.seek($pos,SeekType.^enum_value_list[$whence])
}

# exporting enums appears to be tricky
sub term:<SEEK_SET>(--> 0) is export { }
sub term:<SEEK_CUR>(--> 1) is export { }
sub term:<SEEK_END>(--> 2) is export { }

=begin pod

=head1 NAME

P5seek - Implement Perl 5's seek() built-in

=head1 SYNOPSIS

  use P5seek;

  seek($filehandle, 42, 0);

  seek($filehandle, 42, SEEK_SET); # same, SEEK_CUR / SEEK_END also available

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<seek> function of Perl 5
as closely as possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5seek . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
