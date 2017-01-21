use v6;
use Test;
use DateTime::Parse;

plan 11;

my $rfc1123  = 'Sun, 06 Nov 1994 08:49:37 GMT';
my $bad      = 'Bad, 06 Nov 1994 08:49:37 GMT';
my $rfc850   = 'Sunday, 06-Nov-94 08:49:37 GMT';
my $rfc850v  = 'Sun 06-Nov-1994 08:49:37 GMT';
my $rfc850vb = 'Sun 06-Nov-94 08:49:37 GMT';

is DateTime::Parse.new('Sun', :rule<wkday>), 6, "'Sun' is day 6 in rule wkday";
is DateTime::Parse.new('06 Nov 1994', :rule<date1>).sort,
   {"day" => 6, "month" => 11, "year" => 1994}.sort, "we parse '06 Nov 1994' as rule date1";
is DateTime::Parse.new('08:49:37', :rule<time>).sort,
   {"hour" => 8, "minute" => 49, "second" => 37}.sort, "we parse '08:49:37' as rule time";
is DateTime::Parse.new($rfc1123),
   DateTime.new(:year(1994), :month(11), :day(6), :hour(8), :minute(49), :second(37)),
   'parse string gives correct DateTime object';
ok DateTime::Parse::Grammar.parse($rfc1123)<rfc1123-date>, "'Sun, 06 Nov 1994 08:49:37 GMT' is recognized as rfc1123-date";
throws-like qq[ DateTime::Parse.new('$bad') ], X::DateTime::CannotParse, invalid-str => $bad;
ok DateTime::Parse::Grammar.parse($rfc850)<rfc850-date>, "'$rfc850' is recognized as rfc850-date";
nok DateTime::Parse::Grammar.parse($rfc850v)<rfc850-date>, "'$rfc850v' is NOT recognized as rfc850-date";
ok DateTime::Parse::Grammar.parse($rfc850v)<rfc850-var-date>, "'$rfc850v' is recognized as rfc850-var-date";
nok DateTime::Parse::Grammar.parse($rfc850)<rfc850-var-date>, "'$rfc850' is NOT recognized as rfc850-var-date";
nok DateTime::Parse::Grammar.parse($rfc850vb)<rfc850-var-date>, "'$rfc850vb' is NOT recognized as rfc850-var-date";