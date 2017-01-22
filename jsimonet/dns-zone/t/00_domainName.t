use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# Domain name
my @toTestAreOk = (
	'domainname',
	'domainname.tld',
	'domainame.tld.',
	'domainname.42',
	'@',
	'domainnottoolong.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldd.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklffml.lmkjooidjjldkl.',
	'domainnottoolong.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldd.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklffml.lmkjooidjjldk',
);

my @toTestAreNOk = (
	'domain@',
	'sub@domain',
	'domaintoolong.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldd.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldlmkdjfml.lmkjdmlfjldkf.lmkjdlmfjlmd.mlkjdf.',
	'domaintoolong.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldd.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldj.lmkjdmlkfjdlkmfjldkkfjldjf.jkljdlkfjkmldfdjfjk.mljdlmkfjlkmdklfldlmkdjfml.lmkjdmlfjldkf.lmkjdlmfjlmd.mlkjdf',
	'labeltoolong.lmdjkflmdjflmjdlmfjlmkdjflmkdjlmkfjlmdjfldjabcdlkjdflmjdllkdjfff.',
	'nolabel..fr',
	#'domain_sub', # TODO: fail in RFC 1035
	'domainéç',
);

plan @toTestAreOk.elems + @toTestAreNOk;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'domainName' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'domainName' ), $t;
}

done-testing;
