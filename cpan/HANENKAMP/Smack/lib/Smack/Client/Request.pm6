use v6;

use Smack::Client::Message;

unit class Smack::Client::Request is Smack::Client::Message;

use Smack::URI;
use HTTP::Headers :standard-names;
use URI::Escape;

has Smack::URI $.uri is rw is required;
has Str $.method is rw is required;

method host(--> Str) { $!uri.host }
method port(--> UInt) { $!uri.port }

multi method to-p6wapi(Smack::Client::Request:D: --> Hash) {
    my sub _errors {
        my $errors = Supplier.new;
        $errors.Supply.tap: -> $s { $*ERR.say($s) };
        $errors;
    }

    my %config =
        'p6w.version'          => v0.7.Draft,
        'p6w.errors'           => _errors,
        'p6w.run-once'         => False,
        'p6w.multithread'      => False,
        'p6w.multiprocess'     => False,
        'p6w.protocol.support' => set('request-response'),
        'p6w.protocol.enabled' => set('request-response'),
        ;

    self.to-p6wapi(%config)
}

multi method to-p6wapi(Smack::Client::Request:D: %config --> Hash) {
    my %env = |%config,
        HTTP_HOST           => $.host,
        |$.headers.map({
            if .key eq 'content-length' {
                CONTENT_LENGTH => .value
            }
            elsif .key eq 'content-type' {
                CONTENT_TYPE => .value
            }
            else {
                'HTTP_' ~ .name.uc.trans('-' => '_') => .value
            }
        }),
        SERVER_PORT         => $.port,
        SERVER_NAME         => $.host,
        SCRIPT_NAME         => '',
        REQUEST_METHOD      => $.method,
        'p6w.url-scheme'    => $.uri.scheme,
        'p6w.body.encoding' => 'UTF-8',
        'p6w.protocol'      => 'request-response',
        PATH_INFO           => uri-unescape(~$.uri.path),
        QUERY_STRING        => ~$.uri.query // '',
        REQUEST_URI         => ~$.uri,
        ;

    %env;
}

method send(Smack::Client::Request:D: $handle --> Nil) {
    $.headers.Host = $.host if !$.headers.Host && $.host;

    $handle.write: "$.method $.uri $.protocol\r\n".encode("iso-8859-1");
    callsame;
}

multi method gist(Smack::Client::Request:D: --> Str:D) {
    return [~] "$.method $.uri $.protocol\r\n", callsame;
}
