use lib 'lib';
use Test;
use IO::Path::ChildSecure;

plan 10;

##### Testo

sub make-rand-path (--> IO::Path:D) {
    $*TMPDIR.resolve.child: (
        'perl6_roast_',
        $*PROGRAM.basename, '_line',
        ((try callframe(3).code.line)||''), '_',
        rand,
        time,
    ).join.subst: :g, /\W/, '_';
}
my @FILES-FOR-make-temp-file;
my @DIRS-FOR-make-temp-dir;
END {
    unlink @FILES-FOR-make-temp-file;
    rmdir  @DIRS-FOR-make-temp-dir;
}
sub make-temp-file
    (:$content where Any:U|Blob|Cool, Int :$chmod --> IO::Path:D) is export
{
    @FILES-FOR-make-temp-file.push: my \p = make-rand-path;
    with   $chmod   { p.spurt: $content // ''; p.chmod: $_ }
    orwith $content { p.spurt: $_ }
    p
}
sub make-temp-dir (Int $chmod? --> IO::Path:D) is export {
    @DIRS-FOR-make-temp-dir.push: my \p = make-rand-path;
    p.mkdir;
    p.chmod: $_ with $chmod;
    p
}

sub failuring-like (&test, $ex-type, $reason?, *%matcher) is export {
    subtest $reason => sub {
        plan 2;
        CATCH { default {
            with "expected code to fail but it threw {.^name} instead" {
                .&flunk;
                .&skip;
                return False;
            }
        }}
        my $res = test;
        isa-ok $res, Failure, 'code returned a Failure';
        throws-like { $res.sink }, $ex-type,
            'Failure threw when sunk', |%matcher,
    }
}

###### END Testo

my $parent = make-temp-dir;
my $non-resolving-parent = make-temp-file.child('bar');

sub is-path ($got, $expected, $desc) {
    cmp-ok $got.resolve, '~~', $expected.resolve, $desc
}

failuring-like { $non-resolving-parent.&child-secure('../foo') }, X::IO::Resolve,
    'non-resolving parent fails (given path is non-child)';

failuring-like { $non-resolving-parent.&child-secure('foo') }, X::IO::Resolve,
    'non-resolving parent fails (given path is child)';

failuring-like { $parent.&child-secure('foo/bar') }, X::IO::Resolve,
    'resolving parent fails (given path is a child, but not resolving)';

failuring-like { $parent.&child-secure('../foo') }, X::IO::NotAChild,
    'resolved parent fails (given path is not a child)';

is-path $parent.&child-secure('foo'), $parent.child('foo'),
    'resolved parent with resolving, non-existent child';

$parent.child('foo').mkdir;
is-path $parent.&child-secure('foo'), $parent.child('foo'),
    'resolved parent with resolving, existent child';

is-path $parent.&child-secure('foo/bar'), $parent.child('foo/bar'),
    'resolved parent with resolving, existent child in a subdir';

is-path $parent.&child-secure('foo/../bar'), $parent.child('bar'),
    'resolved parent with resolving, non-existent child, with ../';

failuring-like { $parent.&child-secure('foo/../../bar') }, X::IO::NotAChild,
    'resolved parent fails (given path is not a child, via child + ../)';

failuring-like { $parent.&child-secure("../\x[308]") }, X::IO::NotAChild,
'resolved parent fails (given path is not a child, via combiners)';
