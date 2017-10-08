use MONKEY-SEE-NO-EVAL;
use Crust::Request;

unit class Hematite::Request is Crust::Request;

has $!body_params  = Nil;
has $!query_params = Nil;

# instance methods

method body-parameters() returns Hash {
    if (!$!body_params.defined) {
        $!body_params = parse-params(callsame.all-pairs);
    }

    return EVAL($!body_params.perl);
}

method body-params() { return self.body-parameters; }

method query-parameters() returns Hash {
    if (!$!query_params.defined) {
        $!query_params = parse-params(callsame.all-pairs);
    }

    return EVAL($!query_params.perl);
}

method query-params() { return self.query-parameters; }


# helper functions

sub parse-params(@items) returns Hash {
    my %params = ();
    for @items -> $item {
        my $key   = $item.key;
        my $value = $item.value;
        if (%params{$key}:exists) {
            my $cur_value = %params{$key};
            if (!$cur_value.isa(Array)) {
                $value = [$cur_value, $value];
            }
        }

        %params{$key} = $value;
    }

    return %params;
}
