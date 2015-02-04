use v6;
use JSON::Tiny;

class WebService::Justcoin {

    has Str $!base-url = "https://justcoin.com/api/v1";
    has Str $!api-key;

    has Callable $!url-get;
    has Callable $!url-post;
    has Callable $!url-delete;

    method markets(:$id?) {
        my $json = $!url-get($!base-url ~ "/markets");

        # .flat is workaround, so we don't get array in array (for some reason?)
        my @res := from-json($json).flat;
        return @res unless defined $id;
        @res = grep { $_{"id"} ~~ $id }, @res;
        return @res.elems ?? @res.pop !! Hash
    }

    method market-depth(Str $market-id) {
        my $json = $!url-get($!base-url ~ "/markets/$market-id/depth");
        return from-json($json);

    }

    method market-vohlc(Str $market-id) {
        X::NYI.new;
    }

    method currencies {
        from-json($!url-get(
            $!base-url ~ "/currencies")).flat
    }


    method orders {
        my @orders := from-json($!url-get(self!add-key(
            $!base-url ~ "/orders"))).flat;
        map { 
            to-dt($_{"createdAt"});
            $_;
        }, @orders;
    }

    method create-order(
            Str :$market!, # which market to buy in
            Rat :$amount!, # amount to buy,
            Str :$type!, # bid or ask
            Rat :$price? = Rat, # if undefined, palced as market order
            ) { 
        die "type is not valid, must be 'bid' or 'ask'"
            unless $type ~~ any <bid ask>;

        my $order = $!url-post(self!add-key($!base-url ~ "/orders"), {
            market => $market,
            amount => $amount,
            type => $type,
            price => $price,
        });

        return from-json($order);
    }

    method cancel-order(Int $id) {
        $!url-delete(self!add-key($!base-url ~ "/orders/$id"));
        return;
    }

    method balances(Str :$currency?) {
        my @b = from-json($!url-get(self!add-key(
            $!base-url ~ "/balances"))).flat;
        
        return @b unless defined $currency;
        
        @b = grep { $_{"currency"} ~~ $currency }, @b;
        return @b.elems ?? @b.pop !! Hash
    }

    method create-withdraw-btc(Str :$address, Rat :$amount) {
        from-json($!url-post(self!add-key($!base-url ~ "/btc/out"), {
                address => $address,
                amount => $amount,
            }));
    }

    method withdraws() {
        my @withdraws = from-json($!url-get(
                    self!add-key($!base-url ~ "/withdraws"))).flat;

        map {
            to-dt($_{"created"});
            $_{"completed"} ?? to-dt($_{"completed"}) !! DateTime;
            $_;
        }, @withdraws;

    }

    method !add-key($url) {
        self!require-api-key();
        if $url ~~ /\?/ {
            return $url ~ "&key=" ~ $!api-key;
        }
        return $url ~ "?key=" ~ $!api-key;
    }

    method !require-api-key() {
        fail "method requires API key, which is not set"
            unless $!api-key;
    }

    submethod BUILD(*%args) {
        $!url-get = %args{"url-get"} 
            || sub ($u) { die "url-get not set"; }

        $!url-post = %args{'url-post'}
            || sub ($u, %d) { die "url-post not set" }

        $!url-delete = %args{'url-delete'}
            || sub ($u) { die "url-delete not set" }

        if %args{'api-key'} {
            $!api-key = %args{'api-key'};
        }
    }
}

sub ugly-curl-get ($url) is export {
    my $tmpfile = IO::Path.new(IO::Spec.tmpdir).child(('a'..'z').pick(10).join);
    LEAVE { unlink $tmpfile }
    my $status = shell "curl -o $tmpfile -s -f $url";
    my $contents = slurp $tmpfile;
    fail "error fetching $url - contents: $contents"
        unless $status.exit == 0;
    return $contents;
}

sub params-to-str(%params is copy) {
    for keys %params -> $k {
        %params{$k} = ~%params{$k}
    }
    return %params;
}

sub ugly-curl-post ($url, %params is copy) is export {
    my $tmpfile = IO::Path.new(IO::Spec.tmpdir).child(('a'..'z').pick(10).join);
    LEAVE { unlink $tmpfile }

    my $datastr = to-json(params-to-str(%params));
    my $cmd = "curl -f -H 'Content-Type: application/json' --data '$datastr' -o $tmpfile -s $url";
    my $status = shell $cmd;
    fail "error posting '$url'"
        unless $status.exit == 0;
    my $contents = slurp $tmpfile;
    return $contents;

}

sub ugly-curl-delete ($url) is export {
    my $tmpfile = IO::Path.new(IO::Spec.tmpdir).child(('a'..'z').pick(10).join);
    LEAVE { unlink $tmpfile }
    my $status = shell "curl -i -H 'Accept: application/json' -X DELETE -o $tmpfile -s -f $url";
    fail "error deleting $url"
        unless $status.exit == 0;
    my $contents = slurp $tmpfile;
    return $contents;
}

sub to-dt(Str $timestamp is rw) {
    $timestamp ~~ s/\.\d+//;
    $timestamp = DateTime.new($timestamp);
}

