use v6;
use Test; 
use lib <lib>;

plan 16;

use-ok 'HTML::Tag::Tags', 'HTML::Tag::Tags can be use-d';
use HTML::Tag::Tags;
use-ok 'HTML::Tag::Macro::List', 'HTML::Tag::Macro::List can be use-d';
use HTML::Tag::Macro::List;

my @items = 'Red shirt', 'Harmonica', 'Traverse';

# Unordered list
is HTML::Tag::Macro::List.new(:items(@items)).render, '<ul><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ul>', 'Unordered list works fine';

# Ordered list
is HTML::Tag::Macro::List.new(:ordered, :items(@items)).render, '<ol><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ol>', 'Ordered list works fine';

# Adding items individually
ok my $list = HTML::Tag::Macro::List.new, 'Class instantiated to variable';
ok $list.item('Red shirt'), 'Can add first list item';
ok $list.item('Harmonica'), 'Can add second list item';
ok $list.item('Traverse'), 'Can add third list item';
is $list.render, '<ul><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ul>', 'Adding individual items to list works fine';

# Ordered list with list type
is HTML::Tag::Macro::List.new(:ordered, :type('i'), :items(@items)).render, '<ol type="i"><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ol>', 'Ordered list works fine with type';

# Unordered list with class
is HTML::Tag::Macro::List.new(:class('test'), :items(@items)).render, '<ul class="test"><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ul>', 'Unordered list works fine with class';

# Unordered list with id
is HTML::Tag::Macro::List.new(:id('test'), :items(@items)).render, '<ul id="test"><li>Red shirt</li><li>Harmonica</li><li>Traverse</li></ul>', 'Unordered list works fine with id';

# Adding anchors individually
$list = HTML::Tag::Macro::List.new;
ok $list.link(to   => 'http://localhost/redshirt',
	      text => 'Red shirt'), 'Can add first list link';
ok $list.link(to   => 'http://localhost/harmonica',
	      text => 'Harmonica'), 'Can add second list link';
ok $list.link(to   => 'http://localhost/traverse',
	      text => 'Traverse'), 'Can add third list link';
is $list.render, '<ul><li><a href="http://localhost/redshirt">Red shirt</a></li><li><a href="http://localhost/harmonica">Harmonica</a></li><li><a href="http://localhost/traverse">Traverse</a></li></ul>', 'Generating a list of links works';
