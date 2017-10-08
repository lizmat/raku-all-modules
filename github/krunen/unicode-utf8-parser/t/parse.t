use Test;
use Unicode::UTF8-Parser;

sub utf8parse($list) {
    parse-utf8-bytes($list.Supply).list;
}

sub test-parse($s) {
    my $s2 = $s;
    $s2 ~~ s:g/<:!L+:!N+:!S+:!P>/./;
    my @parse = utf8parse($s.encode('utf8').list);
    if (@parse eq $s.comb) {
        ok 1, "'$s2' parsed (unconverted)";
    } else {
        is @parse.join('').NFC, $s.NFC, "'$s2' parsed (NFC converted)";
    }
}

test-parse("ABCD");
test-parse("Æ");
test-parse("Æa");
test-parse("ÆØÅabcæøå");
test-parse("സന്തോഷകരമായ ക്രിസ്മസ്");

is utf8parse(["æ".encode('utf8').list.Slip, 150, 'a'.ord]), ['æ', 150, 'a'], "æ<150>a parsed correcly";

done-testing;
