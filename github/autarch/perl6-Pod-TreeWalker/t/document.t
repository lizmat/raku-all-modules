use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::TreeWalker;
use TestListener;

=begin pod

=NAME Some::Module

Abstract goes here

=SYNOPSIS

    use Some::Module;
    my $m = Some::Module.new( :foo(42) );
    $m.do-your-thing;

=DESCRIPTION

This module does something amazing!

=end pod

# we just need some code here to break up the POD. It doesn't matter what it
# is, really.
my $l = TestListener.new;
Pod::TreeWalker.new(:listener($l)).walk-pod($=pod);

my $code = "use Some::Module;\nmy \$m = Some::Module.new( :foo(42) );\n\$m.do-your-thing;";

my @expect = (
    { :start, :type('named'), :name('pod') },
    { :start, :type('named'), :name('NAME') },
    { :start, :type('para') },
    { :text('Some::Module') },
    { :end, :type('para') },
    { :end, :type('named'), :name('NAME') },
    { :start, :type('para') },
    { :text('Abstract goes here') },
    { :end, :type('para') },
    { :start, :type('named'), :name('SYNOPSIS') },
    { :end, :type('named'), :name('SYNOPSIS') },
    { :start, :type('code') },
    { :text($code) },
    { :end, :type('code') },
    { :start, :type('named'), :name('DESCRIPTION') },
    { :end, :type('named'), :name('DESCRIPTION') },
    { :start, :type('para') },
    { :text('This module does something amazing!') },
    { :end, :type('para') },
    { :end, :type('named'), :name('pod') },
    { :start, :type('named'), :name('pod') },
    { :start, :type('named'), :name('AUTHOR') },
    { :start, :type('para') },
    { :text('Dave Rolsky <autarch@urth.org>') },
    { :end, :type('para') },
    { :end, :type('named'), :name('AUTHOR') },
    { :end, :type('named'), :name('pod') },
);

is-deeply $l.events, @expect, 'got expected events for pod document';

done-testing;

=begin pod

=AUTHOR Dave Rolsky <autarch@urth.org>

=end pod
