use v6;
use Test;
use Getopt::Tiny;

subtest {
    my @i;
    my @args = '-Ilib', '-I', 'blib/lib', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .str('I', -> $v { @i.push: $v })
        .parse(@args);
    is @i, <lib blib/lib>;
    is @positional, <a b c>;
}, 'string short';

subtest {
    my @i;
    my @args = '--inc=lib', '--inc', 'blib/lib', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .str(Nil, 'inc', -> $v { @i.push: $v })
        .parse(@args);
    is @i, <lib blib/lib>;
    is @positional, <a b c>;
}, 'string long';

subtest {
    my $x = False;
    my @args = '-x', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .bool('x', -> $v { $x = $v })
        .parse(@args);
    is $x, True;
    is @positional, <a b c>;
}, 'bool short';

subtest {
    my $pod = False;
    my $man-pages = True;
    my @args = '--pod', '--no-man-pages', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .bool('pod', -> $v { $pod = $v })
        .bool('man-pages', -> $v { $man-pages = $v })
        .parse(@args);
    is $pod, True;
    is $man-pages, False;
    is @positional, <a b c>;
}, 'bool long';

subtest {
    my @p;
    my @args = '-p8080', '-p', '9090', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .int('p', -> $v { @p.push: $v })
        .parse(@args);
    is @p, [8080, 9090];
    is @positional, <a b c>;
}, 'int short';

subtest {
    my @p;
    my @args = '-p8080', '--', '-p', '9090', 'a', 'b', 'c';
    my @positional = Getopt::Tiny.new()
        .str('p', -> $v { @p.push: $v })
        .parse(@args);
    is @p, [8080];
    is @positional, <-p 9090 a b c>;
}, '-- stops opt parse';

done-testing;
