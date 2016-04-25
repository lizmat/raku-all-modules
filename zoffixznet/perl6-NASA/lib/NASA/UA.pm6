unit role NASA::UA;

use HTTP::Tinyish;
use JSON::Fast;
use URI::Escape;

has Str $.key = 'DEMO_KEY';
has $!ua      = HTTP::Tinyish.new(agent => "Perl 6 NASA.pm6");

method !request ($method, $url, *%params) {
    %params  = %params.kv.map: { uri-escape $_ };

    my %res;
    if ( $method eq 'GET' ) {
        %res = $!ua.get: $url ~ '?' ~ 'api_key=' ~ uri-escape($!key) ~ '&'
            ~ %params.pairs.map(*.kv.join: '=').join: '&';
    }
    else {
        fail "Unsupported request method `$method`";
    }

    %res<success> or fail "ERROR %res<status>: %res<reason>";
    return from-json %res<content>;
}
