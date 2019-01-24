unit module Temp::Path;

use Digest::SHA;
use File::Directory::Tree;

my Channel $GOODS .= new;
END { $GOODS.send: ('nuke',); await $GOODS.closed }
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
