use v6.c;

use P5opendir:ver<0.0.4>:auth<cpan:ELIZABETH>;

class DirHandle:ver<0.0.2>:auth<cpan:ELIZABETH> {
    has $.dirhandle;

    method new($path) {
        opendir(my $dirhandle, $path) ?? self.bless(:$dirhandle) !! Nil
    }

    multi method open(DirHandle:U: $path) { DirHandle.new($path) }
    multi method open(DirHandle:D: $path) {
        closedir($!dirhandle);
        opendir($!dirhandle, $path) ?? self !! Nil
    }

    method close(\SELF:) {
        my $result := closedir($!dirhandle);
        SELF = Nil;
        $result
    }

    multi method read(Mu:U) {
        CALLERS::<$_> = readdir(Scalar, $!dirhandle)
    }
    multi method read(:$void!)
        is DEPRECATED('Mu as first positional')
    {
        CALLERS::<$_> = readdir(Scalar, $!dirhandle)
    }
    multi method read() { readdir(Scalar, $!dirhandle) }

    method rewind()         { rewinddir($!dirhandle)       }
    method tell()           { telldir($!dirhandle)         }
    method seek(Int() $pos) { seekdir($!dirhandle,$pos)    }

    method Str() { $!dirhandle.Str }
}

=begin pod

=head1 NAME

DirHandle - Port of Perl 5's DirHandle

=head1 SYNOPSIS

    use DirHandle;
    with Dirhandle.new(".") -> $d {
        while $d.read -> $entry { something($entry) }
        $d->rewind;
        while $d.read(:void) { something_else($_) }
        $d.close;
    }

=head1 DESCRIPTION

The DirHandle object provides an alternative interface to the C<opendir>,
C<closedir>, C<readdir>, C<telldir>, C<seekdir> and C<rewinddir> functions.

The only objective benefit to using DirHandle is that it avoids namespace
pollution.

=head1 PORTING CAVEATS

Since Perl 6 does not have a concept like void context, one needs to specify
C<Mu> as the only positional parameter with C<read> to mimic the behaviour of
C<DirHandle.read> of Perl 5 in void context.

The Perl 5 version of C<DirHandle> for some mysterious reason does not
contain methods for performing a C<telldir> or a C<seekdir>.  The Perl 6
version B<does> contain equivalent methods C<tell> and C<seek>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/DirHandle . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
