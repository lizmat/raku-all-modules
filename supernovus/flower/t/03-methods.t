#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib' }

use Test;
use Flower::TAL;

class Person {
    method talk (*@args) {
        my $name = @args.shift || 'weirdo';
        return "Why are you talking to yourself $name?";
    }
}

plan 2;

my $xml = '<?xml version="1.0"?>';

my $template = "<test><item tal:content=\"self/talk 'Tim'\"/></test>";
my $tal = Flower::TAL.new();

my $person = Person.new;

is ~$tal.parse($template, :self($person)), $xml~'<test><item>Why are you talking to yourself Tim?</item></test>', 'tal:content with method call';

$template = "<test><item tal:content=\"self/talk\"/></test>";
is ~$tal.parse($template, :self($person)), $xml~'<test><item>Why are you talking to yourself weirdo?</item></test>', 'method call with no arguments.';

