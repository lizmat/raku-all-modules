use v6.c;

use XML::XPath::Types;
use XML::XPath::Utils;

role XML::XPath::FunctionCall::Number {

    method !fn-floor(ResultType $set, Int $index, Int $of) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.floor
        };
        self!help-one-arg($set, $index, $of, $converter);
    }

    method !fn-ceiling(ResultType $set, Int $index, Int $of) {
        die 'functioncall ceiling() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            say "r = $r ceiling -> ", $r.ceiling, " ", $r.perl, " what:",  $r.WHAT;
            $r.ceiling;
        };
        self!help-one-arg($set, $index, $of, $converter);
    }

    method !fn-round(ResultType $set, Int $index, Int $of) {
        die 'functioncall round() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.round;
        };
        self!help-one-arg($set, $index, $of, $converter);
    }
}
