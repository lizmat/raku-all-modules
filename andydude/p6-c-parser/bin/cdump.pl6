#!/usr/bin/env perl6
use v6;
use lib 'lib';
use C::Parser::Actions;
use C::Parser::Lexer;
use C::Parser::Grammar;
use C::Parser::Utils;

sub MAIN (Str $input = "-",
#    Str :$output = "-",
#    Str :$inlang = "c11",
    Str :$oformat = "nil",
    Str :$actions = "nil",
#    Bool :$preproc = False,
    Bool :$lexonly = False,
    Bool :$verbose = False)
{
    my Str $source = ($input eq "-") ?? slurp("/dev/stdin") !! slurp($input);
    my $parser = $lexonly ?? C::Parser::Lexer !! C::Parser::Grammar;
    my $ast;

    #if $preproc {
    #    # preprocess
    #}

    say "--- Input" if $verbose;
    say $source if $verbose;
    
    given $actions {
        when "nil" {
            $ast = $parser.parse($source);
        }
        when "cast" {
            my $actions = C::Parser::Actions.new();
            $ast = $parser.parse($source, :$actions);
        }
        default {
            die "unknown \$actions, must be one of: nil, cast."
        }
    }

    if $ast.WHAT.perl eq 'Any' {
        say "--- Error" if $verbose;
        die "parse failed";
    }
    
    given $oformat {
        when "nil" {
            say "--- Output" if $verbose;
            say $ast;
        }
        when "ast" {
            say "--- Output" if $verbose;
            my $out = C::Parser::Utils::fake_indent($ast.ast.perl);
            say $out;
        }
        when "str" {
            say "--- Output" if $verbose;
            say $ast.Str;
        }
        when "perl" {
            say "--- Output" if $verbose;
            say $ast.perl;
        }
        default {
            say $ast;
            die "unknown \$oformat, must be one of: nil, str, perl."
        }
    }
    
    return 0;
}

Nil