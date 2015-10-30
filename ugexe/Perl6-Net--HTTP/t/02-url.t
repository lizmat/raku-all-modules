use Test;
plan 3;

use Net::HTTP::URL;

subtest {
    my %valid = %(
        "http://httpbin.org"
            => %( :scheme<http>, :host<httpbin.org> ),
        "https://httpbin.org"
            => %( :scheme<https>, :host<httpbin.org> ),
        "https://httpbin.org:443"
            => %( :scheme<https>, :host<httpbin.org>, :port(443) ),
        "https://httpbin.org/"
            => %( :scheme<https>, :host<httpbin.org>, :path</> ),
        "https://httpbin.org:443/"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</> ),
        "https://httpbin.org/cookies"
            => %( :scheme<https>, :host<httpbin.org>, :path</cookies> ),
        "https://httpbin.org:443/cookies"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</cookies> ),
        "https://httpbin.org/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<httpbin.org>, :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://httpbin.org:443/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://httpbin.org/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<httpbin.org>, :path</>, :query<k2=v2&k1=v1> ),
        "https://httpbin.org:443/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</>, :query<k2=v2&k1=v1> ),
        "https://httpbin.org/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<httpbin.org>, :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://httpbin.org:443/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://httpbin.org/#frag"
            => %( :scheme<https>, :host<httpbin.org>, :fragment<frag> ),
        "https://httpbin.org:443/#frag"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :fragment<frag> ),
        "https://httpbin.org/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<httpbin.org>, :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://httpbin.org:443/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<httpbin.org>, :port(443), :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
    );

    for %valid.kv -> $test-url, %want {
        my $url = Net::HTTP::URL.new($test-url);
        is ~$url, $test-url;
        for %want.kv -> $part, $expected {
            is $url."$part"(), $expected;
        }
    }
}, '[name] valid absolute urls';

subtest {
    my %valid = %(
        "http://192.168.0.1"
            => %( :scheme<http>, :host<192.168.0.1> ),
        "https://192.168.0.1"
            => %( :scheme<https>, :host<192.168.0.1> ),
        "https://192.168.0.1:443"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443) ),
        "https://192.168.0.1/"
            => %( :scheme<https>, :host<192.168.0.1>, :path</> ),
        "https://192.168.0.1:443/"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</> ),
        "https://192.168.0.1/cookies"
            => %( :scheme<https>, :host<192.168.0.1>, :path</cookies> ),
        "https://192.168.0.1:443/cookies"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</cookies> ),
        "https://192.168.0.1/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<192.168.0.1>, :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://192.168.0.1:443/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://192.168.0.1/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<192.168.0.1>, :path</>, :query<k2=v2&k1=v1> ),
        "https://192.168.0.1:443/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</>, :query<k2=v2&k1=v1> ),
        "https://192.168.0.1/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://192.168.0.1:443/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://192.168.0.1/#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :fragment<frag> ),
        "https://192.168.0.1:443/#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :fragment<frag> ),
        "https://192.168.0.1/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://192.168.0.1:443/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<192.168.0.1>, :port(443), :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
    );

    for %valid.kv -> $test-url, %want {
        my $url = Net::HTTP::URL.new($test-url);
        is ~$url, $test-url;
        for %want.kv -> $part, $expected {
            is $url."$part"(), $expected;
        }
    }
}, '[ipv4] valid absolute urls';


subtest {
    my %valid = %(
        "http://[2601:587:200:d159:972:cd3b:eb76:4eb5]"
            => %( :scheme<http>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443) ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/cookies"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</cookies> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/cookies"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</cookies> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/cookies/set?k2=v2&k1=v1"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</>, :query<k2=v2&k1=v1> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/?k2=v2&k1=v1"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</>, :query<k2=v2&k1=v1> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/cookies/set?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</cookies/set>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :fragment<frag> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :fragment<frag> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
        "https://[2601:587:200:d159:972:cd3b:eb76:4eb5]:443/?k2=v2&k1=v1#frag"
            => %( :scheme<https>, :host<[2601:587:200:d159:972:cd3b:eb76:4eb5]>, :port(443), :path</>, :query<k2=v2&k1=v1>, :fragment<frag> ),
    );

    for %valid.kv -> $test-url, %want {
        my $url = Net::HTTP::URL.new($test-url);
        is ~$url, $test-url;
        for %want.kv -> $part, $expected {
            is $url."$part"(), $expected;
        }
    }
}, '[ipv6] valid absolute urls';
