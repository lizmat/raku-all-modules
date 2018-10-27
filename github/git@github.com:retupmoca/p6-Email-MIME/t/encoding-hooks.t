use v6;

class TestEncoding {
    method encode($bodytext){
        return "Encode";
    }

    method decode($encodedtext){
        return "Decode";
    }
}

use Test;

use lib 'lib';
use Email::MIME;

plan 4;

my $mail-text = slurp 't/test-mails/encoding-hooks';

my $eml = Email::MIME.new($mail-text);
is $eml.body-str, "This is some testing text.\n", 'Test empty decoder hook';
$eml.body-str-set('stuff here');
is $eml.body-raw, 'stuff here', 'Test empty encoder hook';

Email::MIME.set-encoding-handler('testencoding', TestEncoding);
$eml = Email::MIME.new($mail-text);
is $eml.body-str, 'Decode', 'Test decoder hook';
$eml.body-str-set('stuff here');
is $eml.body-raw, 'Encode', 'Test encoder hook';

