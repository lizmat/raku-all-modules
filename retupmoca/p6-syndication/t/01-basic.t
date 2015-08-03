use v6;
use Test;
BEGIN { @*INC.unshift( 'lib' ) }

plan 3;

use-ok("Syndication");
use  Syndication;

my $title ="My Title";
my $link ="http://example.com/feed.xml";
my $summary ="My Summary";
my $author ="My Name";
my $updated =  DateTime.new("2015-07-27T20:00:00Z");

my $rss-item = Syndication::RSS::Item.new(:$title, :$link, :$summary, :$author, :$updated);

is $rss-item.XML, "<item><title>My Title</title><link>http://example.com/feed.xml</link><guid>http://example.com/feed.xml</guid><description>My Summary</description><pubDate>2015-07-27T20:00:00Z</pubDate><author>My Name</author></item>", 'got expected Syndication::RSS::Item';


my $atom-item = Syndication::Atom.new(:$title, :$link);

is $atom-item.XML, '<feed xmlns="http://www.w3.org/2005/Atom"><id>http://example.com/feed.xml</id><title>My Title</title><updated>-Inf</updated></feed>', 'got expected Syndication::Atom::Item';


