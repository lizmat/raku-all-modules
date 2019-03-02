use v6;

unit class Smack::Response;

use HTTP::Headers;

class X::Smack::Response::MissingStatus is Exception {
    method message() { "missing status during finalize" }
}

has Int $.status is rw;
has HTTP::Headers $.headers handles <header Content-Length Content-Type> = HTTP::Headers.new;
has @.body = [];

multi method redirect(Smack::Response:D: Str $location, :$status = 302) {
    $!status = $status;
    self.headers.Location = $location;
}

multi method redirect(Smack::Response:D:) {
    self.headers.Location
}

method finalize(Smack::Response:D:) {
    die X::Smack::Response::MissingStatus.new
        unless $!status.defined;

    my @headers = $!headers.for-P6WAPI;

    return [
        $!status,
        @headers.item,
        @!body.item
    ];
}

method to-app {
    my $self = self;
    sub { $self.finalize }
}
