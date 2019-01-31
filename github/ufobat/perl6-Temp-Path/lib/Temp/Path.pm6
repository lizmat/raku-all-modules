unit module Temp::Path:ver<1.001007>;

use Digest::SHA;
use File::Directory::Tree;

my Channel $GOODS .= new;
END { with $GOODS { .send: ('nuke',); await $_.closed } }
{
    my %goods is SetHash; # state is busted in whenever; RT#131508
    start react whenever $GOODS -> ($_, $path?) {
        sub nuke-path (IO() $p) {
            CATCH { when X::IO::Dir { $p.rmdir.so } }
            $p.d ?? $p.&rmtree !! $p.e && $p.unlink
        }
        when 'add'    {                 %goods{$path}++                      }
        when 'delete' {   nuke-path     %goods{$path}:delete:k               }
        when 'nuke'   { .&nuke-path for %goods{  *  }:delete:k; $GOODS.close }
        die 'Unknown $GOODS command';
        CATCH { say "Error in Temp::Path: ", $_ }
    }
}

sub make-rand-path (Str:D $prefix, Str:D $suffix --> IO::Path) {
    my $p = $*TMPDIR;
    # XXX TODO .resolve is broken on Windows in Rakudo; .resolve for all OSes
    # when it is fixed
    $p .= resolve unless $*DISTRO.is-win;
    loop {
        my $filename = (
            rand, $*PROGRAM.basename, (try callframe(3).code.line)||'',
            rand, time, rand
        ).join.encode('utf8-c8').&sha256».fmt('%02X').join;
        $p = $p.resolve.add: ($prefix, $filename, $suffix).join;
        last unless $p.e;
        $++ > 10 and die 'IO::Path module failed to create a unique path'
    }

    my role AutoDel [IO::Path:D $orig] {
        submethod DESTROY {
            CATCH { when X::Channel::SendOnClosed { } }; # ignore - happens if 'nuke' invokes DESTROY
            $GOODS.send: ('delete', $orig.absolute) if self === $orig;
        }
        method to-IO-Path { self.absolute.IO }
    }
    $p does AutoDel[$p]
}

sub term:<make-temp-path> (
    :$content where Any|Blob:D|Cool:D,
    Int :$chmod,
    Str() :$suffix = '',
    Str() :$prefix = '',
    --> IO::Path:D
) is export
{
    $GOODS.send: ('add', (my \p = make-rand-path($prefix, $suffix)).absolute);
    with   $chmod   { p.spurt: $content // ''; p.chmod: $_ }
    orwith $content { p.spurt: $_ }
    p
}
sub term:<make-temp-dir> (
    Int :$chmod,
    Str() :$suffix = '',
    Str() :$prefix = '',
    --> IO::Path:D
) is export {
    $GOODS.send: ('add', (my \p = make-rand-path($prefix, $suffix)).absolute);
    with $chmod { p.mkdir: $chmod; p.chmod: $chmod }
    else { p.mkdir }
    p
}

=begin pod
=head1 NAME

Temp::Path - Make a temporary path, file, or directory

=head1 SYNOPSIS

=begin code
use Temp::Path;

with make-temp-path {
        .spurt: 'meows';
    say .slurp: :bin; # OUTPUT: «Buf[uint8]:0x<6d 65 6f 77 73>␤»
    say .absolute;    # OUTPUT: «/tmp/1E508EE56B7C069B7ABB7C71F2DE0A3CE40C20A1398B45535AF3694E39199E9A␤»
}

with make-temp-path :content<meows> :chmod<423> :suffix<.txt> {
    .slurp.say; # OUTPUT: «meows␤»
    .mode .say; # OUTPUT: «0647␤»
    say .absolute; # OUTPUT «/tmp/8E548EE56B7C119B7ABB7C71F2DE0A3CE40C20A1398B45535AF3694E39199EAE.txt␤»
}

with make-temp-dir {
    .add('meows').spurt: 'I ♥ Perl 6!';
    .dir.say; # OUTPUT: «("/tmp/B42F3C9D8B6A0C5C911EE24DD93DD213F1CE1DD0239263AC3A7D29A2073621A5/meows".IO)␤»
}

{
    temp $*TMPDIR = make-temp-dir :chmod<0o700>;
    $*TMPDIR.say;
    # OUTPUT:
    # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E".IO

    say make-temp-path;
    # OUTPUT:
    # "/tmp/F5AA112627DA7B59C038900A3C8C7CB05477DCCCEADF2DC447EC304017A1009E/…
    # …C41E7114DD24C65C6722981F8C5693E762EBC5958238E23F7B324A1BDD37A541".IO
}
=end code

=head1 EXPORTED TERMS

This module exports terms (not subroutines), so you don't need to use
parentheses to avoid block gobbling errors. Just use these same way as you'd
use constant `π`

If you have to use parens for some reason, make them go around the
whole them, not just the args:

     make-temp-path(:content<foo> :chmod<423>) # WRONG
     (make-temp-path :content<foo> :chmod<423>) # RIGHT

=head2 C<make-temp-path>

Defined as:

    sub term:<make-temp-path> (
        :$content where Any|Blob:D|Cool:D,
        Int :$chmod,
        Str() :$prefix = '',
        Str() :$suffix = ''
        --> IO::Path:D
    )


Creates an L<IO::Path|https://docs.perl6.org/type/IO::Path> object pointing
to a path inside
L<$*TMPDIR|https://docs.perl6.org/language/variables#index-entry-%24%2ATMPDIR>
that will be deleted (see L<DETAILS OF DELETION|#details-of-deletion>
section below).

Unless C<:$chmod> or C<:$content> are given, no files will be created. If
C<:$chmod> is given a file containing C<:$content> (or empty, if no C<:$content> is
given) will be created with C<$chmod>
L<permissions|https://docs.perl6.org/type/IO::Path#method_chmod>. If C<:$content>
is given without C<:$chmod>, the mode will be the default resulting from
files created with
L<IO::Handle.open|https://docs.perl6.org/type/IO::Handle#method_open>.

The L<basename|https://docs.perl6.org/type/IO::Path#method_basename>
of the path is currently a SHA256 hash, but your program should
not make assumptions about the format of the basename.

B<Security Note:> at the moment, C<:chmod> is set I<after> the file is
created and its content is written. This will be fixed once a way to create a
file with a specific mode is available in Rakudo. While it will work at the
moment, it might not be the best idea to assume C<:$content> will be successfully
written if you set C<:$chmod> that does not let the current process write to the
file.

=head2 C<make-temp-dir>

Defined as:

    sub term:<make-temp-dir> (Int :$chmod, Str() :$prefix = '', Str() :$suffix = '' --> IO::Path:D)

Creates a directory inside
L<$*TMPDIR|https://docs.perl6.org/language/variables#index-entry-%24%2ATMPDIR>
that will be deleted (see L<DETAILS OF DELETION|#details-of-deletion>
section below) and returns the
L<IO::Path|https://docs.perl6.org/type/IO::Path> object pointing to it.

If C<:$chmod> is provided, the directory will be created with that mode.
Otherwise,  the default C<.mkdir>
L<mode|https://docs.perl6.org/type/IO::Path#routine_mkdir> will be used.

Note that currently C<.mkdir> pays attention to
L<umask|https://en.wikipedia.org/wiki/Umask> and C<make-temp-dir> will first
the C<:$chmod> to C<.mkdir>, to create C<umask> masked directory, and then it will
L<.chmod|https://docs.perl6.org/type/IO::Path#method_chmod> it, to remove
the effects of the C<umask>.

=head1 DETAILS OF DELETION

The deletion of files created by this module will happen either when
the returned C<IO::Path> objects are garbage collected or when the C<END> phaser
gets run. Note that this means temporary files/directories may be left behind
if your program crashes or gets aborted.

The temporary C<IO::Path> objects created by C<make-temp-path> and C<make-temp-dir>
terms have a role C<Temp::Path::AutoDel> mixed in that will
L<rmtree|https://github.com/labster/p6-file-directory-tree#rmtree> or
L<.unlink|https://docs.perl6.org/type/IO::Path#routine_unlink> the filesystem
object the path points to.

Note that deletion will happen only if the
path was created by this module. For example doing C<make-temp-dir.sibling: 'foo'> will
still give you an C<IO::Path> with C<Temp::Path::AutoDel> mixed in due to how
C<IO::Path> methods create new objects. But new objects created by C<.sibling>, C<.add>,
C<.child>, C<.parent>, etc won't be deleted, when the object gets garbage collected, because
I<you> created it and not the module. Of course, when a parent directory, that
was created by this module gets deleted, all its contents that you created with C<.child>
gets removed from the disk. Siblings need to be removed manually.


=head1 REPOSITORY

Fork this module on GitHub:
https://github.com/ufobat/perl6-Temp-Path

=head1 BUGS

To report bugs or request features, please use
https://github.com/ufobat/perl6-Temp-Path/issues

=head1 AUTHOR

=item Zoffix Znet (http://perl6.party/)
=item Martin Barth (ufobat)

=head1 LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the LICENSE file included in this
distribution for complete details.

The META6.json file of this distribution may be distributed and modified
without restrictions or attribution.

=end pod
=finish
