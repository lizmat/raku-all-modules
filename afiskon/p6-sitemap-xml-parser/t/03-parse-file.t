use v6;
use lib 'lib';
use Test;
use Sitemap::XML::Parser;

try {
    chdir('t');
    CATCH { return; }
}

my $parser = Sitemap::XML::Parser.new;
my $rslt = $parser.parse-file('sitemap.xml');

ok( $rslt[0]{'loc'}.isa('URI') );
$rslt[0]{'loc'} = $rslt[0]{'loc'}.Str;

ok( $rslt[0]{'lastmod'}.isa('DateTime') );
$rslt[0]{'lastmod'} = $rslt[0]{'lastmod'}.Str;

ok($rslt eqv [{loc=>'http://example.com/',lastmod=>'2005-01-01T00:00:00Z',changefreq=>'monthly',priority=>0.8}]);

done;
