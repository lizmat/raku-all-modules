use v6.c;

=begin pod

=head1 NAME

Fcntl - load the C Fcntl.h defines

=head1 SYNOPSIS

    use Fcntl;
    use Fcntl qw(:DEFAULT :flock);

=head1 DESCRIPTION

This module is just a translation of the C F<fcntl.h> file.
Unlike the old mechanism of requiring a translated F<fcntl.ph>
file, this uses the B<h2xs> program (see the Perl source distribution)
and your native C compiler.  This means that it has a
far more likely chance of getting the numbers right.

=head1 NOTE

Only C<#define> symbols get translated; you must still correctly
pack up your own arguments to pass as args for locking functions, etc.

=head1 EXPORTED SYMBOLS

By default your system's F_* and O_* constants (eg, F_DUPFD and
O_CREAT) and the FD_CLOEXEC constant are exported into your namespace.

You can request that the flock() constants (LOCK_SH, LOCK_EX, LOCK_NB
and LOCK_UN) be provided by using the tag C<:flock>.  See L<Exporter>.

You can request that the old constants (FAPPEND, FASYNC, FCREAT,
FDEFER, FEXCL, FNDELAY, FNONBLOCK, FSYNC, FTRUNC) be provided for
compatibility reasons by using the tag C<:Fcompat>.  For new
applications the newer versions of these constants are suggested
(O_APPEND, O_ASYNC, O_CREAT, O_DEFER, O_EXCL, O_NDELAY, O_NONBLOCK,
O_SYNC, O_TRUNC).

For ease of use also the SEEK_* constants (for seek() and sysseek(),
e.g. SEEK_END) and the S_I* constants (for chmod() and stat()) are
available for import.  They can be imported either separately or using
the tags C<:seek> and C<:mode>.

Please refer to your native fcntl(2), open(2), fseek(3), lseek(2)
(equal to Perl's seek() and sysseek(), respectively), and chmod(2)
documentation to see what constants are implemented in your system.

See L<perlopentut> to learn about the uses of the O_* constants
with sysopen().

See L<perlfunc/seek> and L<perlfunc/sysseek> about the SEEK_* constants.

See L<perlfunc/stat> about the S_I* constants.

=cut

=end pod

unit module Fcntl:ver<0.0.1>:auth<github:manchicken>;
