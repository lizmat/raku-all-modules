use v6;
use Test;

use Text::More :ALL;

plan 8;

my (@s, @stripped);
# comment char is default '#'
@s = (
'some text',
'text # coment...',
' #comment',
'more text'
);

@stripped = (
'some text',
'text ',
' ',
'more text'
);


# return the stripped strings
for 0..^+@s -> $i {
    my $line = strip-comment(@s[$i]);
    is $line, @stripped[$i];
}

# # strip in place
# strip-comment-rw($str);
# is $line, $stripped;

# comment char is ';'
@s = (
'some text',
'text ; coment...',
' ;comment',
'more text'
);

# return the stripped strings
for 0..^+@s -> $i {
    my $line = strip-comment(@s[$i], ';');
    is $line, @stripped[$i];
}


# # embedded '#'
# my $se   = 'test \# more # comment';
# my $se-s = 'test \# more ';
# my $line = strip-comment($se);
# is $line, $se-s;
