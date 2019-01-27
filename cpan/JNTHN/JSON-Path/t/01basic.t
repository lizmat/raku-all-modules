use JSON::Path;
use JSON::Fast;
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

my $path1 = JSON::Path.new('$.store.book[0].title');
is("$path1", '$.store.book[0].title', "overloaded stringification");
given $path1.values($object) {
    is .elems, 1, 'Found one value result';
    is(.[0], 'Sayings of the Century', "Correct value result");
}
given $path1.paths($object) {
    is .elems, 1, 'Found one path';
    is(.[0], "\$.store.book[0].title", "Correct path result");
}

my $path2 = JSON::Path.new('$..book[-1:]');
given $path2.values($object) {
    is .elems, 1, '.. query got expected number of results';
    isa-ok(.[0], Hash, "Got expected hash result");
    is(.[0]<isbn>, "0-395-19395-8", "Got the correct hash");
}

dies-ok({
    my $path3 = JSON::Path.new('$..book[?(.<author> ~~ rx:i/tolkien/)]');
    my $results3 = $path3.values($object);
}, "eval disabled by default");

my $path3 = JSON::Path.new('$..book[?(.<author> ~~ rx:i/tolkien/)]', :allow-eval);
given $path3.values($object) {
    is .elems, 1, 'Query with evaluated Perl 6 code worked';
    isa-ok(.[0], Hash, "Query gave a hash result");
    is(.[0]<isbn>, "0-395-19395-8", "Query found correct hash entry");
}

my $path4 = JSON::Path.new('.store.book[*].title');
is-deeply $path4.values($object),
        (
            "Sayings of the Century",
            "Sword of Honour",
            "Moby Dick",
            "The Lord of the Rings"
        ),
        'Expression not rooted with $ and starting with . works';

my $path5 = JSON::Path.new('..title');
is-deeply $path5.values($object),
        (
            "Sayings of the Century",
            "Sword of Honour",
            "Moby Dick",
            "The Lord of the Rings"
        ),
        'Expression not rooted with $ and starting with .. works';

my $path6 = JSON::Path.new('store.book[*].title');
is-deeply $path6.values($object),
        (
            "Sayings of the Century",
            "Sword of Honour",
            "Moby Dick",
            "The Lord of the Rings"
        ),
        'Expression not rooted with $ and starting with property name works';

my $path7 = JSON::Path.new(q[..['title']]);
is-deeply $path7.values($object),
        (
            "Sayings of the Century",
            "Sword of Honour",
            "Moby Dick",
            "The Lord of the Rings"
        ),
        "The form ..['index'] works";

my $path8 = JSON::Path.new(q[..['title']]);
is-deeply $path8.paths-and-values($object),
        (
            "\$.store.book[0].title",
            "Sayings of the Century",
            "\$.store.book[1].title",
            "Sword of Honour",
            "\$.store.book[2].title",
            "Moby Dick",
            "\$.store.book[3].title",
            "The Lord of the Rings"
        ),
        "The form ..['index'] works";

my $path9 = JSON::Path.new('store.book.*.title');
is-deeply $path9.values($object),
        (
            "Sayings of the Century",
            "Sword of Honour",
            "Moby Dick",
            "The Lord of the Rings"
        ),
        'The .* syntax works';

my $path10 = JSON::Path.new('$.store.*');
is-deeply $path10.paths($object).sort.list,
        (
            '$.store.bicycle',
            '$.store.book',
        ),
        'Expression terminating with .* returns expected paths';

done-testing;
