use v6.c;

use XML::XPath::Types;
use XML::XPath::Utils;

role XML::XPath::FunctionCall::String {

    method !fn-concat(ResultType $set, Int $index, Int $of) {
        die 'functioncall concat() requires at least one parameter' unless @.args.elems > 0;

        my $result = "";
        for @.args -> $arg {
            $result ~= unwrap $arg.evaluate($set, $index, $of);
        }
        return [$result];
    }

    method !fn-starts-with(ResultType $set, Int $index, Int $of) {
        die "functioncall starts-with() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.starts-with($s) };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }

    method !fn-contains(ResultType $set, Int $index, Int $of) {
        die "functioncall containts() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.contains($s) };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }

    method !fn-substring-before(ResultType $set, Int $index, Int $of) {
        die "functioncall substring-before() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){
            my $match = $r.Str ~~ /$s/;
            return $match ?? $match.prematch !! '';
        };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }

    method !fn-substring-after(ResultType $set, Int $index, Int $of) {
        die "functioncall substring-after() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){
            my $match = $r.Str ~~ m/$s/;
            return $match ?? $match.postmatch !! '';
        };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }

    method !fn-substring(ResultType $set, Int $index, Int $of) {
        die 'functioncall substring() requires 2 or 3 parameters' unless @.args.elems == 2|3;
        my $string = unwrap @.args[0].evaluate($set, $index, $of);
        my $start  = round unwrap @.args[1].evaluate($set, $index, $of);

        my $result;
        if $start ~~ NaN {
            $result = "";
        }
        elsif @.args[2]:exists {
            my $end = round unwrap @.args[2].evaluate($set, $index, $of);

            if $start < 1 {
                $end  -= 1 - $start;
                $start = 0;
            } else {
                $start--;
            }

            if $end ~~ NaN {
                $result = "";
            } else {
                $result = $string.substr($start, $end);
            }
        } else {
            $start = $start < 1 ?? 0 !! $start - 1;
            $result = $string.substr($start);
        }
        return [ $result ];
    }

    method !fn-string-length(ResultType $set, Int $index, Int $of) {
        die 'functioncall string-length() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.defined ?? $r.Str.chars !! 0;
        };
        self!help-one-arg($set, $index, $of, $converter);
    }

    method !fn-normalize-space(ResultType $set, Int $index, Int $of) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.Str.trim;
        };
        self!help-one-arg($set, $index, $of, $converter);
    }

    method !fn-translate(ResultType $set, Int $index, Int $of) {
        die 'functioncall translate() requires three parameters' unless @.args.elems == 3;
        my $converter = sub ($r, Str $s1, Str $s2) { $r.trans($s1 => $s2, :delete) };
        return self!help-three-arg-second-thrid-string($set, $index, $of, $converter);
    }
}
