#!/usr/bin/env perl6

use v6;
use DBIish;

my %sths;
my @files = <Unihan_Readings.txt Unihan_DictionaryLikeData.txt>;
for @files -> $file {
    my $fh = open($file, :r)
        or die "Could not open $file for reading $!\n";
    for $fh.lines -> $line {
        next if $line ~~ /^\#/; # skip comment line
        next unless $line ~~ /\w/;
        # U+3400  kMandarin       qiū
        my ($code_point, $field_type, $value) = $line.split(/\s+/, 3);
        next unless $value;

        unless %sths{$field_type}:exists {
            ## build SQLite
            my $sqlite_file = "unihan_$field_type.sqlite3";
            unlink($sqlite_file) if $sqlite_file.IO ~~ :e;
            my $dbh = DBIish.connect("SQLite", database => $sqlite_file, :RaiseError);

            $dbh.do(q:to/STATEMENT/);
                CREATE TABLE unihan (
                    code_point  varchar(5) PRIMARY KEY,
                    value    text
                )
                STATEMENT

            %sths{$field_type} = $dbh.prepare(q:to/STATEMENT/);
                INSERT INTO unihan (code_point, value)
                VALUES ( ?, ? )
                STATEMENT
        }

        $code_point = $code_point.subst(/^U\+/, '');
        say ($code_point, $field_type, $value).perl;
        %sths{$field_type}.execute($code_point, $value);
    }
}

