use v6;
use Test;
use File::Spec::Case;

plan 7;

if ($*CWD.IO ~~ :w) {
	ok( ("casetol.tmp".IO.e or spurt("casetol.tmp", "temporary test file, delete after reading")),
        "created test file");
    ok "casetol.tmp".IO.e, "test file exists";
	is File::Spec::Case.tolerant("casetol.tmp"), so "CASETOL.TMP".IO.e,
		"tolerant is {so "CASETOL.TMP".IO.e} in cwd";
	ok   File::Spec::Case.insensitive === "CASETOL.TMP".IO.e, "insensitive ok";
	nok  File::Spec::Case.\ sensitive === "CASETOL.TMP".IO.e, "sensitive ok";
	unlink "casetol.tmp";
}
else { skip "tolerant/sensitive/insensitive, no write access in cwd", 6; } 

ok File::Spec::Case.always-case-tolerant("dos"), "always-case-tolerant ok";
ok File::Spec::Case.default-case-tolerant("darwin"), "default-case-tolerant ok";
