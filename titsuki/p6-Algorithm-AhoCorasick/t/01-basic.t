use v6;
use Test;
use-ok 'Algorithm::AhoCorasick';
use Algorithm::AhoCorasick;

# locate
{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick']);
    my $actual = $aho-corasick.locate('corasick');
    my $expected = {'corasick' => [0]};
    is-deeply $actual, $expected, "It should match a keyword with location";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick']);
    my $actual = $aho-corasick.locate('corasic');
    my $expected = Any;
    is-deeply $actual, $expected, "It should match none of words with location";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick','sick','co','si']);
    my $actual = $aho-corasick.locate('corasick');
    my $expected = {'corasick' => [0],'co' => [0],'si' => [4],'sick' => [4]};
    is-deeply $actual, $expected, "It should match all keywords with location";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['It\'s a piece of cake']);
    my $actual = $aho-corasick.locate('Tom said "It\'s a piece of cake."');
    my $expected = {'It\'s a piece of cake' => [10]};
    is-deeply $actual, $expected, "It should match a keyword including whitespaces with location";
}

# Easy Japanese test
{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['駄菓子','菓子','洋菓子']);
    my $actual = $aho-corasick.locate('駄菓子と洋菓子どちらが良いか悩ましい。');
    my $expected = {'駄菓子' => [0],'洋菓子' => [4],'菓子' => [1,5]};
    is-deeply $actual, $expected, "It should match all Japanese keywords with location";
}

# match
{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick']);
    my $actual = $aho-corasick.match('corasick');
    my $expected = set('corasick');
    is-deeply $actual, $expected, "It should match a keyword";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick']);
    my $actual = $aho-corasick.match('corasic');
    my $expected = Set;
    is-deeply $actual, $expected, "It should match none of words";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick','sick','co','si']);
    my $actual = $aho-corasick.match('corasick');
    my $expected = set('corasick','co','sick','si');
    is-deeply $actual, $expected, "It should match all keywords";
}

{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['It\'s a piece of cake']);
    my $actual = $aho-corasick.match('Tom said "It\'s a piece of cake."');
    my $expected = set('It\'s a piece of cake');
    is-deeply $actual, $expected, "It should match a keyword including whitespaces";
}

# Easy Japanese test
{
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['駄菓子','菓子','洋菓子']);
    my $actual = $aho-corasick.match('駄菓子と洋菓子どちらが良いか悩ましい。');
    my $expected = set('駄菓子','洋菓子','菓子');
    is-deeply $actual, $expected, "It should match all Japanese keywords";
}

done-testing;
