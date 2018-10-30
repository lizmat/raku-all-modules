use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::TreeWalker;
use TestListener;

my $pod_i = 0;

#| before class
class Foo {
    has $.foo; #= a foo!
}

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('declarator'), :wherefore(Foo) },
         { :text('before class') },
         { :end, :type('declarator'), :wherefore(Foo) },
    );

    is-deeply $l.events, @expect, 'got expected events for class declarator';

    $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    # XXX - This WHEREFORE doesn't seem right
    @expect = (
         { :start, :type('declarator'), :wherefore(Any) },
         { :text('a foo!') },
         { :end, :type('declarator'), :wherefore(Any) },
    );

    is-deeply $l.events, @expect, 'got expected events for attribute declarator';
}, 'declarators';

done-testing;
