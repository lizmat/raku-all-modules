use v6;
use Test;

constant package-name = 'Chemistry::Elements';
use-ok package-name or bail-out "{package-name} did not compile";
use ::(package-name);
my $class = ::(package-name);

lives-ok { my ZInt $Z = 50 },
	"Can assign positive whole number to ZInt";
lives-ok { my ZInt $Z = "51" },
	"Can assign number as string to ZInt";

throws-like { my ZInt $Z = -2 }, X::TypeCheck::Assignment,
	"Can't assign negative number to ZInt";
throws-like { my ZInt $Z = 999 }, X::TypeCheck::Assignment,
	"Can't assign out-of-range number to ZInt";

done-testing;
