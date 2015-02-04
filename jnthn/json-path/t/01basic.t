use Test;
plan 9;

use JSON::Path;
use JSON::Tiny;

my $object = from-json(q'
{
	"store": {
		"book": [
			{
				"category": "reference",
				"author":   "Nigel Rees",
				"title":    "Sayings of the Century",
				"price":    8.95
			},
			{
				"category": "fiction",
				"author":   "Evelyn Waugh",
				"title":    "Sword of Honour",
				"price":    12.99
			},
			{
				"category": "fiction",
				"author":   "Herman Melville",
				"title":    "Moby Dick",
				"isbn":     "0-553-21311-3",
				"price":    8.99
			},
			{
				"category": "fiction",
				"author":   "J. R. R. Tolkien",
				"title":    "The Lord of the Rings",
				"isbn":     "0-395-19395-8",
				"price":    22.99
			}
		],
		"bicycle": {
			"color": "red",
			"price": 19.95
		}
	}
}
');

my $path1 = JSON::Path.new('$.store.book[0].title');
is("$path1", '$.store.book[0].title', "overloaded stringification");

my @results1 = $path1.values($object);
is(@results1[0], 'Sayings of the Century', "basic value result");

@results1 = $path1.paths($object);
is(@results1[0], "\$['store']['book']['0']['title']", "basic path result");

my $path2 = JSON::Path.new('$..book[-1:]');
my ($results2) = $path2.values($object);

ok($results2 ~~ Hash, "hashref value result");
is($results2<isbn>, "0-395-19395-8", "hashref seems to be correct");

ok($JSON::Path::Safe, "safe by default");

dies_ok({
    my $path3 = JSON::Path.new('$..book[?(.<author> ~~ rx:i/tolkien/)]');
    my $results3 = $path3.values($object);
    1;
}, "eval disabled by default");

$JSON::Path::Safe = False;

my $path3 = JSON::Path.new('$..book[?(.<author> ~~ rx:i/tolkien/)]');
my ($results3) = $path3.values($object);

ok($results3 ~~ Hash, "dangerous hashref value result");
is($results3<isbn>, "0-395-19395-8", "dangerous hashref seems to be correct");
