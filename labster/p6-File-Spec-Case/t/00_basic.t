use v6;
use Test;
use File::Spec::Case;

plan 5;

if ($*CWD.IO ~~ :w) {
	"casetol.tmp".IO.e or spurt "casetol.tmp", "temporary test file, delete after reading";
	is File::Spec::Case.tolerant("casetol.tmp"), so "CASETOL.TMP".IO.e,
		"tolerant is {so "CASETOL.TMP".IO.e} in cwd";
	is File::Spec::Case.insensitive, so "CASETOL.TMP".IO.e, "insensitive ok";
	isnt File::Spec::Case.sensitive, so "CASETOL.TMP".IO.e, "sensitive ok";
	unlink "casetol.tmp";
}
else { skip "tolerant/sensitive/insensitive, no write access in cwd", 3; } 

ok File::Spec::Case.always-case-tolerant("dos"), "always-case-tolerant ok";
ok File::Spec::Case.default-case-tolerant("darwin"), "default-case-tolerant ok";
