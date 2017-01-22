use Test;
plan 6;

use lib "lib";

use-ok "Test::Fuzz";

{
	use Test::Fuzz;

	my $f = sub f() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($f);

	my $g = sub g() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($g);

	my $h = sub h() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($h);

	run-tests;
}

{
	use Test::Fuzz;

	my $f = sub f2() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($f);

	my $g = sub g2() {} but role {method run-tests {pass "runned run-tests"}};
	Test::Fuzz::add-func($g);

	my $h = sub h2() {} but role {method run-tests {flunk "shuldn't run h2"}};
	Test::Fuzz::add-func($h);

	run-tests <f2 g2>;
}
