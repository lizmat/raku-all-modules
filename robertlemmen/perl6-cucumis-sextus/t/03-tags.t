#!/usr/bin/env perl6

use v6;

use Test;

use CucumisSextus::Tags;

is(parse-tags('@test'), ['test'], "Parsing a single tag works");
is(parse-tags('@zicke @test'), ['test', 'zicke'], "Parsing multiple tags works");
is(parse-tags("\t@zicke     @test "), ['test', 'zicke'], "Parsing tags with extra spaces works");
is(parse-tags('@test-2.3_4'), ['test-2.3_4'], "Parsing a tag with special characters works");

dies-ok({ parse-filter('test') }, "Parsing a filter without '@' fails");
lives-ok({ parse-filter('@test') }, "Parsing a single-tag filter works");
lives-ok({ parse-filter('~@test') }, "Parsing a negated single-tag filter works");
lives-ok({ parse-filter('@test,@ofenrohr') }, "Parsing an ORed filter works");
lives-ok({ parse-filter('@test,~@ofenrohr,@zicke') }, "Parsing a longer filter with negation works");
dies-ok({ parse-filter('!@test') }, "Parsing a malformed negated filter fails");
dies-ok({ parse-filter('@test|@zicke') }, "Parsing a filter with misformed Oring fails");

ok(filter-matches(parse-filter('@test'), parse-tags('@test')), "Simple filter matches single tag");
nok(filter-matches(parse-filter('@test'), parse-tags('@zicke')), "Simple filter fails to match single, different tag");
ok(filter-matches(parse-filter('~@test'), parse-tags('@zicke')), "Simple negated filter matches single, different tag");
nok(filter-matches(parse-filter('~@test'), parse-tags('@test')), "Simple negated filter fails to match single matching tag");
ok(filter-matches(parse-filter('@test'), parse-tags('@test @zicke')), "Simple filter matches set of tags");
ok(filter-matches(parse-filter('@zicke'), parse-tags('@test @zicke')), "Simple filter matches set of tags");
ok(filter-matches(parse-filter('~@schnecke'), parse-tags('@test @zicke')), "Negated filter matches set of tags");
nok(filter-matches(parse-filter('~@test'), parse-tags('@test @zicke')), "Negated filter does not matches set of tags which include filter");
ok(filter-matches(parse-filter('~@test,@test'), parse-tags('@test @zicke')), "Negated filter ORed with itself matches set of tags");

done-testing;
