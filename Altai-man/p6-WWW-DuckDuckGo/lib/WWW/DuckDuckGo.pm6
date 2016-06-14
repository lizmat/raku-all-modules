use v6;

unit class WWW::DuckDuckGo;

use JSON::Fast;
use HTTP::UserAgent;
use URI;
use URI::Escape;
use WWW::DuckDuckGo::ZeroClickInfo;

has Str $!duckduckgo_api_url = 'http://api.duckduckgo.com/';
has Str $!duckduckgo_api_url_secure = 'https://api.duckduckgo.com/';
has     $!zeroclickinfo = WWW::DuckDuckGo::ZeroClickInfo;
has     $!http-agent    = HTTP::UserAgent.new;
has Int $!forcesecure   = 0;
has Int $!safeoff       = 0;
has Int $!html          = 0;
has Hash $!params;

multi method zci($q) {
    self.zeroclickinfo([$q]);
}

multi method zci(*@rest) {
    self.zeroclickinfo(@rest);
}

method zeroclickinfo_request_base($for_uri, @query_fields) {
    my $query = @query_fields.join(' ');
    $query = uri-escape($query);
    my $uri = URI.new($for_uri);
    my %params = %($!params);
    # FIXME: when it'll work with Perl 6 URI module;
    # $uri.query_param( q => $query); is much more safe.
    $uri ~= "?q=$query";
    $uri ~= "&o=json";
    $uri ~= "&kp=-1" if $!safeoff;
    $uri ~= "&no_redirect=1";
    $!html ?? ($uri ~= "&no_html=0") !! ($uri ~= "&no_html=1");
    for %params.keys {
	$uri ~= "&$_=%params{$_}";
    };
    $uri;
}

method zeroclickinfo_request_secure(@query_fields) {
    return if !@query_fields;
    self.zeroclickinfo_request_base($!duckduckgo_api_url_secure, @query_fields);
}

method zeroclickinfo_request(@query_fields) {
    return if !@query_fields;
    self.zeroclickinfo_request_base($!duckduckgo_api_url, @query_fields);
}

method zeroclickinfo(@query_fields) {
    return if !@query_fields;
    my $res;

    try {
	my $url = self.zeroclickinfo_request_secure(@query_fields);
	$res = $!http-agent.get($url);
    }
    if (!$!forcesecure && (!$res || !$res.is-success)) {
	warn("HTTP request failed " ~ $res.status-line ~ "\n") if ($res && !$res.is-success);
	warn("Can't access " ~ $!duckduckgo_api_url_secure ~ " failing back to: " ~ $!duckduckgo_api_url);
	my $url = self.zeroclickinfo_request(@query_fields);
	$res = $!http-agent.get($url);
    }
    return self.zeroclickinfo_by_response($res);
}

method zeroclickinfo_by_response($res) {
    if $res.is-success {
        my $result = from-json($res.content);
	return $!zeroclickinfo.new($result);
    } else {
	die 'HTTP request failed: ' ~ $res.status-line ~ "\n";
    }
}
