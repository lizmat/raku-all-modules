use v6.c;

use Test;

use Lingua::Palindrome;

ok  char-palindrome('Was it a car or a cat I saw?');
nok char-palindrome('Foo bar baz!');
ok  char-palindrome('MadaM', :case(True));
nok char-palindrome('Madam', :case(True));
ok  char-palindrome('a121z', :alpha(False));
nok char-palindrome('a123z', :alpha(False));
ok  char-palindrome('a12ba', :digit(False));
nok char-palindrome('a12bc', :digit(False));
ok  char-palindrome('M.d.m', :punct(True));
nok char-palindrome('M.d-m', :punct(True));
ok  char-palindrome('M d m', :space(True));
nok char-palindrome('ada  ', :space(True));

ok  word-palindrome('Fall leaves after leaves fall.');
nok word-palindrome('Foo bar baz!');
nok word-palindrome('Fall leaves after leaves fall.', :case(True));
ok  word-palindrome('Fall leaves after leaves Fall.', :case(True));
ok  word-palindrome('1234 leaves after leaves 1234.', :alpha(False));
nok word-palindrome('1234 leaves after leaves 4321.', :alpha(False));
ok  word-palindrome('1234 leaves after leaves 5678.', :digit(False));
nok word-palindrome('1234 leaves after leavez 5678.', :digit(False));
nok word-palindrome('Fall leaves after leaves fall.', :punct(True));
ok  word-palindrome('Fall leaves after leaves fall ', :punct(True));

ok  line-palindrome('t/abc1.txt'.IO);
nok line-palindrome('t/abc2.txt'.IO);

ok  line-palindrome(q:to/END/);
Abc
def
abc
END
nok line-palindrome(q:to/END/);
Abc
def
ghi
END

ok  line-palindrome(q:to/END/, :case(True));
Abc
def
Abc
END
nok line-palindrome(q:to/END/, :case(True));
Abc
def
abc
END

ok  line-palindrome(q:to/END/, :alpha(False));
abc123
def456
ghi123
END
nok line-palindrome(q:to/END/, :alpha(False));
abc123
def456
ghi789
END

ok  line-palindrome(q:to/END/, :digit(False));
Abc123
def456
abc789
END
nok line-palindrome(q:to/END/, :digit(False));
Abc123
def456
ghi789
END

ok  line-palindrome(q:to/END/, :punct(True));
Abc.
def
abc.
END
nok line-palindrome(q:to/END/, :punct(True));
Abc
def
abc.
END

ok  line-palindrome(q:to/END/, :space(True));
Ab c
def
ab c
END
nok line-palindrome(q:to/END/, :space(True));
Ab c
def
a b c
END

# TODO IO::Path $path,

done-testing;
