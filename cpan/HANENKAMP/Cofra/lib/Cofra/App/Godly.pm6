use v6;

unit role Cofra::App::Godly;

use Cofra::AppObject;

has Cofra::AppObject $.app is rw handles <logger biz>;

=begin pod

=head1 NAME

Cofra::App::Godly - clearly identifies anything that needs access to the God object

=head1 SYNOPSIS

    use Cofra::App::Godly;

    unit class MyApp::Widget does Cofra::App::Godly;

=head1 DESCRIPTION

Any object that requires a reference to the main application God object should
be clearly declared this way. That way you know where all the religious nut
classes are within your application.

=end pod
