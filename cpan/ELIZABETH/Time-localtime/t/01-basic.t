use v6.c;
use Test;

plan 13;

{
    use Time::localtime;
    for <&localtime &ctime> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

{
    use Time::localtime :FIELDS;
    for <&localtime &ctime $tm_sec $tm_min $tm_hour $tm_mday $tm_mon $tm_year
         $tm_wday $tm_mday $tm_isdst> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

# vim: ft=perl6 expandtab sw=4
