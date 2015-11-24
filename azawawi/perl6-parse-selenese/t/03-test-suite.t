
use v6;

use Test;

my $NUM_TEST_CASE_DEFS = 2;

plan 5 + $NUM_TEST_CASE_DEFS;

my $code = qq{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
  <title>Test Suite</title>
</head>
<body>
<table id="suiteTable" cellpadding="1" cellspacing="1" border="1" class="selenium"><tbody>
<tr><td><b>Test Suite</b></td></tr>
<tr><td><a href="login.html">Login</a></td></tr>
<tr><td><a href="invalid_login.html">Invalid Login</a></td></tr>
</tbody></table>
</body>
</html>
};

use Parse::Selenese;

my $parser = Parse::Selenese.new;
my $result = $parser.parse($code);
ok($result.defined, "Code parsed successfully");
my $test_suite = $result.ast;
ok($test_suite.defined, "Well defined");
ok($test_suite ~~ Parse::Selenese::TestSuite);
ok($test_suite.name eq 'Test Suite', 'Correct title');
ok($test_suite.test_case_defs.elems == $NUM_TEST_CASE_DEFS, "Found $NUM_TEST_CASE_DEFS test case definition(s)");
for 0..$NUM_TEST_CASE_DEFS-1 {
  ok($test_suite.test_case_defs[$_] ~~ Parse::Selenese::TestCaseDef, "index #$_ is a test case definition");
}

