use v6;
use Test;
use lib <lib>;

plan 6;

use-ok 'HTML::Tag::Tags', 'HTML::Tag::Tags can be use-d';
use HTML::Tag::Tags;
use-ok 'HTML::Tag::Macro::Table', 'HTML::Tag::Macro::Table can be use-d';
use HTML::Tag::Macro::Table;


# Table Macro
my $table = HTML::Tag::Macro::Table.new;
my @data = 'Col1', 'Col2', 'Col3';
$table.row(:header, @data);
@data = 11, 22, 33;
$table.row(@data);
is $table.render, '<table><tr><th>Col1</th><th>Col2</th><th>Col3</th></tr><tr><td>11</td><td>22</td><td>33</td></tr></table>', 'HTML::Tag::Macro::Table works';

# Table Macro using rows()
$table = HTML::Tag::Macro::Table.new;
@data = 'Col1', 'Col2', 'Col3';
$table.row(:header, @data);
@data = ((11, 22, 33), (44, 55, 66));
$table.rows(@data);
is $table.render, '<table><tr><th>Col1</th><th>Col2</th><th>Col3</th></tr><tr><td>11</td><td>22</td><td>33</td></tr><tr><td>44</td><td>55</td><td>66</td></tr></table>', 'HTML::Tag::Macro::Table works with rows()';

# Table Macro with td options
$table = HTML::Tag::Macro::Table.new;
@data = 'Col1', 'Col2', 'Col3';
$table.row(:header(True), @data);
@data = 11, 22, 33;
$table.row(@data);
@data = 111, 222, 333;
my $td-opts = %(1 => {class => 'pretty'},
		2 => {class => 'pretty',
		      id    => 'lastone'});
$table.row(:td-opts($td-opts), @data);
is $table.render, '<table><tr><th>Col1</th><th>Col2</th><th>Col3</th></tr><tr><td>11</td><td>22</td><td>33</td></tr><tr><td>111</td><td class="pretty">222</td><td id="lastone" class="pretty">333</td></tr></table>', 'HTML::Tag::Macro::Table works with td-opts';

$table = HTML::Tag::Macro::Table.new(:table-opts(id => 'mytable'));
@data = 'Col1', 'Col2', 'Col3';
$table.row(:header(True), @data);
@data = 11, 22, 33;
my $tr-opts = %(class => 'pretty');
$table.row(:tr-opts($tr-opts), @data);
@data = 111, 222, 333;
$table.row(@data);
is $table.render, '<table id="mytable"><tr><th>Col1</th><th>Col2</th><th>Col3</th></tr><tr class="pretty"><td>11</td><td>22</td><td>33</td></tr><tr><td>111</td><td>222</td><td>333</td></tr></table>', 'HTML::Tag::Macro::Table works with tr-opts';
