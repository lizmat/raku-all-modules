use v6;

unit module Lingua::Unihan;

use DBIish;
use Encode;

my %sths;

sub unihan_query($field_type, $text) is export {
    unless %sths{$field_type}:exists {
        my $sqlite_file = $?FILE.IO.dirname ~ "/Unihan/unihan_$field_type.sqlite3";
        my $dbh = DBIish.connect("SQLite", database => $sqlite_file, :RaiseError);
        %sths{$field_type} = $dbh.prepare('SELECT value FROM unihan WHERE code_point = ?');
    }

    my @res;
    for comb(/\N/, $text) -> $char {
        my $code_point = unihan_codepoint($char);
        %sths{$field_type}.execute(uc $code_point);
        my ($v) = %sths{$field_type}.fetchrow_array;
        if ($v) {
            @res.push($v);
        } else {
            @res.push($char);
        }
    }
    return @res;
}

sub unihan_codepoint($text) is export {
    return sprintf("%04x", ord Encode::decode('utf-8', buf8.new($text.encode)));
}

=begin pod

=head NAME

Lingua::Unihan - reader (SQLite) for unihan database

=head SYNOPSIS

    use Lingua::Unihan;

    my $codepoint = unihan_codepoint('你'); # 4f60

    my $mandarin = unihan_query('kMandarin', '林'); # 'lín'
    my $strokes  = unihan_query('kTotalStrokes', '林'); # 8

=end pod
