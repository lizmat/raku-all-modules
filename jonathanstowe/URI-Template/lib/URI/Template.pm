use v6.c;

=begin pod

=head1 NAME

URI::Template - implementation of RFC 6570

=head1 SYNOPSIS

=begin code

use URI::Template;

my $template = URI::Template.new(template => 'http://foo.com{/foo,bar}');

say $template.process(foo => 'baz', bar => 'quux'); # http://foo.com/baz/quux

=end code

=head1 DESCRIPTION

This provides an implementation of
L<RFC6570|https://tools.ietf.org/html/rfc6570> which allows for the
definition of a URI through variable expansion. Please refer to the
specification for full details of the template expansion.

=head2 Overview of templates

A URI template comprises a string representing a full or partial URI
containing on or more template expressions.  A template expression
is delimited by curly braces ('{', '}',) and may contain one or more
variable names to be expanded separated by commas.  The variables may
be qualified by either an integer maximum length (separated from the
variable name by a ':',) or by a '*' that indicates that aggregate
values should be 'exploded', (how this explosion manifests in detail
depends on the expression 'operator' and is described in the specification.)

The expression can be modified with an optional 'operator' which should be
supplied immediately after the opening '{', the operator may modify the
way in which the values of the variables are encoded, the way that multiple
variables are joined in the same expression and the way in which aggregate
variable values are expanded.

The operators and their general meaning are thus:

=begin code

      +   Reserved character strings;

      #   Fragment identifiers prefixed by "#";

      .   Name labels or extensions prefixed by ".";

      /   Path segments prefixed by "/";

      ;   Path parameter name or name=value pairs prefixed by ";";

      ?   Query component beginning with "?" and consisting of
          name=value pairs separated by "&"; and,

      &   Continuation of query-style &name=value pairs within
          a literal query component.

=end code

=head1 METHODS

=head2 method new
    
    method new(Str :$template) returns URI::Template

The constructor of the class.  The C<$template> must be a valid URI template if
it is provided.  If it is not provided to the constructor then it must be provided
by setting the attribute accessor before C<process> is called.

=head2 method process

    method process(*%variables) returns Str

Expand the template with the values of the template variables specified as named
arguments.  If no C<template> has been provided then a C<X::NoTemplate> exception
will be thrown.  If the provided template is unable to be parsed then a
C<X::InvalidTemplate> exception will be thrown.

=head2 method template

    method template() returns Str is rw

A read/write public accessor for the template.  If this parameter is not set by
the accessor it must be set using C<template> before C<process> is called.

Because of the way the template is parsed it will only be done once for any 
given C<URI::Template> object, so setting this after C<process> has been called
for the first time will have no effect.  If you need a different template it is
recommended to use a different object.


=end pod

class URI::Template:ver<0.0.5>:auth<github:jonathanstowe> {

    has Str $.template is rw;

    # this holds the parsed parts
    has @.parts;


    #| Simply a marker to indicate whether encoding need happen
    my role PreEncoded {
    }

    #| Mark that we don't need the name expansion
    my role PreExploded {
    }

    class Variable {
        has Str $.name;
        has Int $.max-length;
        has Bool $.explode;

        method get-value(Str $operator, %vars) returns Str {
            my Str $value;

            if %vars{$!name}:exists {
                $value = self.expand-value($operator, %vars{$!name});

            }

            $value;
        }

        multi method expand-value(Str $operator, Any:U $) {
            Str;
        }

        multi method expand-value(Str $operator, Numeric:D $value) {
            self.expand-value($operator, $value.Str);
        }
        multi method expand-value(Str $operator, Str $value) {
            my Str $exp-value;


            if $!max-length {
                $exp-value = $value.substr(0, $!max-length);
            }
            else {
                $exp-value = $value;
            }
            $exp-value;
        }

        multi method expand-value(Str $operator, @value) {

            if @value.elems {
                my $joiner = self!get-joiner($operator);
                my &exp = self!get-exploder($operator);
                my Str $exp-value = @value.map(&uri-encode-component).map(&exp).join($joiner);
    
                $exp-value does PreEncoded;
                if self!was-exploded($operator) {
                    $exp-value does PreExploded;
                }

                return $exp-value;
            }
            else {
                Nil;
            }
        }

        method !was-exploded(Str $operator) returns Bool {
            my Bool $ret = False;
            if $operator.defined {
                if self.explode {
                    if $operator ~~ any(<& ? ;>) {
                        $ret = True;
                    }
                }
            }
            $ret;
        }

        #! return a closure to handle the array explosion
        method !get-exploder(Str $operator) returns Callable {

            my &exp =  sub ( $val ) {
                my $exp-val = $val;
                if $operator.defined {
                    if self.explode {
                        if $operator ~~ any(<& ? ;>) {
                            $exp-val = self.name ~ "=" ~ $exp-val;
                            $exp-val does PreExploded;
                        }
                    }
                }
                $exp-val;
            }
            &exp;
        }

        multi method expand-value(Str $operator, %value) {

            if ?%value.keys {
                my Str $res;
                my $joiner = self!get-joiner($operator);
                my &enc = self!get-hash-encoder($operator);
                if self.explode {
                    $res = %value.kv.map({.Str}).map(&enc).map( -> $k, $v { "$k=$v"}).join($joiner);
                    $res does PreExploded;
                }
                else {
                    $res = %value.kv.map({.Str}).map(&enc).join($joiner);
                }

                $res does PreEncoded;

                $res;
            }
            else {
                Nil;
            }

        }

        #| lookup for the joiners
        my %joiners = (
                        '+'  =>     ",",
                        '#'  =>     ",",
                        '.'  =>     ".",
                        '/'  =>     "/",
                        ';'  =>     ";",
                        '?'  =>     "&",
                        '&'  =>     "&" ,
        );

        #| Get the appropriate character to join elements
        method !get-joiner(Str $operator) returns Str {
            my $joiner = self.explode ?? $operator.defined ?? %joiners{$operator} !! ',' !! ',';
            $joiner;
        }

        my &enc = sub ($m) {
            $m.Str.encode.list.map({.fmt('%%%02X')}).join('')
        }

        my sub uri-encode (Str:D $text)
        {
            return $text.subst(/<[\x00..\x10ffff]-[a..zA..Z0..9_.~\!\+\-\#\$\&\+,\/\:;\=\?@]>/, &enc, :g);
        }

        my sub uri-encode-component (Str:D $text)
        {
            return $text.subst(/<[\x00..\x10ffff]-[a..zA..Z0..9_.~\-]>/, &enc, :g);
        }

        #| Returns the appropriate encoding sub for the operator
        method !get-encoder(Str $operator) returns Callable {
            my &encoder = do if $operator.defined {
                given $operator {
                    when /<[\+\#\;\.]>/ {
                        &uri-encode;
                    }
                    default {
                        &uri-encode-component;
                    }
                }
            }
            else {
                &uri-encode-component;
            }
            &encoder;
        }

        #| Returns the appropriate encoding sub for the operator
        #| this is special for the hash case for the time being
        method !get-hash-encoder(Str $operator) returns Callable {
            my &encoder = do if $operator.defined {
                given $operator {
                    when /<[\+\#]>/ {
                        &uri-encode;
                    }
                    default {
                        &uri-encode-component;
                    }
                }
            }
            else {
                &uri-encode-component;
            }
            &encoder;
        }

        #| encode the string if it it needed
        method !encode-expanded(Str $operator, Str $value) returns Str {
            my $res = do if $value ~~ PreEncoded {
                $value;
            }
            else {
                self!get-encoder($operator).($value);
            }

            $res;
        }

        multi method process(Str $operator, %vars) {
            my $res;

            my $val = self.get-value($operator, %vars);
            if $val {
                if $val !~~ PreExploded {
                    my $eq = $operator.defined && $operator eq ';' ?? '=' !! '';
                    $res = (self!get-primer($operator) // '') ~ $eq;
                }
                $res ~= self!encode-expanded($operator, $val);
            } 
            elsif $val.defined {
               $res = self!get-primer($operator);
            }
            else {
                $res = Nil;
            }
            $res;
        }

        method !get-primer(Str $operator) returns Str {
            my Str $primer = do given $operator {
                when '&' {
                    $!name ~ '=';
                }
                when '?' {
                    $!name ~ '=';
                }
                when ';' {
                    $!name;
                }
                default {
                    Str;
                }
            }
            $primer;
        }

    }

    sub get-joiner(Str $operator) {
        my $joiner = do given $operator {
            when '/' {
                '/';
            }
            when '&' {
                '&';
            }
            when '?' {
                '&';
            }
            when '.' {
                '.';
            }
            when ';' {
                ';';
            }
            default {
                ',';
            }
        }

        $joiner;

    }

    class Expression {
        has $.operator;
        has Variable @.variables;

        method process(%vars) returns Str {
            my Str $str;

            my @processed-bits = ();

            for self.variables -> $variable {
               @processed-bits.push($variable.process($!operator, %vars));
            }

            my $joiner = get-joiner($!operator);

            my &filter = self!get-part-filter;

            my $show-op = self!show-operator(@processed-bits);

            $str = @processed-bits.grep(&filter).map({ $_ // ''}).join($joiner);

            if $!operator.defined && $!operator ne '+' && $str.defined {
                $str = ($show-op ?? $!operator !! '') ~ $str;
            }

            $str;
        }

        method !show-operator(@bits) {
            my &pc = self!get-part-filter;
            return ?@bits.grep(&pc);
        }

        # This is a bit hacky but adjusting to match the spec
        method !get-part-filter() {
            sub ( $value ) {
                my Bool $rc;
                if $!operator.defined && $!operator eq '#' {
                    $rc = $value ~~ Str;
                }
                else {
                    $rc = $value ~~ Str;
                }
                $rc;
            }
        }

    }

    has Grammar $.grammar = our grammar Grammar {
        rule TOP {
            <bits>* [ <expression>+ ]* %% <bits>+ 
        }

        token bits { <-[{]>+ }

        regex expression {
            '{' <operator>? <variable>+ % ',' '}'
        }

        regex operator {
            <reserved>          || 
            <fragment>          || 
            <label-dot>         || 
            <path-slash>        ||
            <path-semicolon>    ||
            <form-ampersand>    ||
            <form-continuation>


        }

        token reserved {
            '+'
        }
        token fragment {
            '#'
        }

        token label-dot {
            '.'
        }

        token path-slash {
            '/'
        }

        token path-semicolon {
            ';'
        }

        token form-ampersand {
            '?'
        }

        token form-continuation {
            '&'
        }

        regex variable {
            <variable-name><var-modifier>?
        }
        regex variable-name {
             <-[\s,\:\*\}]>+
        }

        rule var-modifier {
            <explode> || <prefix>
        }

        token explode {
            '*'
        }
        token prefix {
            ':' <max-length>
        }
        token max-length {
            \d+
        }
    }

    our class Actions {

        has @.PARTS = ();
        has Match $!last-bit;

        method TOP($/) {
            $/.make(@!PARTS);
        }

        method bits($/) {
            # This shouldn't be necessary but I can't work out why
            # the last bit is duplicated
            if !$!last-bit.defined || $/.from  != $!last-bit.from {
                @!PARTS.push($/.Str);
            }
            $!last-bit = $/;
        }

        method expression($/) {
            my $operator =  $/<operator>.defined ?? $/<operator>.Str !! Str;
            my @variables = $/<variable>.list.map({ $_.made }); 
            @!PARTS.push(Expression.new(:$operator, :@variables));
        }

        method variable($/) {

            my Str $name = $/<variable-name>.Str;
            my Int $max-length;
            my Bool $explode = False;

            my $vm = $/<var-modifier>;

            if $vm.defined {
                $max-length = $vm<prefix><max-length>.defined ?? $vm<prefix><max-length>.Int !! Int;
                $explode = $vm<explode>.defined;
            }
            $/.make(Variable.new(:$name, :$max-length, :$explode));
        }

    }

    #| thrown when no template
    class X::NoTemplate is Exception {
        has $.message = "Template is not defined";
    }

    #| thrown when template can't be parsed
    class X::InvalidTemplate is Exception {
        has $.message = "Invalid or un-parseable template";
    }

    #| accessor for the parsed parts of the template
    #| forces it to be made if it hasn't been already
    method parts() {
        if not @!parts.elems {

            if $!template.defined {

            
                my $actions = Actions.new;

                my $match = URI::Template::Grammar.parse($!template, :$actions);

                if $match {
                    @!parts = $match.made;
                }
                else {
                    X::InvalidTemplate.new.throw;
                }
            }
            else {
                X::NoTemplate.new.throw;
            }
        }
        @!parts;
    }

    method process(*%vars) returns Str {
        my Str $string;

        for self.parts -> $part {
            given $part {
                when Str {
                    $string ~= $part
                }
                when Expression {
                    $string ~= $part.process(%vars);
                }
                default {
                    die "Unexpected object of type { $part.WHAT.name } found in parsed template";

                }
            }
        }

        $string;
    }


}
# vim: expandtab shiftwidth=4 ft=perl6
