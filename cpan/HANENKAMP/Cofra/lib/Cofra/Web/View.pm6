use v6;

use Cofra::Web::Godly;

unit class Cofra::Web::View does Cofra::Web::Godly;

use Cofra::Web::Request;
use Cofra::Web::Response;

class Instance {
    has Cofra::Web::View $.view is required handles <web>;
    has Cofra::Web::Request $.request is required;
    has Cofra::Web::Response $!response;

    method response(--> Cofra::Web::Response:D) {
        $!response //= $.request.start-response;
    }

    multi method redirect($uri, Bool :$created = False, :$temporary = False --> Cofra::Web::Response:D) {
        my $status = 301;
        if $created { $status = 201 }
        elsif $temporary ~~ Bool { $status = 307 }
        else { $status = +$temporary }

        $.response.status = $status;
        $.response.Content-Length = 0 unless $created;
        $.response.headers.Location = $uri;

        $.response;
    }

    multi method redirect(*%mapping, Bool :$created = False, :$temporary = False --> Cofra::Web::Response:D) {
        self.redirect(
            $.web.path-for(%mapping),
            :$created,
            :$temporary,
        );
    }

    method render(*@_, *%_ --> Cofra::Web::Response:D) { ... }
}

method activate(Cofra::Web::Request:D $request --> Cofra::Web::View::Instance:D) {
    ...
}

=begin pod

=head1 NAME

Cofra::Web::View - the interface for presenting output to web clients

=head1 DESCRIPTION

Views are hard, especially for engineers. In fact, unless your view is just a
storage format like CSV or JSON, you probably don't want engineers having much
to do with your views. I've seen what happens when engineers are involved
several times and it was not pretty in every case, literally. However, this
design will not save you from engineers uglifying your application. Sorry,
you'll have to figure out that on your own.

That this does do is provide an interface for taking the output of your business
logic functions and turn it into some sort of form that can be sent over a
socket connection. Whether that's purely functional or informatically beautiful
depends completely on which view implementation you use (and maybe whether you
let engineers near your presentaiton layer, but I digress, again).

=head1 METHODS

=head2 method activate

    method activate(Cofra::Web::Request:D $request --> Cofra::Web::View::Instance:D)



=end pod
