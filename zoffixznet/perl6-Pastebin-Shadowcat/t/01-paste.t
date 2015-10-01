
use v6;
use Test;
use lib 'lib';
use Pastebin::Shadowcat;

my $paste_url = paste("Perl 6 Module Test<p>\n& <pre>foo", 'My Summary <>&');
ok $paste_url ~~ /^^ 'http://fpaste.scsys.co.uk/'  \d+ $$/,
    "Paste URL [$paste_url] is sane";

my ( $content, $summary ) = get_paste($paste_url);
is $content, "Perl 6 Module Test<p>\n& <pre>foo", 'Retrieved content is good';
is $summary, 'My Summary <>&', 'Retrieved summary is good';

( $content, $summary ) = get_paste( ($paste_url ~~ /(\d+)/)[0] );
is $content, "Perl 6 Module Test<p>\n& <pre>foo",
    'Retrieved content is good when using paste ID only';
is $summary, 'My Summary <>&',
    'Retrieved summary is good when using paste ID only';

done-testing;