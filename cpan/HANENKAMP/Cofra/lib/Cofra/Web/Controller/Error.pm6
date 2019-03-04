use v6;

use Cofra::Web::Controller;

unit class Cofra::Web::Controller::Error is Cofra::Web::Controller;

use X::Cofra::Web::Error;

method error(Cofra::Web::Request:D $req) is action {
    die X::Cofra::Web::Error.new($.web, $req);
}

method bad-request(Cofra::Web::Request:D $req) is action {
    die X::Cofra::Web::Error::BadRequest.new($.web, $req);
}

method unauthorized(Cofra::Web::Request:D $req) is action {
    die X::Cofra::Web::Error::Unauthorized.new($.web, $req);
}

method forbidden(Cofra::Web::Request:D $req) is action {
    die X::Cofra::Web::Error::Forbidden.new($.web, $req);
}

method not-found(Cofra::Web::Request:D $req) is action {
    die X::Cofra::Web::Error::NotFound.new($.web, $req);
}

=begin pod

=head1 NAME

Cofra::Web::Controller::Error - the very special error controller

=head1 DESCRIPTION

I will document this some other time.

=end pod
