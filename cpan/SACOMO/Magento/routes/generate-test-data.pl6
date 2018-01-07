#!/usr/bin/env perl6

use v6;
use String::CamelCase;
use lib 'lib';
use Magento::Utils;

sub MAIN($mod_name) {

    die 'Please provide a module name' unless $mod_name;

    my $routes = slurp("routes/$mod_name");

    # Gather all subnames
    my @sub_names = $routes.lines.map(-> $line {
        decamelize (S/'-'$// given $line.match(/^ \S* \s* (\S*) $/).Str.split('/')[2..*].grep({ $_ !~~ /':'/}).join('-')), '-';
    });

    # Track subs
    my @processed_subs;

    # Module header
    say qq:to/END/;
    use v6;
    use Base64;

    unit module {$mod_name};
    END

    for sort({ tokenize($^a) gt tokenize($^b) }, lines $routes) -> $line {
        my ($http_method, $route) = ~<< $line.match: / ^ ('GET'|'PUT'|'POST'|'DELETE') \s* (\S*) $ /;

        # Base subroutine name
        my $sub_name = decamelize (S/'-'$// given $route.split('/')[2..*].grep({ $_ !~~ /':'/}).join('-')), '-';
        next when @processed_subs (cont) $sub_name || $http_method ~~ 'DELETE'|'GET';

        say qq:to/END/;
        our sub {$sub_name} \{
            %();
        \}
        END

        push @processed_subs, $sub_name;
    }
}
