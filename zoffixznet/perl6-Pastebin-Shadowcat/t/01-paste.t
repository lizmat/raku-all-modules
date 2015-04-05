
use Test;
use Pastebin::Shadowcat;

plan 5;

my $paste_url = paste('Perl 6 Module Test<p>& foo', 'My Summary <>&');
ok $paste_url ~~ m:P5{^\Qhttp://fpaste.scsys.co.uk/\E\d+$},
    'Paste URL is sane';

my ( $content, $summary ) = get_paste($paste_url);
is $content, 'Perl 6 Module Test<p>& foo', 'Retrieved content is good';
is $summary, 'My Summary <>&', 'Retrieved summary is good';

( $content, $summary ) = get_paste( ($paste_url ~~ m:P5{(\d+)})[0] );
is $content, 'Perl 6 Module Test<p>& foo',
    'Retrieved content is good when using paste ID only';
is $summary, 'My Summary <>&',
    'Retrieved summary is good when using paste ID only';