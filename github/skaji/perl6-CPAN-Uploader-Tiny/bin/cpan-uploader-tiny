#!/usr/bin/env perl6
use v6;
use CPAN::Uploader::Tiny;

sub MAIN($tarball, Str :c(:$config) is copy, Str :s(:$subdirectory) = "Perl6") {
    $config ||= $*HOME.add(".pause").Str;
    my $cpan = CPAN::Uploader::Tiny.new-from-config($config);
    $cpan.upload($tarball, :$subdirectory);
}
