#!/usr/bin/env perl6

use Test;

use CSS::Grammar::Test;
use CSS::Grammar::CSS1;
use CSS::Grammar::CSS21;
use CSS::Grammar::CSS3;

# whitespace
for ' ', '  ', "\t", "\r\n", ' /* hi */ ', '/*there*/', '<!-- zzz -->' {
    ok $_ ~~ /^<CSS::Grammar::ws>$/, "ws: $_";
}
nok "r\n" ~~ /^<CSS::Grammar::ws>$/, "ws: r\\n";

# comments
for ('/**/', '/* hi */', '<!--X-->',
     '<!-- almost done -->',
     '<!-- Out of coffee',
     '/* is that the door?',) {
    ok $_ ~~ /^<CSS::Grammar::comment>$/, "comment: $_";
}

# unicode
for "f", "012f", "012A" {
    ok $_ ~~ /^<CSS::Grammar::unicode>$/, "unicode: $_";
}

for "012AF", "012AFc" {
    # css2+ unicode is up to 6 digits
    nok $_ ~~ /^<CSS::Grammar::CSS1::unicode>$/, "not css1 unicode: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS21::unicode>$/, "css21 unicode: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS3::unicode>$/, "css3 unicode: $_";
}

# angle, frequency - introduced with css2
for '70deg', '50Hz' {
    ok $_ ~~ /^<CSS::Grammar::CSS1::num><CSS::Grammar::CSS1::Ident>$/, "css1 num+ident: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS21::term>$/, "css21 term: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS3::term>$/, "css3 term: $_";
}

# non-ascii
for '¡', "\o250", 'ÿ' {
    ok $_ ~~ /^<CSS::Grammar::nonascii>$/, "non-ascii: $_ ("~ .ord ~')';
    ok $_ ~~ /^<CSS::Grammar::CSS1::nonascii>$/, "non-ascii css1: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS21::nonascii>$/, "non-ascii css21: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS3::nonascii>$/, "non-ascii css3: $_";
    ok $_ ~~ /^<CSS::Grammar::Core::nonascii>$/, "non-ascii scan: $_";
    ok $_ ~~ /^<CSS::Grammar::Core::Ident>$/, "non-ascii ident: $_";
}

# css1 and css21 only recognise latin chars as non-ascii (\o240-\o377)
for '' {
    ok $_ ~~ /^<CSS::Grammar::nonascii>$/, "non-ascii: $_ ("~ .ord ~')';
    nok $_ ~~ /^<CSS::Grammar::CSS1::nonascii>$/, "not non-ascii css1: $_";
    nok $_ ~~ /^<CSS::Grammar::CSS21::nonascii>$/, "not non-ascii css21: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS3::nonascii>$/, "non-ascii css3: $_";
}

for chr(0), ' ', '~' {
    nok $_ ~~ /^<CSS::Grammar::nonascii>$/, "not non-ascii: $_";
    nok $_ ~~ /^<CSS::Grammar::CSS1::nonascii>$/, "not non-ascii css1: $_";
    nok $_ ~~ /^<CSS::Grammar::CSS21::nonascii>$/, "not non-ascii css21: $_";
    nok $_ ~~ /^<CSS::Grammar::CSS3::nonascii>$/, "not non-ascii css3: $_";
} 

for 'http://www.bg.com/pinkish.gif', '"http://www.bg.com/pinkish.gif"', "'http://www.bg.com/pinkish.gif'", '"http://www.bg.com/pink(ish).gif"', "'http://www.bg.com/pink(ish).gif'", 'http://www.bg.com/pink%20ish.gif', 'http://www.bg.com/pink\(ish\).gif' {
    ok "url($_)" ~~ /^<CSS::Grammar::url>$/, "css1 url: url($_)";
}

for 'http://www.bg.com/pink(ish).gif' {
    nok "url($_)" ~~ /^<CSS::Grammar::url>$/, "not css1 url: url($_)";
}

for 'Appl8s', 'oranges', 'k1w1-fru1t', '-i' {
    ok $_ ~~ /^<CSS::Grammar::Ident>$/, "ident: $_";
}

for '8' {
    nok $_ ~~ /^<CSS::Grammar::Ident>$/, "not ident: $_";
}

for (q{"Hello"}, q{'world'}, q{''}, q{""}, q{"'"}, q{'"'}, q{"grocer's"}, 
    q{"a /* non-comment */"}) {
    ok $_ ~~ /^<CSS::Grammar::string>$/, "string: $_";
}

for q{"Unclosed},  q{"} {
    nok $_ ~~ /^<CSS::Grammar::string>$/, "not string: $_";
    ok $_ ~~ /^<CSS::Grammar::badstring>$/, "badstring: $_";
}

for q{world'}, q{'''}, q{'grocer's'},  "'hello\nworld'" {
    nok $_ ~~ /^<CSS::Grammar::string>$/, "not string: $_";
}

for (< * + \> |= ~= >) {
    ok $_ ~~ /^<CSS::Grammar::Core::_op>$/, "scan op: $_";
}

my $rule-list = '{
   body { font-size: 10pt }
}';

for ('{ }', $rule-list) { 
    ok $_ ~~ /^<CSS::Grammar::CSS21::rule-list>$/, "css21 rule-list: $_";
    ok $_ ~~ /^<CSS::Grammar::CSS3::rule-list>$/, "css3 rule-list: $_";
}

my $at-rule_page = '@page :left { margin: 3cm };';
my $at-rule_print = '@media print ' ~ $rule-list;

for ($at-rule_page, $at-rule_print) { 
    ok $_ ~~ /^<CSS::Grammar::CSS21::at-rule>$/, "css21 at-rule: $_";
}

done-testing;
