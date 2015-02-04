use JSON::Path;
use JSON::Tiny;
use Test;

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

my $path1 = '$.store.book[*].title';

jpath_map { uc $_ }, $object, '$.store.book[*].title';

is_deeply(
	[ jpath1($object, $path1) ],
	[ map &uc, 'Sayings of the Century' ],
);

is_deeply(
	[ jpath($object, $path1) ],
	[ map &uc, 'Sayings of the Century', 'Sword of Honour', 'Moby Dick', 'The Lord of the Rings' ],
);

is(
	JSON::Path.new('$.store.book[*].author').set($object => 'Anon', 2),
	2,
);

is_deeply(
	[ jpath($object, '$.store.book[*].author') ],
	[ 'Anon', 'Anon', 'Herman Melville', 'J. R. R. Tolkien' ],
);

done();
