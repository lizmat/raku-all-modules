use v6;
use Terminal::Getpass;
use Cro::HTTP::Client;

unit role App::AizuOnlineJudge::Submittable;

has Cro::HTTP::Cookie $!cookie;
has Cro::HTTP::Client $!client;

method is-login(--> Bool) {
    return False without $!cookie;
    my $uri = Cro::Uri.parse('https://judgeapi.u-aizu.ac.jp');
    my $client = Cro::HTTP::Client.new(base-uri => $uri);
    my $response = await $client.get('/self',
                                     cookies => {
                                            $!cookie.name => $!cookie.value
                                        }
                                    );
    $response.say;
    $response.status == 200
}

method login(Str :$user!, Str :$password! --> Bool) {
    return True if self.is-login;

    my $uri = Cro::Uri.parse('https://judgeapi.u-aizu.ac.jp');
    $!client = Cro::HTTP::Client.new(base-uri => $uri, body-serializers => [ Cro::HTTP::BodySerializer::JSON ]);
    my %data = %(
        id => $user,
        password => $password
    );
    my $response = await $!client.post('/session', body => %data, content-type => 'application/json');
    my $cookie-value = $response.headers.grep({ .name.lc eq 'set-cookie' }).map({ .value }).list.head;
    {
        use Cro::HTTP::Cookie;

        my regex cookie-name { <[\x1F..\xFF] - [() \< \> @,;: \\ \x22 /\[\] ?={} \x20 \x1F \x7F]>+ };

        my regex octet { <[\x21
                  \x23..\x2B
                  \x2D..\x3A
                  \x3C..\x5B
                  \x5D..\x7E]>*};
        my regex cookie-value { [ <octet> || '("' <octet> '")' ] };

        my regex name  { <[\w\d]> (<[\w\d-]>* <[\w\d]>)* };
        # In Domain regex first dot comes from
        # RFC 6265 and is intended to be ignored.
        my regex domain { '.'? (<name> ['.'<name>]*) }

        my regex path { <[\x1F..\xFF] - [;]>+ }

        my grammar MyCookieString {
            token TOP          { <cookie-pair> [';' <cookie-av> ]* }
            token cookie-pair  { <cookie-name> '=' <cookie-value> }
            proto token cookie-av {*}
            token cookie-av:sym<expires>   { :i 'Expires=' [ <dt=DateTime::Parse::Grammar::rfc1123-date>    |
                                                             <dt=DateTime::Parse::Grammar::rfc850-date>     |
                                                             <dt=DateTime::Parse::Grammar::rfc850-var-date> |
                                                             <dt=DateTime::Parse::Grammar::asctime-date>    ] }
            token cookie-av:sym<max-age>   { :i 'Max-Age=' '-'? <[1..9]> <[0..9]>* }
            token cookie-av:sym<domain>    { :i 'Domain=' <domain> }
            token cookie-av:sym<path>      { :i 'Path=' <path> }
            token cookie-av:sym<secure>    { :i 'Secure' }
            token cookie-av:sym<httponly>  { :i 'HttpOnly' }
            token cookie-av:sym<extension> { :i <path> }
        }
        $!cookie = MyCookieString.parse($cookie-value, :actions(CookieBuilder.new)).made;
    }
    $response.status == 200;
}

method post-code(:%form! --> Str) {
    my $response = await $!client.post('/submissions', body => %form,
                                       cookies => {
                                              $!cookie.name => $!cookie.value
                                          },
                                       content-type => 'application/json',
                                      );
    %(self.response-to-p6($response))<token>;
}

method get-password(Bool :$mockable = False, Str :$mockpass = "mockpass" --> Str) {
    if $mockable {
       $mockpass;
    } else {
       getpass;
    }
}

method validate-code(Str $code --> Bool) {
    if not $code.IO.f {
        die "ERROR: Couldn't find your code";
    }
    True;
}

method validate-language(Str $language --> Bool) {
    if <C C++ C++11 C# D Ruby Python Python3 PHP JavaScript Scala Haskell OCaml>.grep(* eq $language) == 0 {
        die "ERROR: $language is not an acceptable language";
    }
    True;
}

method response-to-p6(Cro::HTTP::Response $response) {
    if $response.status != 200 {
        die "ERROR: Failed in sending your code.";
    }
    use JSON::Fast;
    from-json(await $response.body-text);
}

method wait(Int:D $try-count) {
    $*ERR.say(sprintf("Waiting... (%d seconds)", 4 ** $try-count));
    sleep(4 ** $try-count);
}

method validate-problem-number($problem-number --> Bool) { ... }

method ask-result($token --> Str) {
    my Bool $success = False;
    loop (my $try-count = 1; $try-count <= 5; $try-count++) {
        self.wait($try-count);
        my $response = await $!client.get('/submission_records/recent');
        my $recent-post = self.response-to-p6($response);
        my %latest = self.get-latest-by-token($recent-post, $token);
        return sprintf("%s %.2f sec", [%latest<status>, %latest<cputime> / 100]);
    }

    if not $success {
        die "ERROR: Timeout";
    }
}

method get-latest-by-token($recent-post, Str:D $token --> Hash) {
    use JSON::Fast;

    my %latest;
    my @status-list = <CompileError WrongAnswer TimeLimitExceeded MemoryLimitExceeded Accepted OutputLimitExceeded RuntimeError PresentationError>;
    my %row = @($recent-post).grep({ .<token> eq $token }).head;

    %latest<submission-date> = $%row<submissionDate>;
    %latest<status> = @status-list[%row<status>];
    %latest<cputime> = %row<cpuTime>;
    return %latest;
}

method run { ... }
