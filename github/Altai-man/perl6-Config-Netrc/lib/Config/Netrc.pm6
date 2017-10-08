use v6;

unit module Config::Netrc;

grammar Netrc {
    token TOP {
        ^
        [<line-comment>|<entry>|<eol>]*?
        $
    }
    token eol          { \n                                            }
    token line-comment { \h* '#' $<line-comment> = [.*?] \n            }
    token comment      { \h* '#' [\h|\w|'-']*                          }
    token entry        { [<machine>|<default>] \s*?
                         <login>?              \s*?
                         <password>?           \n?                     }
    token machine      { \h*? 'machine'  \h+? (\w+) (<comment>?) <eol> }
    token default      { \h*? 'default'  \h*?       (<comment>?) <eol> }
    token login        { \h*? 'login'    \h+? (\w+) (<comment>?) <eol> }
    token password     { \h*? 'password' \h+? (\w+) (<comment>?) <eol> }
}

sub construct($/) {
    if $<machine>.defined {
        return {machine  => $<machine>.made,
                login    => $<login>.made,
                password => $<password>.made}
    } else {
        return {default  => Any,
                login    => $<login>.made,
                password => $<password>.made}
    }
}

sub comment-layering($/) {
    if not ~$1 eq '' {
        return {value => ~$0.trim, comment => ~$1.trim};
    } else {
        return {value => ~$0.trim}
    }
}

sub sorting($/) {
    my %hash;
    for ($/.kv) -> $elem {
        if $elem<line-comment>.defined {
            %hash<comments>.push(~$elem<line-comment>);
        }
        if $elem<machine>.defined || $elem<default> {
            %hash<entries>.push: construct($elem);
        }
    }
    %hash;
}

class Netrc::Actions {
    method TOP ($/) { $/.make: sorting($/)        }
    method line-comment ($/) { $/.make: ~$/.trim; }
    method entry    ($/) { $/.make: construct($/) }
    method machine  ($/) { $/.make: comment-layering($/); }
    method login    ($/) { $/.make: comment-layering($/); }
    method password ($/) { $/.make: comment-layering($/); }

}

our sub parse(Str $string) is export {
    Netrc.parse($string, :actions(Netrc::Actions.new)).made;
}

our sub parse-file(Str $fn) is export {
    my $text = slurp $fn;
    Netrc.parse($text, :actions(Netrc::Actions.new)).made;
}

# =begin pod
# =head1 NAME
# Config::Netrc - parse Netrc configuration files
# =head1 SYNOPSIS
#     use Config::Netrc;
#     my %hash = Config::Netrc::parse-file('config.netrc');
#     #or
#     %hash = Config::Netrc::parse($file_contents);
#     say %hash<comments>[0];
#     say %hash<entries>[0]<machine><value>;
#     say %hash<entries>[5]<default><comment>;
# =head1 DESCRIPTION
# This module provides 2 functions: parse() and parse-file(), both taking
# one C<Str> argument, where parse-file is just parse(slurp $file).
# Both return a hash which contains all structure of configuration file.
# For example, the following config file:
#      # this is my netrc with default
#      machine m
#      login l # this is my username
#      password p
#
#      default
#      login default_login # this is my default username
#      password default_password
# would result in the following hash:
# {comments => [ this is my netrc with default],
#  entries => [{login    => {comment => # this is my username, value => l},
#               machine  => {value => m},
#               password => {value => p}}
#              {default => (Any),
#               login => {comment => # this is my default username,
#               value => default_login},
#               password => {value => default_password}}]}
# =end pod
