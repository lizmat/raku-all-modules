use v6;

use Cofra::WebObject;

role Cofra::Web::Godly {
    has Cofra::WebObject $.web is rw handles <app>;
}

=begin pod

=head1 NAME

Cofra::Web::Godly - clearly identifies anything that needs access to the web-application God object

=head1 SYNOPSIS

    use Cofra::Web::Godly;

    unit class MyApp::Web::Widget does Cofra::Web::Godly;

=head1 DESCRIPTION

This framework might appear to be polytheistic, but it probably isn't. Maybe
it's henotheistic? I'm not really sure yet. I told you it was eccentric,
assuming you read all the documentation from the beginning I started with when I
ran C<vim lib/**/*.pm> this evening.

However, there's definitely more than one way to be godly, which certainly seems
very Perlish.

=end pod
