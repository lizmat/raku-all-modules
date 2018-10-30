#! /usr/bin/env perl6

use v6.c;

use DateTime::Parse;
use Test;


plan 2;

subtest "date(1) strings" => {
	my @asctimes = (
		"Fri Mar 23 13:20:46 2018",
		"Thu Mar  3 23:05:25 2005",
	);

	plan @asctimes.elems + 1;

	for @asctimes {
		lives-ok { DateTime::Parse.new($_); }, "$_ parses";
	}

	subtest "Thu Mar  3 23:05:25 2005 parses correctly" => {
		my $dt = DateTime::Parse.new("Thu Mar  3 23:05:25 2005");

		plan 7;

		isa-ok $dt, DateTime, "Returns a DateTime object";

		is $dt.year, 2005, "Year is correct";
		is $dt.month, 3, "Month is correct";
		is $dt.day, 3, "Day is correct";
		is $dt.hour, 23, "Hour is correct";
		is $dt.minute, 5, "Minute is correct";
		is $dt.second, 25, "Second is correct";
	}
}

subtest "locale datetime string with timezone" => {
	my @asctimes = (
		"Fri Mar 23 13:20:46 2018 UTC",
		"Fri Mar 23 13:20:46 2018 UTC+3",
	);

	plan @asctimes.elems + 2;

	for @asctimes {
		lives-ok { DateTime::Parse.new($_); }, "$_ parses";
	}

	subtest "Fri Mar 23 13:20:46 2018 UTC parses correctly" => {
		my $dt = DateTime::Parse.new("Fri Mar 23 13:20:46 2018 UTC");

		plan 7;

		isa-ok $dt, DateTime, "Returns a DateTime object";

		is $dt.year, 2018, "Year is correct";
		is $dt.month, 3, "Month is correct";
		is $dt.day, 23, "Day is correct";
		is $dt.hour, 13, "Hour is correct";
		is $dt.minute, 20, "Minute is correct";
		is $dt.second, 46, "Second is correct";
	}

	subtest "Fri Mar 23 13:20:46 2018 UTC+3 parses correctly" => {
		my $dt = DateTime::Parse.new("Fri Mar 23 13:20:46 2018 UTC+3");

		plan 10;

		isa-ok $dt, DateTime, "Returns a DateTime object";
		is $dt.offset-in-hours, 3, "Offset is 3 hours";

		$dt .= utc;

		isa-ok $dt, DateTime, "Still a DateTime after converting to UTC";
		is $dt.offset-in-hours, 0, "Offset is now 0 hours";

		is $dt.year, 2018, "Year is correct";
		is $dt.month, 3, "Month is correct";
		is $dt.day, 23, "Day is correct";
		is $dt.hour, 10, "Hour is correct";
		is $dt.minute, 20, "Minute is correct";
		is $dt.second, 46, "Second is correct";
	}
}

# vim: ft=perl6 noet
