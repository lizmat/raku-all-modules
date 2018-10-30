use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::TreeWalker;
use TestListener;

my class PickyListener is TestListener {
    multi method start (Pod::Block::Named $node) {
        callsame;
        if $node.name eq 'IGNORE' {
            return False;
        }
        return True;
    }
}

=begin pod

=IGNORE this content

=KEEP this content

=end pod

subtest {
    my $l = PickyListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[0]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('named'), :name('IGNORE') },
         { :start, :type('named'), :name('KEEP') },
         { :start, :type('para') },
         { :text('this content') },
         { :end, :type('para') },
         { :end, :type('named'), :name('KEEP') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'when NodeListener object returns false from start method, contents are ignored';

done-testing;
