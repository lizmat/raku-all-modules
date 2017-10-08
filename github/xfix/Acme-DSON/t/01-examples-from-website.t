use Test;
use Acme::DSON;

plan 4;

is from-dson('such "foo" is "bar". "doge" is "shibe" wow'),
            { foo => "bar", doge => "shibe" }, "first example";

is from-dson('such "foo" is such "shiba" is "inu", "doge" is yes wow wow'),
            { foo => { shiba => "inu", doge => True }}, "second example";

is from-dson('such "foo" is so "bar" also "baz" and "fizzbuzz" many wow'),
            { foo => ["bar", "baz", "fizzbuzz"] }, "third example";

is from-dson('such "foo" is 42, "bar" is 42very3 wow'),
            { foo => 34, bar => 17408 }, "fourth example";
