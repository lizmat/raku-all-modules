use v6;

use lib <lib ../lib>;

use Test;
use Test::When <online>;
use Pod::To::BigPage;

# Test the rendering of a full page
plan 7;

=begin pod

=head1 This is the head X<|indexed head>

=head2 More stuff here

And just your average text.
=end pod

setup();
say $=pod;
# Tests start here
like compose-before-content($=pod), /This\s+is\s+the\s+head/, "Head inserted";
like compose-before-content($=pod, 'x'), /xml \s+ version/, "Head with xml inserted";
like compose-before-content($=pod, ''), /DOCTYPE \s+ html/, "Head with html inserted";
for $=pod[0].contents -> $pod-part {
    my $html = handle( $pod-part, pod-name => "/language/test",
                       part-number => 1,
                       toc-counter =>  TOC-Counter.new.set-part-number(0),
                       part-config => {:head1(:numbered(True)),:head2(:numbered(True))} );
    say $html;
    like $html, /{$pod-part.contents}/, "Inserts text with parts";
}

like handle( $=pod[0].contents[0],
             pod-name => "/language/test",
             part-number => 1,
             toc-counter =>  TOC-Counter.new.set-part-number(0),
             part-config => {:head1(:numbered(True)),
                             :anchored(True)
                            }
           ),
/a \s+ name/, "Anchors inserted when you want them";
