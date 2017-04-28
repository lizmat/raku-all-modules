use v6;

use Path::Map;

use Test;

plan 29;

my $mapper = Path::Map.new('a/b/c' => 'ABC',
			   '/date/:year/:month/:day' => 'Date',
			  );

ok ($mapper ~~ Path::Map), 'Path::Map.new';

$mapper.add_handler('/date/:year/:day/:month/US', 'Date');

# lots of different versions of the same patter, all should match the same

my @variations =
  'date/2012/12/25',
  '/date/2012/12/25',
  '/date/2012/12/25/',
  'date/2012/12/25/',
  '//date//2012/12/25',
  '/date/2012/25/12/US',
  'date/2012/25/12/US';

for @variations -> $path {
  my $match = $mapper.lookup($path);
  ok $match, qq{lookup('$path')};
  ok $match.?handler ~~ 'Date', '.. mapped to Date';
  ok $match.?variables.<year month day> ~~ ( 2012, 12, 25 ), '.. correct variables';
}

my $match = $mapper.lookup('/a/b/c/');
ok $match.?handler ~~ 'ABC', "lookup('/a/b/c/')";
ok $match.?variables ~~ (), 'Empty variable hash when there are no variable segments';

my @misses =
  'date',
  'date/2012',
  'date/2012/12',
  'date/2012/12/25/UK';

for @misses -> $path {
  ok !defined($mapper.lookup($path)), qq{lookup('$path') does not match};
}

ok <ABC Date> ~~ $mapper.?handlers.?sort.?list, 'handlers()';
