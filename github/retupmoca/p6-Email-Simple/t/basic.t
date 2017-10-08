use v6;
use Test;

use lib 'lib';

use Email::Simple;

my $mail-text = slurp './t/test-mails/josey-nofold';

my $mail = Email::Simple.new($mail-text);

plan 14;

my $old-from;
is $old-from = $mail.header('From'), 'Andrew Josey <ajosey@rdg.opengroup.org>', "We can get a header";

my $sc = 'Simon Cozens <simon@cpan.org>';
is $mail.header-set("From", $sc), $sc, "Setting returns new value";
is $mail.header("From"), $sc, "Which is consistently returned";
ok defined($mail.header-obj.Str.index($sc)), 'stringified header object contains new "From" header';

is $mail.header("Bogus"), Nil, "Missing header returns Nil.";

$mail.header-set("From", $old-from);

my $body;
ok ($body = $mail.body) ~~ m:s/Austin Group Chair/, "Body has sane stuff in it";

my $hi = "Hi there!\n";
$mail.body-set($hi);
is $mail.body, $hi, "Body can be set properly";

$mail.body-set($body);
is ~$mail, $mail-text, "Good grief, it's round-trippable";

is Email::Simple.new(~$mail).Str, $mail-text, "Good grief, it's still round-trippable";

$mail.header-set('Previously-Unknown', 'wonderful species');
is $mail.header('Previously-Unknown'), 'wonderful species', "We can add new headers...";
ok $mail.Str ~~ m:s/Previously\-Unknown\: wonderful species/, "...that show up in the stringification";

# with odd newlines
my $nr = "\x0a\x0d";
my $nasty = "Subject: test{$nr}To: foo{$nr}{$nr}foo{$nr}";
$mail = Email::Simple.new($nasty);
is $mail.crlf, "{$nr}", "got correct line terminator";
is $mail.body, "foo{$nr}", "got correct body";
is ~$mail, $nasty, "Round trip nasty";
