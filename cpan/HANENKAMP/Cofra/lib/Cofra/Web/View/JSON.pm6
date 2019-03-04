use v6;

use Cofra::Web::View;

unit class Cofra::Web::View::JSON is Cofra::Web::View;

use JSON::Fast;
use Cofra::Web::Response;

class Instance is Cofra::Web::View::Instance {
    method render($content --> Cofra::Web::Response:D) {
        my $json = $content.&to-json;
        my $bjson = $json.encode('utf8');

        $.response.Content-Type = 'application/json; charset=utf8';
        $.response.Content-Length = $bjson.bytes;

        $.response.body = $bjson;

        $.response;
    }
}

# TODO I hate this. This needs a fix.
method activate(Cofra::Web::Request:D $request --> Cofra::Web::View::JSON::Instance:D) {
    Cofra::Web::View::JSON::Instance.new(view => self, :$request);
}

=begin pod

=head1 NAME

Cofra::Web::View::JSON - render output in JSON

=head1 SYNOPSIS

    unit class MyApp::Web::Controller::Whoohoo is Cofra::Web::Controller;

    method do-it(Cofra::Web::Request:D $req --> Cofra::Web::Response:D) is action {
        $.web.view('JSON').render: %(
            foo => 1,
            bar => 2,
            baz => 3,
        );
    }

=head1 DESCRIPTION

JSON is both cool and popular and, therefore, almost universally hated by the
nerds who write software that read and write it. This view will transform your
data into a JSON serialized form, setup the C<Content-Type> header for you using
L<JSON::Fast> as the actual serializer internally.

=head1 METHDOS

=head2 method activate

Returns a L<Cofra::Web::Veiw::JSON::Instance> object.

=end pod
