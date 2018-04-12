use v6;
use Pod::To::Tree;
use Pod::To::HTMLBody;
use Test;

subtest 'tree manipulation', {
	my $item = Node::Item.new;

	my $new-list = Node::List.new;
	$new-list.add-below( $item );

	subtest 'links from new-list', {
		nok $new-list.parent;
		nok $new-list.previous-sibling;
		nok $new-list.next-sibling;
		is $new-list.first-child, $item;
	};

	subtest 'links from item', {
		is $item.parent, $new-list;
		nok $item.previous-sibling;
		nok $item.next-sibling;
		nok $item.first-child;
	};

	my $new-item = Node::Item.new;
	$item.replace-with( $new-item );

	subtest 'new-list after replacing item', {
		nok $new-list.parent;
		nok $new-list.previous-sibling;
		nok $new-list.next-sibling;
		is $new-list.first-child, $new-item;

	};

	subtest 'new-item after being emplaced', {
		is $new-item.parent, $new-list;
		nok $new-item.previous-sibling;
		nok $new-item.next-sibling;
		nok $new-item.first-child;
	};

	my $item2 = Node::Item.new;
	$new-list.add-below( $item2 );

	subtest 'new-list after adding $item2', {
		nok $new-list.parent;
		nok $new-list.previous-sibling;
		nok $new-list.next-sibling;
		is $new-list.first-child, $new-item;
	};

	# Root <-
	#  | |   \
	#  V V   /
	# List -  <-
	#  | |      \
	#  V V      /
	# Item
	#  | |
	#  V V
	#  X X

	my $the-root = Node::Document.new;
	my $the-item = Node::Item.new;
	my $the-list = Node::List.new;
	$the-root.add-below( $the-list );
	$the-list.add-below( $the-item );

	subtest 'root', {
		nok $the-root.parent;
		nok $the-root.previous-sibling;
		nok $the-root.next-sibling;
		is $the-root.first-child, $the-list;
	};
	subtest 'list', {
		is $the-list.parent, $the-root;
		nok $the-list.previous-sibling;
		nok $the-list.next-sibling;
		is $the-list.first-child, $the-item;
	};
	subtest 'item', {
		is $the-item.parent, $the-list;
		nok $the-item.previous-sibling;
		nok $the-item.next-sibling;
		nok $the-item.first-child;
	};
};

my $pod-counter = 0;
my $root;
my $r;

subtest 'paragraphs', {

=begin pod
Lorem ipsum
=end pod

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<div>'
			'<p>' 'Lorem ipsum' '</p>'
		'</div>'
	/, 'simple paragraph';

=begin pod

someone accidentally left a space
 
between these two paragraphs

=end pod

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<p>' 'someone accidentally left a space' '</p>'
		'<p>' 'between these two paragraphs' '</p>'
	/, 'paragraph break';

=for foo
some text

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'some text' '</p>'
		'</section>'
	/, 'paragraph with body';

=for foo
some
spaced   text

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'some spaced text' '</p>'
		'</section>'
	/, 'spacing';
};

subtest 'section', {
=begin foo
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
		'</section>'
	/, 'section';

=begin foo
Some content
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'Some content' '</p>'
		'</section>'
	/, 'section wih content';

=begin foo
Some content
over two lines
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'Some content over two lines' '</p>'
		'</section>'
	/, 'section wih content over two lines';

=begin foo
paragraph one

paragraph
two
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'paragraph one' '</p>'
			'<p>' 'paragraph two' '</p>'
		'</section>'
	/, 'two paragraphs';

=begin something
    =begin somethingelse
    toot tooot!
    =end somethingelse
=end something

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
		'<section>'
			'<h1>' 'something' '</h1>'
			'<section>'
				'<h1>' 'somethingelse' '</h1>'
				'<p>' 'toot tooot!' '</p>'
			'</section>'
		'</section>'
	/, 'nested section';

=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =begin bar
    Dragon Tears!
    =end bar

Which, as we all know...

    =begin bar
    Turn into Jelly Beans!
    =end bar
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'and so, all of the villages chased Albi, The Racist Dragon, into the very cold and very scary cave' '</p>'
			'<p>' 'and it was so cold and so scary in there, that Albi began to cry' '</p>'
			'<section>'
				'<h1>' 'bar' '</h1>'
				'<p>' 'Dragon Tears!' '</p>'
			'</section>'
			'<p>' 'Which, as we all know...' '</p>'
			'<section>'
				'<h1>' 'bar' '</h1>'
				'<p>' 'Turn into Jelly Beans!' '</p>'
			'</section>'
		'</section>'
	/, 'Mixed sections and paragraphs';

=begin something
    =begin somethingelse
    toot tooot!
    =end somethingelse
=end something

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'something' '</h1>'
			'<section>'
				'<h1>' 'somethingelse' '</h1>'
				'<p>' 'toot tooot!' '</p>'
			'</section>'
		'</section>'
	/, 'regression test';

=begin kwid

= DESCRIPTION
bla bla

foo
=end kwid

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'kwid' '</h1>'
			'<p>' '= DESCRIPTION bla bla' '</p>'
			'<p>' 'foo' '</p>'
		'</section>'
	/, 'broken meta tag';

=begin more-discussion-needed

XXX: chop(@array) should return an array of chopped strings?
XXX: chop(%has)   should return a  hash  of chopped strings?

=end more-discussion-needed

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'more-discussion-needed' '</h1>'
			'<p>' 'XXX: chop(@array) should return an array of chopped strings? XXX: chop(%has) should return a hash of chopped strings?' '</p>'
		'</section>'
	/, 'playing with line breaks';

=for foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
		'</section>'
	/, 'hanging section';

# tests without Albi would still be tests, but definitely very, very sad
# also, Albi without paragraph blocks wouldn't be the happiest dragon
# either
=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =for bar
    Dragon Tears!

Which, as we all know...

    =for bar
    Turn into Jelly Beans!
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'and so, all of the villages chased Albi, The Racist Dragon, into the very cold and very scary cave' '</p>'
			'<p>' 'and it was so cold and so scary in there, that Albi began to cry' '</p>'
			'<section>'
				'<h1>' 'bar' '</h1>'
				'<p>' 'Dragon Tears!' '</p>'
			'</section>'
			'<p>' 'Which, as we all know...' '</p>'
			'<section>'
				'<h1>' 'bar' '</h1>'
				'<p>' 'Turn into Jelly Beans!' '</p>'
			'</section>'
		'</section>'
	/, 'nested blocks';

=foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
		'</section>'
	/, 'hanging block';

=foo some text

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'some text' '</p>'
		'</section>'
	/, 'hanging block with paragraph';

=foo some text
and some more

# Yes, 'some text' and 'and some more' are in the same paragraph block, no
# way to know if they've been broken up.
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'some text and some more' '</p>'
		'</section>'
	/, 'hanging block with multi-line paragraph';

=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =bold Dragon Tears!

Which, as we all know...

    =bold Turn
          into
          Jelly
          Beans!
=end foo

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'foo' '</h1>'
			'<p>' 'and so, all of the villages chased Albi, The Racist Dragon, into the very cold and very scary cave' '</p>'
			'<p>' 'and it was so cold and so scary in there, that Albi began to cry' '</p>'
			'<section>'
				'<h1>' 'bold' '</h1>'
				'<p>' 'Dragon Tears!' '</p>'
			'</section>'
			'<p>' 'Which, as we all know...' '</p>'
			'<section>'
				'<h1>' 'bold' '</h1>'
				'<p>' 'Turn into Jelly Beans!' '</p>'
			'</section>'
		'</section>'
	/, 'nested paragraphs';

=table_not
    Constants 1
    Variables 10
    Subroutines 33
    Everything else 57

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<section>'
			'<h1>' 'table_not' '</h1>'
			'<p>' 'Constants 1 Variables 10 Subroutines 33 Everything else 57' '</p>'
		'</section>'
	/, 'S26 counterexample - not a table';
};

subtest 'table', {
#`(
=table
+-----+----+---+
|   a | b  | c |
+-----+----+---+
| foo | 52 | Y |
| bar | 17 | N |
|  dz | 9  | Y |
+-----+----+---+

	# Check out the raw pod if you don't believe me, this is a set of single
	# rows.
	#
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
			'<tr>' '<td>' '| a | b | c |'    '</td>' '</tr>'
			'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
			'<tr>' '<td>' '| foo | 52 | Y |' '</td>' '</tr>'
			'<tr>' '<td>' '| bar | 17 | N |' '</td>' '</tr>'
			'<tr>' '<td>' '| dz | 9 | Y |'   '</td>' '</tr>'
			'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
		'</table>'
	/, 'RT #124403 - incorrect table parse';
)

#`(
=begin table
a | b | c
l | m | n
x | y
=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'a' '</td>'
				'<td>' 'b' '</td>'
				'<td>' 'c' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'l' '</td>'
				'<td>' 'm' '</td>'
				'<td>' 'n' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'x' '</td>'
				'<td>' 'y' '</td>'
			'</tr>'
		'</table>'
	/, 'RT #129862 short row';
)

#`(
=table
    X   O
   ===========
        X   O
   ===========
            X

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'X' '</td>'
				'<td>' 'O' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '</td>'
				'<td>' 'X' '</td>'
				'<td>' 'O' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '</td>'
				'<td>' '</td>'
				'<td>' 'X' '</td>'
			'</tr>'
		'</table>'
	/, 'RT #132341 rows, also #129862';
)

#`(
# XXX The 'Z<..>' aren't being parsed by Perl...
# also tests fix for RT #129862
=begin table
a | b | c
l | m | n
x | y      Z<a comment> Z<another comment>
=end table

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<table>'
		'<tr>'
			'<td>' 'a' '</td>'
			'<td>' 'b' '</td>'
			'<td>' 'c' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'l' '</td>'
			'<td>' 'm' '</td>'
			'<td>' 'n' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'x' '</td>'
			'<td>' 'y Z<a comment> Z<another comment>' '</td>'
		'</tr>'
	'</table>'
/, 'RT #132348 allow inline Z<> comments';
)

=begin table
a
=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'a' '</td>'
			'</tr>'
		'</table>'
	/, 'single-column table';

=begin table
b
-
a
=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'b' '</td>'
			'</th>'
			'<tr>'
				'<td>' 'a' '</td>'
			'</tr>'
		'</table>'
	/, 'single-column table with header';

#`(
# need to handle table cells with char column separators as data
# example table from <https://docs.perl6.org/language/regexes>
# WITHOUT the escaped characters (results in an extra, unwanted, incorrect column)
=begin table

    Operator  |  Meaning
    ==========+=========
     +        |  set union
     |        |  set union
     &        |  set intersection
     -        |  set difference (first minus second)
     ^        |  symmetric set intersection / XOR

=end table

	# XXX '&' needs to be escaped, among others probably.
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Operator' '</td>'
				'<td>' 'Meaning' '</td>'
			'</th>'
			'<tr>'
				'<td>' '+' '</td>'
				'<td>' 'set union' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '</td>'
				'<td>' '</td>'
				'<td>' 'set union' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '&' '</td>'
				'<td>' 'set intersection' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '-' '</td>'
				'<td>' 'set difference (first minus second)' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '^' '</td>'
				'<td>' 'symmetric set intersection / XOR' '</td>'
			'</tr>'
		'</table>'
	/, '#1282 header, entities and gaps';
)

#`(
# WITHOUT the escaped characters and without the non-breaking spaces
# (results in the desired table)
=begin table

    Operator  |  Meaning
    ==========+=========
    +       |  set union
    |       |  set union
    &       |  set intersection
    -       |  set difference (first minus second)
    ^       |  symmetric set intersection / XOR

=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Operator' '</td>'
				'<td>' 'Meaning' '</td>'
			'</th>'
			'<tr>'
				'<td>' '+ &' '</td>'
				'<td>' 'set union set intersection' '</td>'
				'<td>' 'set union' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '^' '</td>'
				'<td>' 'symmetric set intersection / XOR' '</td>'
			'</tr>'
		'</table>'
	/, 'escaped characters';
)

#`(
# WITH the escaped characters (results in the desired table)
=begin table

    Operator  |  Meaning
    ==========+=========
     \+        |  set union
     \|        |  set union
     &        |  set intersection
     -        |  set difference (first minus second)
     ^        |  symmetric set intersection / XOR

=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Operator' '</td>'
				'<td>' 'Meaning' '</td>'
			'</th>'
			'<tr>'
				'<td>' '\\+' '</td>'
				'<td>' 'set union' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '\\|' '</td>'
				'<td>' 'set union' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '&' '</td>'
				'<td>' 'set intersection' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '-' '</td>'
				'<td>' 'set difference (first minus second)' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '^' '</td>'
				'<td>' 'symmetric set intersection / XOR' '</td>'
			'</tr>'
		'</table>'
	/, 'escaped, and some non-breaking spaces';
)

#`(
# WITH the escaped characters but without the non-breaking spaces
# (results in the desired table)

=begin table

    Operator  |  Meaning
    ==========+=========
    \+       |  set union
    \|       |  set union
    &       |  set intersection
    -       |  set difference (first minus second)
    ^       |  symmetric set intersection / XOR

=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Operator' '</td>'
				'<td>' 'Meaning' '</td>'
			'</th>'
			'<tr>'
				'<td>' '\\+ \\| &' '</td>'
				'<td>' 'set union set union set intersection' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '^' '</td>'
				'<td>' 'symmetric set intersection / XOR' '</td>'
			'</tr>'
		'</table>'
	/, 'escaped, no non-breaking spaces';
)

=begin table
        The Shoveller   Eddie Stevens     King Arthur's singing shovel
        Blue Raja       Geoffrey Smith    Master of cutlery
        Mr Furious      Roy Orson         Ticking time bomb of fury
        The Bowler      Carol Pinnsler    Haunted bowling ball
=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'The Shoveller' '</td>'
				'<td>' 'Eddie Stevens' '</td>'
				'<td>' 'King Arthur\'s singing shovel' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Blue Raja' '</td>'
				'<td>' 'Geoffrey Smith' '</td>'
				'<td>' 'Master of cutlery' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Mr Furious' '</td>'
				'<td>' 'Roy Orson' '</td>'
				'<td>' 'Ticking time bomb of fury' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'The Bowler' '</td>'
				'<td>' 'Carol Pinnsler' '</td>'
				'<td>' 'Haunted bowling ball' '</td>'
			'</tr>'
		'</table>'
	/, 'simple table';

=table
    Constants           1
    Variables           10
    Subroutines         33
    Everything else     57

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<table>'
		'<tr>'
			'<td>' 'Constants' '</td>'
			'<td>' '1' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'Variables' '</td>'
			'<td>' '10' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'Subroutines' '</td>'
			'<td>' '33' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'Everything else' '</td>'
			'<td>' '57' '</td>'
		'</tr>'
	'</table>'
/, 'simple two-column table';

=for table
    mouse    | mice
    horse    | horses
    elephant | elephants

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'mouse' '</td>'
				'<td>' 'mice' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'horse' '</td>'
				'<td>' 'horses' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'elephant' '</td>'
				'<td>' 'elephants' '</td>'
			'</tr>'
		'</table>'
	/, 'two-column table, no header';

=table
    Animal | Legs |    Eats
    =======================
    Zebra  +   4  + Cookies
    Human  +   2  +   Pizza
    Shark  +   0  +    Fish

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Animal' '</td>'
				'<td>' 'Legs' '</td>'
				'<td>' 'Eats' '</td>'
			'</th>'
			'<tr>'
				'<td>' 'Zebra' '</td>'
				'<td>' '4' '</td>'
				'<td>' 'Cookies' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Human' '</td>'
				'<td>' '2' '</td>'
				'<td>' 'Pizza' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Shark' '</td>'
				'<td>' '0' '</td>'
				'<td>' 'Fish' '</td>'
			'</tr>'
		'</table>'
	/, 'hanging table';

=table
        Superhero     | Secret          |
                      | Identity        | Superpower
        ==============|=================|================================
        The Shoveller | Eddie Stevens   | King Arthur's singing shovel

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Superhero' '</td>'
				'<td>' 'Secret Identity' '</td>'
				'<td>' 'Superpower' '</td>'
			'</th>'
			'<tr>'
				'<td>' 'The Shoveller' '</td>'
				'<td>' 'Eddie Stevens' '</td>'
				'<td>' "King Arthur's singing shovel" '</td>'
			'</tr>'
		'</table>'
	/, 'hanging table with multiline header';

=begin table

                        Secret
        Superhero       Identity          Superpower
        =============   ===============   ===================
        The Shoveller   Eddie Stevens     King Arthur's
                                          singing shovel

        Blue Raja       Geoffrey Smith    Master of cutlery

        Mr Furious      Roy Orson         Ticking time bomb
                                          of fury

        The Bowler      Carol Pinnsler    Haunted bowling ball

=end table

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<th>'
				'<td>' 'Superhero' '</td>'
				'<td>' 'Secret Identity' '</td>'
				'<td>' 'Superpower' '</td>'
			'</th>'
			'<tr>'
				'<td>' 'The Shoveller' '</td>'
				'<td>' 'Eddie Stevens' '</td>'
				'<td>' "King Arthur's singing shovel" '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Blue Raja' '</td>'
				'<td>' 'Geoffrey Smith' '</td>'
				'<td>' 'Master of cutlery' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Mr Furious' '</td>'
				'<td>' 'Roy Orson' '</td>'
				'<td>' 'Ticking time bomb of fury' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'The Bowler' '</td>'
				'<td>' 'Carol Pinnsler' '</td>'
				'<td>' 'Haunted bowling ball' '</td>'
			'</tr>'
		'</table>'
	/, 'table with == separators';

=table
    X | O |
   ---+---+---
      | X | O
   ---+---+---
      |   | X

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'X' '</td>'
				'<td>' 'O' '</td>'
				'<td>' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '</td>'
				'<td>' 'X' '</td>'
				'<td>' 'O' '</td>'
			'</tr>'
			'<tr>'
				'<td>' '</td>'
				'<td>' '</td>'
				'<td>' 'X' '</td>'
			'</tr>'
		'</table>'
	/, 'tic-tac-toe with empty squares';

# test for:
#   RT #126740 - Pod::Block::Table node caption property is not populated properly
# Note that the caption property is just one of the table's %config key/value
# pairs so any tests for other config keys in a single table are usually the same as testing
# multiple tables, each for one caption test.
=begin table :caption<foo> :bar(0)

foo
bar

=end table

	$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
	isa-ok $root, Node::Table;
	is $root.config.<bar>, 0;
	# XXX This is wrong. There's a .caption available, it should be used.
	is $root.config.<caption>, 'foo';
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<table>'
			'<tr>'
				'<td>' 'foo' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'bar' '</td>'
			'</tr>'
		'</table>'
	/, 'RT #126740 caption propery';
};

subtest 'item', {
=item foo

	# Isn't part of the Roast suite, but I need it to check some edge cases.
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<li>' 'foo' '</li>'
	/, 'standalone item';

=begin pod
=item foo
=item bar
=end pod

	# Isn't part of the Roast suite, but I need it to check some edge cases.
	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<div>'
			'<li>' 'foo' '</li>'
			'<li>' 'bar' '</li>'
		'</div>'
	/, 'items';

=begin pod
The seven suspects are:

=item  Happy
=item  Dopey
=item  Sleepy
=item  Bashful
=item  Sneezy
=item  Grumpy
=item  Keyser Soze
=end pod

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<div>'
			'<p>' 'The seven suspects are:' '</p>'
			'<li>' 'Happy' '</li>'
			'<li>' 'Dopey' '</li>'
			'<li>' 'Sleepy' '</li>'
			'<li>' 'Bashful' '</li>'
			'<li>' 'Sneezy' '</li>'
			'<li>' 'Grumpy' '</li>'
			'<li>' 'Keyser Soze' '</li>'
		'</div>'
	/, 'one-level list';

#`(
=begin pod
=item1  Animal
=item2     Vertebrate
=item2     Invertebrate

=item1  Phase
=item2     Solid
=item2     Liquid
=item2     Gas
=item2     Chocolate
=end pod

	like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
		'<li>' 'Animal' '</li>'
		'<ul>'
			'<li>' 'Vertebrate' '</li>'
			'<li>' 'Invertebrate' '</li>'
		'</ul>'
		'<li>' 'Phase' '</li>'
		'<ul>'
			'<li>' 'Solid' '</li>'
			'<li>' 'Liquid' '</li>'
			'<li>' 'Gas' '</li>'
			'<li>' 'Chocolate' '</li>'
		'</ul>'
	/, 'nested lists';
)

#`(
=begin pod
=comment CORRECT...
=begin item1
The choices are:
=end item1
=item2 Liberty
=item2 Death
=item2 Beer
=item2 Cake
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
1
/;
)
};

=begin pod
sample paragraph
=begin table

                        Secret
        Superhero       Identity          Superpower
        =============   ===============   ===================
        The Shoveller   Eddie Stevens     King Arthur's
                                          singing shovel

        Blue Raja       Geoffrey Smith    Master of cutlery

        Mr Furious      Roy Orson         Ticking time bomb
                                          of fury

        The Bowler      Carol Pinnsler    Haunted bowling ball

=end table

=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>' 'sample paragraph' '</p>'
		'<table>'
			'<th>'
				'<td>' 'Superhero' '</td>'
				'<td>' 'Secret Identity' '</td>'
				'<td>' 'Superpower' '</td>'
			'</th>'
			'<tr>'
				'<td>' 'The Shoveller' '</td>'
				'<td>' 'Eddie Stevens' '</td>'
				'<td>' "King Arthur's singing shovel" '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Blue Raja' '</td>'
				'<td>' 'Geoffrey Smith' '</td>'
				'<td>' 'Master of cutlery' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'Mr Furious' '</td>'
				'<td>' 'Roy Orson' '</td>'
				'<td>' 'Ticking time bomb of fury' '</td>'
			'</tr>'
			'<tr>'
				'<td>' 'The Bowler' '</td>'
				'<td>' 'Carol Pinnsler' '</td>'
				'<td>' 'Haunted bowling ball' '</td>'
			'</tr>'
		'</table>'
	'</div>'
/, 'paragraph and complex table';

# various things which caused the spectest to fail at some point


=begin pod
    =head1 This is a heading block

    This is an ordinary paragraph.
    Its text  will   be     squeezed     and
    short lines filled. It is terminated by
    the first blank line.

    This is another ordinary paragraph.
    Its     text    will  also be squeezed and
    short lines filled. It is terminated by
    the trailing directive on the next line.
        =head2 This is another heading block

        This is yet another ordinary paragraph,
        at the first virtual column set by the
        previous directive
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<h1>'
			'<p>' 'This is a heading block' '</p>'
		'</h1>'
		'<p>' 'This is an ordinary paragraph. Its text will be squeezed and short lines filled. It is terminated by the first blank line.' '</p>'
		'<p>' 'This is another ordinary paragraph. Its text will also be squeezed and short lines filled. It is terminated by the trailing directive on the next line.' '</p>'
		'<h2>'
			'<p>' 'This is another heading block' '</p>'
		'</h2>'
		'<p>' 'This is yet another ordinary paragraph, at the first virtual column set by the previous directive' '</p>'
	'</div>'
/, 'headings with indentations';

=begin pod

=for got
Inside got

    =for bidden
    Inside bidden

Outside blocks
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<section>'
			'<h1>' 'got' '</h1>'
			'<p>' 'Inside got' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'bidden' '</h1>'
			'<p>' 'Inside bidden' '</p>'
		'</section>'
		'<p>' 'Outside blocks' '</p>'
	'</div>'
/, 'nested blocks';

# mixed blocks
=begin pod
=begin one
one, delimited block
=end one
=for two
two, paragraph block
=for three
three, still a parablock

=begin four
four, another delimited one
=end four
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<section>'
			'<h1>' 'one' '</h1>'
			'<p>' 'one, delimited block' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'two' '</h1>'
			'<p>' 'two, paragraph block' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'three' '</h1>'
			'<p>' 'three, still a parablock' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'four' '</h1>'
			'<p>' 'four, another delimited one' '</p>'
		'</section>'
	'</div>'
/, 'multiple blocks';

# Without the =begin..=end directives here, each =for is its own directive.
# It might not quite be in the spirit of the test, XXX
#
=begin pod
=for pod
=for nested
=for para :nested(1)
E<a;b>E<a;b;c>
♥♥♥
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<div>' '</div>'
		'<section>'
			'<h1>' 'nested' '</h1>'
		'</section>'
		'<section>'
			'<h1>' 'para' '</h1>'
			'<p>' 'a ba b c ♥♥♥' '</p>'
		'</section>'
	'</div>'
/, 'RT #131400';

=begin pod

=got Inside
got

=bidden Inside
bidden

Outside blocks
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<section>'
			'<h1>' 'got' '</h1>'
			'<p>' 'Inside got' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'bidden' '</h1>'
			'<p>' 'Inside bidden' '</p>'
		'</section>'
		'<p>' 'Outside blocks' '</p>'
	'</div>'
/, 'multiple blocks';

# mixed blocks
=begin pod
    =begin one
    one, delimited block
    =end one
    =two two,
    paragraph block
    =for three
    three, still a parablock

    =begin four
    four, another delimited one
    =end four
    =head1 And just for the sake of having a working =head1 :)
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<section>'
			'<h1>' 'one' '</h1>'
			'<p>' 'one, delimited block' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'two' '</h1>'
			'<p>' 'two, paragraph block' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'three' '</h1>'
			'<p>' 'three, still a parablock' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'four' '</h1>'
			'<p>' 'four, another delimited one' '</p>'
		'</section>'
		'<h1>'
			'<p>' 'And just for the sake of having a working =head1 :)' '</p>'
		'</h1>'
	'</div>'
/, 'mixed contents';

=head3
Heading level 3

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<h3>'
		'<p>' 'Heading level 3' '</p>'
	 '</h3>'
/, 'heading';

=begin pod
This ordinary paragraph introduces a code block:

    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);

    $which.spans(:newlines);

=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<p>' 'This ordinary paragraph introduces a code block:' '</p>'
	'<code>' "\$this = 1 * code('block');
\$which.is_specified(:by<indenting>);

\$which.spans(:newlines);" '</code>'
/, 'indented code';

# more fancy code blocks
=begin pod
This is an ordinary paragraph

    While this is not
    This is a code block

    =head1 Mumble mumble

    Suprisingly, this is not a code block
        (with fancy indentation too)

But this is just a text. Again

=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'<div>'
		'<p>' 'This is an ordinary paragraph' '</p>'
		'<code>' 'While' .+ 'block' '</code>' # XXX look into this
		'<h1>'
			'<p>' 'Mumble mumble' '</p>'
		'</h1>'
		'<p>' 'Suprisingly, this is not a code block (with fancy indentation too)' '</p>'
		'<p>' 'But this is just a text. Again' '</p>'
	'</div>'
/, 'mixed block types';

=begin pod

Tests for the feed operators

    ==> and <==
    
=end pod

# XXX Check to see if entities need to be decoded here.
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<p>' 'Tests for the feed operators' '</p>'
	'<code>' '==> and <==' '</code>'
/, 'entities';

=begin pod
Fun comes

    This is code
  Ha, what now?

 one more block of code
 just to make sure it works
  or better: maybe it'll break!
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<p>' 'Fun comes' '</p>'
	'<code>' 'This is code' '</code>'
	'<code>' 'Ha, what now?' '</code>'
	'<code>' 'one more block of code
just to make sure it works
 or better: maybe it\'ll break!' '</code>'
/, 'multi-line code block';

=begin pod

=head1 A heading

This is Pod too. Specifically, this is a simple C<para> block

    $this = pod('also');  # Specifically, a code block

=end pod

# XXX The code with '$this...' needs to be fixed.
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<h1>'
			'<p>' 'A heading' '</p>'
		'</h1>'
		'<p>' 'This is Pod too. Specifically, this is a simple '
			'<code>' 'para' '</code>'
#			' block'
#		'</p>'
#		'<code>'
#			'\$this = pod(\'also\');  # Specifically, a code block'
#		'</code>'
#	'</div>'
/, 'complex code block';

=begin pod
    this is code

    =for podcast
        this is not

    this is not code either

    =begin itemization
        this is not
    =end itemization

    =begin quitem
        and this is not
    =end quitem

    =begin item
        and this is!
    =end item
=end pod

# Note that <li> <code/> </li> is intentional here because of the indent.
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<code>' 'this is code' '</code>'
		'<section>'
			'<h1>' 'podcast' '</h1>'
			'<p>' 'this is not' '</p>'
		'</section>'
		'<p>' 'this is not code either' '</p>'
		'<section>'
			'<h1>' 'itemization' '</h1>'
			'<p>' 'this is not' '</p>'
		'</section>'
		'<section>'
			'<h1>' 'quitem' '</h1>'
			'<p>' 'and this is not' '</p>'
		'</section>'
		'<li>' '<code>' 'and this is!' '</code>' '</li>'
	'</div>'
/, 'mixed code and one hidden in an item';

=begin code
    foo foo
    =begin code
    =end code
=end code

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'<code>'
		'foo foo
    =begin code
    =end code'
	'</code>'
/, 'embedded pseudo-pod';

=begin pod
=for comment
foo foo
bla bla    bla

This isn't a comment
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'<div>'
		'<!--' 'foo foo' 'bla bla    bla' '-->'
		'<p>' 'This isn\'t a comment' '</p>'
	'</div>'
/, 'paragraph comment';

=comment
This file is deliberately specified in Perl 6 Pod format

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'<!--'
		'This file is deliberately specified in Perl 6 Pod format'
	'-->'
/, 'S26 counterexample - hanging comment';

# this happens to break hilighting in some editors,
# so I put it at the end
=begin comment
foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!
=end comment

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'<!--'
		'foo foo'
		'=begin invalid pod'
		'=as many invalid pod as we want'
		'===yay!'
	'-->'
/, 'delimited comment';

# XXX Those items are :numbered in S26, but we're waiting with block
# configuration until we're inside Rakudo, otherwise we'll have to
# pretty much implement Pair parsing in gsocmess only to get rid of
# it later.

=begin pod
Let's consider two common proverbs:

=begin item
I<The rain in Spain falls mainly on the plain.>

This is a common myth and an unconscionable slur on the Spanish
people, the majority of whom are extremely attractive.
=end item

=begin item
I<The early bird gets the worm.>

In deciding whether to become an early riser, it is worth
considering whether you would actually enjoy annelids
for breakfast.
=end item

As you can see, folk wisdom is often of dubious value.
=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>' "Let's consider two common proverbs:" '</p>'
		'<li>'
			'<i>' 'The rain in Spain falls mainly on the plain.' '</i>'
			'This is a common myth and an unconscionable slur on the Spanish people, the majority of whom are extremely attractive.'
		'</li>'
		'<li>'
			'<i>' 'The early bird gets the worm.' '</i>'
			'In deciding whether to become an early riser, it is worth considering whether you would actually enjoy annelids for breakfast.'
		'</li>'
		'<p>' 'As you can see, folk wisdom is often of dubious value.' '</p>'
	'</div>'
/, 'compound mixed content';

# includes tests for fixes for RT bugs:
#   124403 - incorrect table parse:
#   129862 - uneven rows
#   132341 - pad rows to add empty cells to ensure all rows have same number of cells

=pod
B<I am a formatting code>

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<b>' 'I am a formatting code' '</b>'
/, 'inline bold';

=pod
I<Render unto Caesar in italic>

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<i>' 'Render unto Caesar in italic' '</i>'
/, 'inline italic';

=pod
U<Ignore this!>

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<u>' 'Ignore this!' '</u>'
/, 'inline underline';

=pod
The basic C<ln> command is: C<ln> B<R<source_file> R<target_file>>

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /:s
	'The basic'
	'<code>' 'ln' '</code>'
	'command is:'
	'<code>' 'ln' '</code>'
	'<b>'
		'<var>' 'source_file' '</var>'
		'<var>' 'target_file' '</var>'
	'</b>'
/, 'inline code and references';

=pod
L<C<b>|a>
L<C<b>|a>

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>'
			'<a href="a">' '<code>' 'b' '</code>' '</a>'
			' '
			'<a href="a">' '<code>' 'b' '</code>' '</a>'
		'</p>'
	'</div>'
/, 'links';

=begin pod

=head1 A heading

This is Pod too. Specifically, this is a simple C<para> block

    $this = pod('also');  # Specifically, a code block

=end pod

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<h1>'
			'<p>' 'A heading' '</p>'
		'</h1>'
		'<p>'
			'This is Pod too. Specifically, this is a simple '
			'<code>' 'para' '</code>'
			' block'
		'</p>'
		'<code>'
			'$this = pod(\'also\');  # Specifically, a code block'
		'</code>'
	'</div>'
/, 'mixture';

=pod V<C<boo> B<bar> asd>

# Note that V<> doesn't generate its own POD node.
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>' 'C<boo> B<bar> asd' '</p>'
	'</div>'
/, 'invisible verbatim';

=pod C< infix:<+> >
=pod C<< infix:<+> >>

# XXX Needs to be translated.
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>'
			'<code>' 'infix:<+> ' '</code>'
		'</p>'
	'</div>'
/, 'inline <>';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<p>'
			'<code>' 'infix:<+> ' '</code>'
		'</p>'
	'</div>'
/, 'RT #114510 inline <<>>';

=begin pod
    =begin code :allow<B>
    =end code
=end pod

$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
isa-ok $root, 'Node::Document';
isa-ok $root.first-child, 'Node::Code';
is $root.first-child.config.<allow>, 'B';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<code>' '</code>'
	'</div>'
/, 'code with configuration';

=begin pod
    =config head2  :like<head1> :formatted<I>
=end pod

$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
isa-ok $root.first-child, 'Node::Config';
is $root.first-child.type, 'head2';
todo 'need to test config properly', 2;
is $root.first-child.config[0],<formatted>, 'I';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
	'</div>'
/, 'bare config node';

=begin pod
    =for pod :number(42) :zebras :!sheep :feist<1 2 3 4>
=end pod

$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
todo 'need to test config properly', 2;
is $root.first-child.config[0],<formatted>, 'I';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
	'<div>'
	'</div>'
	'</div>'
/, 'RT #127005';

=begin pod
=for DESCRIPTION :title<presentation template>
=                :author<John Brown> :pubdate(2011)
=end pod

$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
todo 'need to test config properly', 1;
is $root.first-child.config[0],<formatted>, 'I';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<section>'
			'<h1>' 'DESCRIPTION' '</h1>'
		'</section>'
	'</div>'
/, 'RT #127005';

=begin pod
=for table :caption<Table of contents>
    foo bar
=end pod

$root = Pod::To::Tree.to-tree( $=pod[$pod-counter] );
todo 'need to test config properly', 1;
is $root.first-child.config[0],<formatted>, 'I';
like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<table>'
			'<tr>'
				'<td>' 'foo bar' '</td>'
			'</tr>'
		'</table>'
	'</div>'
/, 'captioned table';

=begin pod
    =begin code :allow<B>
    These words have some B<importance>.
    =end code
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
#die $r;

like Pod::To::HTMLBody.render( $=pod[$pod-counter++] ), /
	'<div>'
		'<code>'
			'These words have some '
			'<b>' 'importance' '</b>'
			'.' "\n"
		'</code>'
	'</div>'
/, 'Adjective';

done-testing;

# vim: ft=perl6
