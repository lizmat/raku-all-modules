use v6.c;
use Test;
use Text::Sift4;

subtest {
    is sift4(Str, "perl6"), 5, 'undefined one vs "perl6"';
    is sift4("perl6", Str), 5, '"perl6" vs undefined one';
}, "the one side has an undefined Str";
 
subtest {
    is sift4("", "perl6"), 5, 'zero-length one vs "perl6"';
    is sift4("perl6", ""), 5, '"perl6" vs zero-length one';
}, "the one side has a zero-length Str";

subtest {
    is sift4(Str,Str), 0;
    is sift4("",""), 0;
    is sift4("a","a"), 0;
    is sift4("abc","abc"), 0;
}, "equal";

subtest {
    is sift4("", "a"), 1, '"" -> "a"';
    is sift4("ab", "abc"), 1, '"ab" -> "abc"';
    is sift4("ab", "acb"), 1, '"ab" -> "acb"';
    is sift4("ab", "cab"), 1, '"ab" -> "cab"';
}, "insertion";

subtest {
    is sift4("a", ""), 1, '"a" -> ""';
    is sift4("abc", "ab"), 1, '"abc" -> "ab"';
    is sift4("abc", "bc"), 1, '"abc" -> "bc"';
    is sift4("abc", "ac"), 1, '"abc" -> "ac"';
    is sift4("abc", "a"), 2, '"abc" -> "a"';
    is sift4("abc", "b"), 2, '"abc" -> "b"';
    is sift4("abc", "c"), 2, '"abc" -> "c"';
}, "deletion";

subtest {
    is sift4("a", "b"), 1, '"a" -> "b"';
    is sift4("abc", "abx"), 1, '"abc" -> "abx"';
    is sift4("abc", "axc"), 1, '"abc" -> "axc"';
    is sift4("abc", "xbc"), 1, '"abc" -> "xbc"';
    is sift4("abc", "xxc"), 2, '"abc" -> "xxc"';
    is sift4("abc", "xxx"), 3, '"abc" -> "xxx"';
}, "substitution";

subtest {
    todo "NOTE: Sift4 is approximation of Levenstein", 1;
    is sift4("abcx", "xabc"), 2, 'insertion("abcx" -> "xabcx") -> deletion("xabcx" -> "xabc")';
    
    is sift4("abxc", "abcxy"), 2, 'insertion("abxc" -> "abcxc") -> substitution("abcxc" -> "abcxy")';

    todo "NOTE: Sift4 is approximation of Levenstein", 1;
    is sift4("abxcy", "abcyz"), 2, 'deletion("abxcy" -> "abcy") -> insertion("abcy" -> "abcyz")';
    is sift4("abc", "bx"), 2, 'deletion("abc" -> "bc") -> substitution("bc" -> "bx")';
    is sift4("axyc", "azc"), 2, 'substitution("axyc" -> "azyc") -> deletion("azyc" -> "azc")';
    is sift4("a", "bc"), 2, 'substitution("a" -> "b") -> insertion("b" -> "bc")';
}, "combination";

done-testing;
