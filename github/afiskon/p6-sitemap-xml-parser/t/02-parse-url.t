use v6;
use lib 'lib';
use Test;
use Test::Mock;
use Sitemap::XML::Parser;

my $lwp = mocked(LWP::Simple, returning => {
        get => q{<urlset><url><loc>http://example.ru</loc></url></urlset>}.encode('ascii')
    });

my $parser = Sitemap::XML::Parser.new(lwp => $lwp);
my $rslt = $parser.parse-url('http://eax.me/sitemap.xml');

check-mock($lwp, *.called('get', times => 1));

ok( $rslt[0]{'loc'}.isa('URI') );
$rslt[0]{'loc'} = $rslt[0]{'loc'}.Str;

ok($rslt eqv [{ loc => "http://example.ru" }] );

done;
