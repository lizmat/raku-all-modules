unit class GlotIO:ver<1.001001>;

use HTTP::Tinyish;
use JSON::Fast;
use URI::Escape;

has Str $.key;
has $!run-api-url  = 'https://run.glot.io';
has $!snip-api-url = 'https://snippets.glot.io';
has $!ua = HTTP::Tinyish.new: :agent("Perl 6 GlotIO API Implementation");

method !request ($method, $url, $content?, Bool :$add-token) {
    fail 'This operation requires API key specified in `key` argument to .new'
        if $add-token and not $.key;

    my %res;
    if ( $method eq 'GET' ) {
        %res = $!ua.get: $url,
            headers => %(
                ('Authorization' => "Token $!key" if $add-token)
            );
    }
    elsif ( $method eq 'POST' | 'PUT' ) {
        %res = $!ua."$method.lc()"( $url,
            headers => {
                'Content-type'  => 'application/json',
                'Authorization' => "Token $!key",
            },
            content => $content
        );
    }
    elsif ( $method eq 'DELETE' ) {
        %res = $!ua.delete: $url,
            headers => {
                'Authorization' => "Token $!key",
            };
        return True if %res<status> == 204;
    }
    else {
        fail "Unsupported request method `$method`";
    }

    %res<success> or fail "ERROR %res<status>: %res<reason>";

    return from-json %res<content>
        unless %res<headers><link>;

    my %links;
    for %res<headers><link> ~~ m:g/ '<'.+? 'page='(\d+).+?'>;'\s+'rel="'(.+?)\" / -> $m {
        %links{ ~$m[1] } = $m[0].Int;
    };
    return %(
        |%links,
        content => from-json %res<content>
    );
}

method languages {
    self!request('GET', $!run-api-url ~ '/languages').map: *<name>;
}

method versions (Str $lang) {
    my $uri = $!run-api-url ~ '/languages/' ~ uri-escape($lang);
    self!request('GET', $uri).map: *<version>;
}

multi method run (Str $lang, @files, :$ver = 'latest') {
    my %content;
    %content<files> = @files.map: {
        %(name => .key, content => .value )
    };
    my $uri = $!run-api-url ~ '/languages/' ~ uri-escape($lang)
        ~ '/' ~ uri-escape($ver);
    self!request: 'POST', $uri, to-json %content;
}

multi method run (Str $lang, Str $code, :$ver = 'latest') {
    self.run: $lang, [ main => $code ], :$ver;
}

method stdout (|c) {
    my $res = self.run(|c);
    fail "Error: $res" if $res<error>;
    $res<stdout>;
}

method stderr (|c) {
    my $res = self.run(|c);
    fail "Error: $res" if $res<error>;
    $res<stderr>;
}

method list (
    Int  :$page = 1,
    Int  :$per-page = 100,
    Str  :$owner,
    Str  :$language,
    Bool :$mine = False,
) {
    self!request: 'GET', $!snip-api-url ~ '/snippets'
        ~ "?page=$page&per_page=$per-page"
        ~ ( $owner.defined    ?? "&owner="    ~ uri-escape($owner)    !! '' )
        ~ ( $language.defined ?? "&language=" ~ uri-escape($language) !! '' ),
        add-token => $mine;
}

multi method create (
    Str   $lang,
    Str   $code,
    Str   $title = 'Untitled',
    Bool :$mine  = False
) {
    self.create: $lang, [ main => $code, ], $title;
}

multi method create (
    Str   $language,
          @files,
    Str   $title = 'Untitled',
    Bool :$mine  = False
) {
    my %content = :$language, :$title, public => !$mine;
    %content<files> = @files.map: {
        %(name => .key, content => .value )
    };
    self!request: 'POST', $!snip-api-url ~ '/snippets', to-json(%content),
        add-token => $mine;
}

method get ( Str:D $id ) {
    self!request: 'GET', $!snip-api-url ~ '/snippets/' ~ uri-escape($id);
}

multi method update ( %snippet ) {
    my @files = %snippet<files>.map: { .<name> => .<content> };
    self.update: %snippet<id>,
                 %snippet<language>,
                 @files,
                 %snippet<title>,
                 public => %snippet<public>;
}

multi method update (
    Str   $id,
    Str   $lang,
    Str   $code,
    Str   $title = 'Untitled',
    Bool :$public = False,
) {
    self.update: $id, $lang, [ main => $code, ], $title;
}

multi method update (
    Str   $id,
    Str   $language,
          @files,
    Str   $title = 'Untitled',
    Bool :$public = False,
) {
    my %content = :$language, :$title, public => $public;
    %content<files> = @files.map: {
        %(name => .key, content => .value )
    };
    self!request: 'PUT', $!snip-api-url ~ '/snippets/' ~ uri-escape($id),
        to-json(%content);
}

method delete ( Str $id ) {
    self!request: 'DELETE', $!snip-api-url ~ '/snippets/' ~ uri-escape($id);
}
