use v6.c;

use XML::XPath::Types;
use XML::XPath::Utils;

role XML::XPath::FunctionCall::Node {

    method !fn-last(ResultType $set, Int $index, Int $of) {
        die 'functioncall last() requires no parameter' unless @.args.elems == 0;
        return [ $of ];
    }

    method !fn-position(ResultType $set, Int $index, Int $of) {
        die 'functioncall position() requires no parameter' unless @.args.elems == 0;
        return [ $index + 1 ];
    }

    method !fn-count(ResultType $set, Int $index, Int $of) {
        die 'functioncall count() requires one parameter' unless @.args.elems == 1;
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, $index, $of);
        return [ $interim.elems ];
    }

    method !fn-namespace-uri(ResultType $set, Int $index, Int $of) {
        die "namespace-uri can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        my $converter = sub ($r) {
            my ($uri, $node-name) = namespace-infos($r);
            return $uri;
        }
        if @.args.elems == 1 {
            self!help-one-arg($set, $index, $of, $converter);
        } else {
            # the more common way for name()
            return [ $converter.($set) ];
        }
    }

    method !fn-name(ResultType $set, Int $index, Int $of) {
        die "name can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        my $converter = sub ($r) {
            $r.name;
        }
        if @.args.elems == 1 {
            self!help-one-arg($set, $index, $of, $converter);
        } else {
            # the more common way for name()
            return [ $converter.($set) ];
        }
    }
}
