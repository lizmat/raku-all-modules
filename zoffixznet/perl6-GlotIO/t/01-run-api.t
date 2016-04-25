use lib 'lib';

use Test;
use GlotIO;

my GlotIO $glot .= new: key => 't/key'.IO.lines[0];

subtest {
    my $langs = $glot.languages;
    is $langs.WHAT, Seq, 'returns a Seq';
    ok <perl perl6 ruby python> ⊆ $langs, 'returned stuff looks sane';
}, '.languages method';

subtest {
    my $versions = $glot.versions: 'python';
    is $versions.WHAT, Seq, 'returns a Seq';
    ok ("2", "latest") ⊆ $versions, 'returned stuff looks sane';
}, '.versions method';

subtest {
    my $ret = $glot.run: 'perl6', 'say "Hello, World!"';
    is $ret.WHAT, Hash, 'returns a Hash';
    is-deeply $ret, { error => '', stderr =>  '', stdout => "Hello, World!\n" },
        'return value is correct';

    $ret = $glot.run: 'perl6', [
        'main.p6' => 'use lib "."; use Foo; doit;',
        'Foo.pm6' => 'unit module Foo; sub doit is export { say "42" }',
    ];
    is-deeply $ret, { error => '', stderr =>  '', stdout => "42\n" },
        'return value is correct with multiple files';

    $ret = $glot.run: 'python', 'print "Hello, World!"', :ver<2>;
    is-deeply $ret, { error => '', stderr =>  '', stdout => "Hello, World!\n" },
        'return value is correct with explicit version';

    $ret = $glot.run: 'python', 'print "Hello, World!"', :ver<latest>;
    is $ret<error>, 'exit status 1', 'got error with failing code';
    like $ret<stderr>, /'File' .+ 'line' .+ 'Hello, World'/,
        'STDERR has the error message';
    is $ret<stdout>, '', 'STDOUT is empty';
}, '.run method';

subtest {
    my $ret = $glot.stdout: 'perl6', 'say "Hello, World!"';
    is $ret, "Hello, World!\n", 'return value is correct';

    $ret = $glot.stdout: 'perl6', [
        'main.p6' => 'use lib "."; use Foo; doit;',
        'Foo.pm6' => 'unit module Foo; sub doit is export { say "42" }',
    ];
    is $ret, "42\n", 'return value is correct with multiple files';

    $ret = $glot.stdout: 'python', 'print "Hello, World!"', :ver<2>;
    is $ret, "Hello, World!\n",
        'return value is correct with explicit version';

    $ret = $glot.stdout: 'python', 'print "Hello, World!"', :ver<latest>;
    is $ret.WHAT, Failure, 'got a Failure on failing code';
}, '.stdout method';

done-testing;