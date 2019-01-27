use v6;
use Test;
use Pod::To::HTML;

plan 3;

=begin pod

=head1 Heading 1

=head2 Heading 1.1

=head2 Heading 1.2

=head1 Heading 2

=head2 Heading 2.1

=head2 Heading 2.2

=head2 L<(Exception) method message|/routine/message#class_Exception>

=head3 Heading 2.2.1

=head3 X<Heading> 2.2.2

=head1 Heading C<3>

=end pod

my $html = pod2html $=pod;

#put $html;

($html ~~ m:g/ ('2.2.2') /);

is so ($0 && $1 && $2), True, 'hierarchical numbering';

($html ~~ m:g/ 'href="#Heading_3"' /);

is so $0, True, 'link down to heading';

($html ~~ m:g/ ('name="index-entry-Heading"') /);

is so ($0 || $1), True, 'no X<> anchors in ToC';
