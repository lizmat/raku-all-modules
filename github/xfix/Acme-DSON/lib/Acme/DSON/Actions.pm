use v6;
use JSON::Tiny::Actions;
unit class Acme::DSON::Actions is JSON::Tiny::Actions;

method value:sym<number>($/) {
    my $result = :8(~$/);
    if $<very> {
        $result *= 8 ** $<very>;
    }
    make $result;
}

my %h = '\\' => "\\",
        '/' => "/",
        'b' => "\b",
        'n' => "\n",
        't' => "\t",
        'f' => "\f",
        'r' => "\r",
        '"' => "\"";
method str_escape($/) {
    if $<odigit> {
        make chr(:8(~$<odigit>));
    } else {
        make %h{~$/};
    }
}
