use lib './t';
use Test;
use lib::testhelper;

my $locator = get-locator;
plan 2;

is ~$locator.find-file('a', 'js'), q:to/JS/.trim, 'Gets the correct content';
	console.log('hey !');
  JS

is ~$locator.find-file('multi', 'js'), q:to/JS/.trim, 'Parses filters';
  perl();
  JS
