#!/usr/bin/env perl6

use lib <blib lib>;

use Test;
use Flower::TAL;

plan 3;

my $xml = '<?xml version="1.0"?>';

## test 1, basic define and use.

my $template = '<test><zool metal:define-macro="hello">Hello World</zool><zed metal:use-macro="hello">Goodbye Universe</zed></test>';
my $tal = Flower::TAL.new();
$tal.provider.add-path: './t/metal';

is ~$tal.parse($template), $xml~'<test><zool>Hello World</zool><zool>Hello World</zool></test>', 'metal:define-macro and metal:use-macro';

## test 2, using from an external file.

$template = '<test><zed metal:use-macro="common#hello">Say Hi</zed></test>';
is ~$tal.parse($template), $xml~'<test><zool>Hello, World.</zool></test>', 'metal:use-macro with external reference.';

## test 3, slots.

$template = '<test><zed metal:use-macro="common#slotty">A slotty test, <orb metal:fill-slot="booya">Yippie Kai Yay!</orb>.</zed></test>';
is ~$tal.parse($template), $xml~'<test><zarf>It is known, <orb>Yippie Kai Yay!</orb> What do you think?</zarf></test>', 'metal:define-slot and metal:fill-slot';

