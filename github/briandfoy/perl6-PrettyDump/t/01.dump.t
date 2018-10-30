use v6;
use Test;

constant package-name = 'PrettyDump';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);
can-ok $class, 'new' or bail-out "$class cannot .new";

my $p = $class.new;
can-ok $p, 'dump' or bail-out "{$p.^name} cannot .dump";

subtest {
	is $p.dump(Nil), q<Nil>, q<Empty call works.>;
	is $p.dump(Any), q<Any>, q<You can call it with (Any)thing.>;
	}, 'trivial';

subtest {
	is $p.dump(False),    q<False>,    q<False works.>;
	is $p.dump(True),     q<True>,     q<True works.>;
	is $p.dump(0),        q<0>,        q<0 works.>;
	is $p.dump(1),        q<1>,        q<1 works.>;
	is $p.dump(1.234-2i), q<1.234-2i>, q<1.234-2i works.>;
	is $p.dump(''),       q<"">,       q<Empty strings quotify.>;
	is $p.dump(""),       q<"">,       q<Even interpolated strings.>;
	}, 'scalar';

subtest {
	is $p.dump( [] ),    q<Array=[]>,    q<Empty arrayref works>;
	is $p.dump( [Any] ), qq/Array=\[\n\tAny\n]/, q<As does an arrayref with an empty element>;
	is $p.dump( [1] ),   qq/Array=\[\n\t1\n]/,   q<Or even one with a single scalar.>;
	is $p.dump( [[]] ),  q<Array=[]>,    q<Empty arrayrefs flatten>;
	is $p.dump( [{}] ),  q<Array=[]>,    q<As do empty blocks.>;
	}, 'arrayref';

subtest {
	is $p.dump( {} ),       q<Hash={}>, q<Empty hashref works>;
	is $p.dump( {a=>Any} ), qq<Hash=\{\n\t:a(Any)\n}>, q<As does a hashref with a single item>;
	is $p.dump( {a=>[]} ),  qq<Hash=\{\n\t:a(Array=\[])\n}>, q<And a hashref with an embedded reference.>;
	}, 'hashref';

subtest {

	subtest {
		my $q = $class.new(
			intra-group-spacing => "\n",
			pre-item-spacing    => "\n",
			);
		is $q.dump( [] ),          qq<Array=\[\n]>,
								 q<Newline after open-bracket>;
		is $q.dump( [1] ),         qq<Array=\[\n\t1\n]>,
								 q<And only between open-bracket and first item>;
		is $q.dump( [1,2] ),       qq<Array=\[\n\t1,\n\t2\n]>,
								 q<Even in the presence of multiple items.>;
		is $q.dump( {} ),          qq<Hash=\{\n}>,
								 q<Newline after open-brace>;
		is $q.dump( {1=>2 } ),     qq<Hash=\{\n\t:1(2)\n}>,
								 q<And only between open-brace and first item>;
		is $q.dump( {1=>2,3=>4} ), qq<Hash=\{\n\t:1(2),\n\t:3(4)\n}>,
								 q<Even in the presence of multiple items.>;
		}, 'beginning newline';

	subtest {
		my $q = $class.new(
			intra-group-spacing => "\n",
			post-item-spacing   => "\n",
			);
		is $q.dump( [] ),          qq<Array=\[\n]>,
								 q<Newline before close-bracket>;
		is $q.dump( [1] ),         qq<Array=\[\n\t1\n]>,
								 q<And only between close-bracket and first item>;
		is $q.dump( [1,2] ),       qq<Array=\[\n\t1,\n\t2\n]>,
								 q<Even in the presence of multiple items.>;
		is $q.dump( {} ),          qq<Hash=\{\n}>,
								 q<Newline before close-brace>;
		is $q.dump( {1=>2} ),      qq<Hash=\{\n\t:1(2)\n}>,
								 q<And only between close-brace and first item>;
		is $q.dump( {1=>2,3=>4} ), qq<Hash=\{\n\t:1(2),\n\t:3(4)\n}>,
								 q<Even in the presence of multiple items.>;
  }, 'ending newline';

	subtest sub {
		my $q = $class.new(
			intra-group-spacing    => "\n",
			pre-item-spacing       => "\n",
			post-separator-spacing => "\n",
			post-item-spacing      => "\n",
			);
		is $q.dump( [] ),          qq<Array=\[\n]>,
								 q<Newline before close-bracket>;
		is $q.dump( [1] ),         qq<Array=\[\n\t1\n]>,
								 q<And only between close-bracket and first item>;
		is $q.dump( [1,2] ),       qq<Array=\[\n\t1,\n\t2\n]>,
								 q<Even in the presence of multiple items.>;
		is $q.dump( {} ),          qq<Hash=\{\n}>,
								 q<Newline before close-brace>;
		is $q.dump( {1=>2} ),      qq<Hash=\{\n\t:1(2)\n}>,
								 q<And only between close-brace and first item>;
		is $q.dump( {1=>2,3=>4} ), qq:to/EOF/.chomp, q<And multiple items.>;
			Hash=\{
			\t:1(2),
			\t:3(4)
			}
			EOF
	  }, 'Newlines galore';

	subtest sub {
	    my $q = $class.new(
			intra-group-spacing    => "\n",
			pre-item-spacing       => ' ',
			post-separator-spacing => "\n   ",
			post-item-spacing      => "\n ",
			);
		is $q.dump( {1=>2,3=>4} ), qq:to/EOF/.chomp, q<And multiple items.>;
			Hash=\{ \t:1(2),
			   \t:3(4)
			 }
			EOF
		}, 'Sample of better formatting';

	subtest sub {
		my $q = $class.new(
			intra-group-spacing    => "\n",
			pre-item-spacing       => ' ',
			post-separator-spacing => "\n   ",
			post-item-spacing      => "\n "
			);
		is $q.dump( {1=>2,3=>{4=>5}} ), qq:to/EOF/.chomp, q<And multiple items.>;
			Hash=\{ \t:1(2),
			   \t:3(Hash=\{ \t:4(5)
			\t })
			 }
			EOF
		}, 'Sample of better formatting';

	}, 'Alternate formatting';

done-testing();
