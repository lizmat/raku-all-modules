use Test;
use LibGit2;

plan 1;

my $message = q:to/END/;
This is my message foo
I like it
# comment
ignore the comment
END

is Git::Message.prettify($message), q:to/END/, 'Message prettify';
This is my message foo
I like it
ignore the comment
END
