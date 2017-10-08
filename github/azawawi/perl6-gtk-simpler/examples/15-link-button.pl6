#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => 'Link Button Demo');

my $link1-button = link-button(:label("Perl 6"),
    :uri("http://perl6.org"));
my $link2-button = link-button(:label("Perl 6 Docs"),
    :uri("http://doc.perl6.org"));
my $text-view   = text-view;

$link1-button.activate-link.tap: {
    $text-view.text ~= sprintf("activate-link %s triggered, visited=%s\n",
        $link1-button.uri, $link1-button.visited);
}

$link2-button.activate-link.tap: {
    $text-view.text ~= sprintf("activate-link %s triggered, visited=%s\n",
        $link2-button.uri, $link2-button.visited);
}

$app.set-content(
    vbox([
        { :widget($link1-button), :expand(False) },
        { :widget($link2-button), :expand(False) },
        $text-view,
    ])
);

$app.border-width = 20;
$app.run;
