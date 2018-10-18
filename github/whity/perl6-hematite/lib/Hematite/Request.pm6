use MONKEY-SEE-NO-EVAL;
use Crust::Request;

unit class Hematite::Request is Crust::Request;

use JSON::Fast;

has $!body_params  = Nil;
has $!query_params = Nil;

# instance methods

multi method FALLBACK(Str $name where /^accepts\-(\w+)$/) returns Bool {
    my $type    = ($name ~~ /^accepts\-(\w+)$/)[0];
    my @accepts = self.accepts;

    return @accepts.first(-> $item { $item ~~ /$type/ }) ?? True !! False;
}

method body-parameters() returns Hash {
    if (!$!body_params.defined) {
        $!body_params = parse-params(callsame.all-pairs);
    }

    return $!body_params.perl.EVAL;
}

method body-params() { return self.body-parameters; }

method query-parameters() returns Hash {
    if (!$!query_params.defined) {
        my @pairs = callsame.all-pairs;
        $!query_params = parse-params(@pairs);
    }

    return $!query_params.perl.EVAL;
}

method query-params() { return self.query-parameters; }

method is-xhr() returns Bool {
    my $header = self.header('x-requested-with');

    return False if (!$header || $header.lc ne 'xmlhttprequest');
    return True;
}

method accepts() returns Array {
    my $accepts = self.headers.header('accept') || '';
    my @matches = ($accepts ~~ m:g/(\w+\/\w+)\,?/);

    return [] if !@matches;

    @matches = @matches.map(-> $item { $item[0] });
    return @matches;
}

method json() {
    my $supply = self.body;
    my $body   = "";

    $supply.tap(-> $chunk { $body ~= $chunk.decode("utf-8"); });
    $supply.wait;

    return from-json($body);
}

# helper functions

sub parse-params(@items) returns Hash {
    my %params = ();
    for @items -> $item {
        my $key = $item.key;
        next if !$key.defined || !$key.chars;

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
