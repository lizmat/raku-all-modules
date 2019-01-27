use v6;
use Test;
use lib 'lib', 't/lib';;
use Pod::TreeWalker;
use TestListener;

my $pod_i = 0;

=begin pod
=head1 HEADING1
=head2 HEADING2
=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('heading'), :level(1) },
         { :start, :type('para') },
         { :text('HEADING1') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(1) },
         { :start, :type('heading'), :level(2) },
         { :start, :type('para') },
         { :text('HEADING2') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(2) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'single =head1';

=begin pod

    $code.goes-here;

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('code') },
         { :text('$code.goes-here;') },
         { :end, :type('code') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'code block';

=begin pod

=comment Trenchant

=end pod

subtest {

    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('comment') },
         { :text("Trenchant\n") },
         { :end, :type('comment') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'pod comment';

=begin pod

A simple paragraph.

And another.

=end pod

subtest {

    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('para') },
         { :text("A simple paragraph.") },
         { :end, :type('para') },
         { :start, :type('para') },
         { :text("And another.") },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'two paragraphs';

=begin pod

=begin table :caption('Foo and Bar')

    Name    Color    Size
    ===========================
    Foo     Blue     Fourty-Two
    Bar     Green    Seven

=end table

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('table'), :caption('Foo and Bar'), :headers([< Name Color Size >]) },
         { :table-row([< Foo Blue Fourty-Two > ]) },
         { :table-row([< Bar Green Seven > ]) },
         { :end, :type('table') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'table';

=begin pod

B<Bold>, I<italic>, and C<code>.

=end pod

subtest {
    my $l = TestListener.new;
    my $w = Pod::TreeWalker.new(:listener($l));
    $w.walk-pod($=pod[$pod_i]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('para') },
         { :start, :type('formatting-code'), :code-type('B'), :meta([]) },
         { :text('Bold') },
         { :end, :type('formatting-code'), :code-type('B'), :meta([]) },
         { :text(', ') },
         { :start, :type('formatting-code'), :code-type('I'), :meta([]) },
         { :text('italic') },
         { :end, :type('formatting-code'), :code-type('I'), :meta([]) },
         { :text(', and ') },
         { :start, :type('formatting-code'), :code-type('C'), :meta([]) },
         { :text('code') },
         { :end, :type('formatting-code'), :code-type('C'), :meta([]) },
         { :text('.') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';

    is $w.text-contents-of($=pod[$pod_i++]), 'Bold, italic, and code.', 'text content of pod';
}, 'formatting codes';

=begin pod
=config everything :with<feeling> :formatting<pretty>
=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :config-type('everything'), :config({ :with('feeling'), :formatting('pretty') }) },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'code block';

=begin pod
=head1 HEADING
=title TITLE GOES HERE

And a paragraph of text
=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('heading'), :level(1) },
         { :start, :type('para') },
         { :text('HEADING') },
         { :end, :type('para') },
         { :end, :type('heading'), :level(1) },
         { :start, :type('named'), :name('title') },
         { :start, :type('para') },
         { :text('TITLE GOES HERE') },
         { :end, :type('para') },
         { :end, :type('named'), :name('title') },
         { :start, :type('para') },
         { :text('And a paragraph of text') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    is-deeply $l.events, @expect, 'got expected events';
}, 'heading, named block, and paragraph';

=begin pod

=defn Term
Definition

=end pod

subtest {
    my $l = TestListener.new;
    Pod::TreeWalker.new(:listener($l)).walk-pod($=pod[$pod_i++]);

    my @expect = (
         { :start, :type('named'), :name('pod') },
         { :start, :type('defn') },
         { :start, :type('para') },
         { :text('Definition') },
         { :end, :type('defn') },
         { :end, :type('para') },
         { :end, :type('named'), :name('pod') },
    );

    todo( 'https://rt.perl.org/Ticket/Display.html?id=126651', 1 );
    is-deeply $l.events, @expect, 'got expected events';
}, '=defn block';

done-testing;
