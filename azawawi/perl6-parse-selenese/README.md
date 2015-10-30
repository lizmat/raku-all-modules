Parse::Selenese
===============

[![Build Status](https://travis-ci.org/azawawi/perl6-parse-selenese.svg?branch=master)](https://travis-ci.org/azawawi/perl6-parse-selenese)

This is a simple utility to parse Selenese test cases and suites that are
usually generated from the Selenium IDE.

## Example

```Perl6
use Parse::Selenese;

my $selenese = qq{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head profile="http://selenium-ide.openqa.org/profiles/test-case">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="selenium.base" href="http://some-server:3000/" />
<title>Login</title>
</head>
<body>
<table cellpadding="1" cellspacing="1" border="1">
<thead>
<tr><td rowspan="1" colspan="3">Login</td></tr>
</thead><tbody>
<tr>
	<td>open</td>
	<td>/login</td>
	<td></td>
</tr>
<tr>
	<td>type</td>
	<td>name=username</td>
	<td>admin</td>
</tr>
<tr>
	<td>type</td>
	<td>name=password</td>
	<td>123</td>
</tr>
<tr>
	<td>clickAndWait</td>
	<td>//button[@type='submit']</td>
	<td></td>
</tr>
<tr>
	<td>verifyTitle</td>
	<td>regex:Home</td>
	<td></td>
</tr>

</tbody></table>
</body>
</html>
};

my $parser = Parse::Selenese.new;
my $result = $parser.parse($selenese);
if $result {
  say "Matches with the following results: " ~ $result.ast.perl;
} else {
  say "Fails";
}
```

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

    panda update
    panda install Parse::Selenese

## Testing

To run tests:

    prove -e perl6

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

Artistic License 2.0
