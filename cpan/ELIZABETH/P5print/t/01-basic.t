use v6.c;
use Test;
use P5print;

plan 16;

# Cannot easily check whether print / printf / say were exported, as they
# are additions to the existing multi subs.

ok defined(::('&term:<STDIN>')),          'STDIN imported?';
ok !defined(P5print::{'&term:<STDIN>'}),  'STDIN externally NOT accessible?';
ok defined(::('&term:<STDOUT>')),         'STDOUT imported?';
ok !defined(P5print::{'&term:<STDOUT>'}), 'STDOUT externally NOT accessible?';
ok defined(::('&term:<STDERR>')),         'STDERR imported?';
ok !defined(P5print::{'&term:<STDERR>'}), 'STDERR externally NOT accessible?';

my $format;
my $said;

class FakeHandle {
    method print(*@_) { $said = @_.join }
    method printf($template, *@_) { $format = $template, $said = @_.join }
    method say(*@_) { $said = @_.join }
}

{
    my $*OUT = FakeHandle;
    my $*ERR = FakeHandle;

    print STDOUT, "foo";
    is $said, "foo", 'was "foo" said with print';

    printf STDOUT, "%s", "bar";
    is $format, '%s', 'did we get the right format';
    is $said, "bar", 'was "bar" said with printf';

    say STDOUT, "baz";
    is $said, "baz", 'was "baz" said with printf';

    print STDERR, "foo";
    is $said, "foo", 'was "foo" said with print to STDERR';

    printf STDERR, "%s", "bar";
    is $format, '%s', 'did we get the right format to STDERR';
    is $said, "bar", 'was "bar" said with printf to STDERR';

    say STDERR, "baz";
    is $said, "baz", 'was "baz" said with printf to STDERR';

    given "zippo" {
        print();  # alas, need ()
        is $said, $_, "was '$_' said with print";
    }

    given "zappo" {
        say();  # alas, need ()
        is $said, $_, "was '$_' said with say";
    }
}

# vim: ft=perl6 expandtab sw=4
