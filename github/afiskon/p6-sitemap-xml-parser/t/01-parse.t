use v6;
use lib 'lib';
use Test;
use Sitemap::XML::Parser;

my @invalid = (
    'trash',
    '<bebebe />',
    '<urlset><bebebe /></urlset>',
    '<urlset>data</urlset>',
    '<urlset><![CDATA[data]]></urlset>',
    '<urlset><url></url></urlset>',
    '<urlset><url><bebebe /></url></urlset>',
    '<urlset><url><loc></loc></url></urlset>',
    '<urlset><url><loc>%%%%%%</loc></url></urlset>',
    '<urlset><url><loc>http://example.ru/</loc><bebebe /></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><changefreq> monthly </changefreq></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><changefreq>bebebe</changefreq></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><changefreq><tag /></changefreq></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><priority /></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><priority></priority></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><priority>bebebe</priority></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><priority>-0.0000001</priority></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><priority>1.0000001</priority></url></urlset>', 
    '<urlset><url><loc>http://example.ru/</loc><lastmod>bebebe</lastmod></url></urlset>',
    '<urlset><url><lastmod>2012-08-30T04:20:04Z</lastmod><changefreq>monthly</changefreq><priority>0.2</priority></url></urlset>',
);

my ( @valid_sitemaps, @valid_results );
@valid_sitemaps.push:
    q{<urlset>
        <url>
            <loc>http://example.ru/</loc>
            <lastmod>2012-08-30T04:20:04+00:00</lastmod>
            <changefreq>monthly</changefreq>
            <priority>0.2</priority>
        </url>
    </urlset>};
@valid_sitemaps.push:
    q{<?xml ?><urlset>
        <url>
            <priority>0.2</priority>
            <lastmod>2012-08-30T04:20:04+00:00</lastmod>
            <loc>http://example.ru/</loc>
            <changefreq>monthly</changefreq>
        </url>
    </urlset>};

for 1..2 {
    @valid_results.push: [
        {
            loc => 'http://example.ru/',
            lastmod => '2012-08-30T04:20:04Z',
            changefreq => 'monthly',
            priority => 0.2
        },
    ];
}

@valid_sitemaps.push:
    q{<?xml version="1.0" encoding="UTF-8"?>
      <?xml-stylesheet type="text/xsl" href="http://example.ru/wp-content/plugins/google-sitemap-generator/sitemap.xsl"?>
<!-- generator="wordpress/3.4.1" -->
<!-- sitemap-generator-url="http://www.arnebrachhold.de" sitemap-generator-version="3.2.8" -->
<!-- generated-on="06.09.2012 03:23" -->
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
        xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">	<url>
		<loc>http://username:password@xn--d1abbgf6aiiy.xn--p1ai:8080/</loc>
		<lastmod>2012-09-06T03:22:42+00:00</lastmod>
		<changefreq>daily</changefreq>
		<priority>1.0</priority>
	</url>
	<url>
		<loc>http://example.ru/perl6-install/</loc>
		<priority>0.2</priority>
	</url>
	<url>
		<loc>http://example.ru/erlang/</loc>
	</url>
    </urlset>};
@valid_results.push: [
    {
        loc => 'http://username:password@xn--d1abbgf6aiiy.xn--p1ai:8080/',
        lastmod => '2012-09-06T03:22:42Z',
        changefreq => 'daily',
        priority => 1.0
    },
    {
        loc => 'http://example.ru/perl6-install/',
        priority => 0.2
    },
    {
        loc => 'http://example.ru/erlang/',
    },
];

my @changefreq_list = qw/always hourly daily weekly monthly yearly never/;
for @changefreq_list -> $changefreq {
    @valid_sitemaps.push:
        qq{<urlset>
            <url>
                <loc>http://example.ru/</loc>
                <changefreq>$changefreq\</changefreq>
            </url>
          </urlset>};
    @valid_results.push: [
        {
            loc => 'http://example.ru/',
            changefreq => $changefreq,
        },
    ];
}

my $parser = Sitemap::XML::Parser.new;

for @invalid -> $sitemap {
    dies-ok({ $parser.parse($sitemap) });
}

for @valid_sitemaps Z @valid_results -> ($sitemap, $struct) {
    my $rslt = $parser.parse($sitemap);

    for $rslt.values -> $item is rw {
        ok( $item{'loc'}.isa('URI') );
        $item{'loc'} = $item{'loc'}.Str;

        next unless defined $item{'lastmod'};
        ok( $item{'lastmod'}.isa('DateTime') );
        $item{'lastmod'} = $item{'lastmod'}.Str;
    }

    ok( $rslt eqv $struct );
}

done;

