use v6;

unit module Config::INI;

grammar INI {
    token TOP      { 
                        ^
                        <.eol>*
                        <toplevel>?
                        <sections>* 
                        <.eol>*
                        $
                   }
    token toplevel { <keyval>* }
    token sections { <header> <keyval>* }
    token header   { ^^ \h* '[' ~ ']' $<text>=<-[ \] \n ]>+ \h* <.eol>+ }
    token keyval   { ^^ \h* <key> \h* '=' \h* <value>? \h* <.eol>+ }
    regex key      { <![\[]> <-[;=]>+ }
    regex value    { [ <![;]> \N ]+ }
    # TODO: This should be just overriden \n once Rakudo implements it
    token eol      { [ ';' \N+ ]? \n }
}

class INI::Actions {
    method TOP ($/) { 
        my %hash = $<sections>».ast;
        %hash<_> = $<toplevel>.ast.hash if $<toplevel>.?ast;
        make %hash;
    }
    method toplevel ($/) { make $<keyval>».ast.hash }
    method sections ($/) { make $<header><text>.Str => $<keyval>».ast.hash }
    # TODO: The .trim is useless, <!after \h> should be added to key regex,
    # once Rakudo implements it
    method keyval ($/) { make $<key>.Str.trim => $<value>.Str.trim }
}

our sub parse (Str $string) {
    INI.parse($string, :actions(INI::Actions.new)).ast;
}

our sub parse_file (Str $file) {
    my $conf = slurp $file;
    my $parseconf = 0;
    my %result;
    try {
        %result = parse $conf;
        CATCH {
            $parseconf = 1
        }
    }
    if $parseconf {
        die "Failed parsing $file"
    }
    return %result
}

=begin pod

=head1 NAME

Config::INI - parse standard configuration files (.ini files)

=head1 SYNOPSIS

    use Config::INI;
    my %hash = Config::INI::parse_file('config.ini');
    #or
    %hash = Config::INI::parse($file_contents);
    say %hash<_><root_property_key>;
    say %hash<section><in_section_key>;

=head1 DESCRIPTION

This module provides 2 functions: parse() and parse_file(), both taking
one C<Str> argument, where parse_file is just parse(slurp $file).
Both return a hash which keys are either toplevel keys or a section
names. For example, the following config file:

    foo=bar
    [section]
    another=thing

would result in the following hash:

    { '_' => { foo => "bar" }, section => { another => "thing" } }

=end pod

# vim: ft=perl6
