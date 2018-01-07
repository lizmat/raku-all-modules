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

    # Track multis
    my @processed_multis;

    # Module header
    say qq:to/END/;
    use v6;

    use Magento::HTTP;
    use Magento::Utils;
    use JSON::Fast;

    unit module Magento::{$mod_name};
    END

    for sort({ tokenize($^a) gt tokenize($^b) }, lines $routes) -> $line {
        my ($http_method, $route) = ~<< $line.match: / ^ ('GET'|'PUT'|'POST'|'DELETE') \s* (\S*) $ /;
        my @params = $route.split('/')[2..*].grep({ $_ ~~ /':'/});
        push @params, 'search_criteria = %{}' when $route ~~ /'search'/;

        # Base subroutine name
        my $sub_name = decamelize (S/'-'$// given $route.split('/')[2..*].grep({ $_ !~~ /':'/}).join('-')), '-';

        # Count all subs that want to use the same name
        my $sub_name_count = @sub_names.grep(/^ $sub_name $/).elems;

        # Use proto for multis with same name
        if $sub_name_count > 1 && @processed_multis !(cont) $sub_name {
            push @processed_multis, $sub_name;
            # Define multi if not single sub
            say "proto sub {$sub_name}(|) is export \{*\}";
        }

        # Print the route above the sub definition
        print "# $line";

        # Define sub if not multi
        print "\nour {$sub_name_count > 1 && $http_method !~~ 'DELETE' ?? 'multi' !! 'sub'} {$sub_name}{'-delete' when $http_method ~~ 'DELETE'}(";

        # All routines have a $config
        print "\n    Hash \$config" ~ (@params.elems > 0 || $http_method ~~ 'POST'|'PUT' ?? ',' !! '');

        # Newline when we need to add params
        print "\n" when @params.elems > 0;

        # Loop params and format
        @params.map({
            '    ' ~ \
            do (if $_ ~~ /<[Ii]>'d'$/ {
                "Int ";
            } elsif $_ ~~ /'search_criteria'/ {
                "Hash";
            } else {
                "Str ";
            }) ~ " :\${ decamelize (S/':'// given $_), '_' }" ~ \
                ('!' when $route !~~ /'search'/)
        }).join(",\n").print;

        # Add comma / newline before data Hash parameter
        print ",\n" when $http_method ~~ 'POST'|'PUT' && @params.elems > 0;

        # Add $data param if POST or PUT
        print ("\n" when @params.elems eq 0) ~ "    Hash :\$data!" when $http_method ~~ 'POST'|'PUT';

        # Close signature and add 'is export' if single sub
        print "\n)" ~ ($sub_name_count eq 1 || $http_method ~~ 'DELETE' ?? ' is export' !! '')  ~ " \{\n"; 

        # Add query string parsing if search capable routine
        print "    my \$query_string = search-criteria-to-query-string \$search_criteria;\n" when $route ~~ /'search'/;

        # Reformat the query string to use the correct p6 variable format
        my $route_formatted = S/'/V1/'// given $route;
        for @params -> $p {
            my $param = "\${ decamelize (S/':'// given $p), '_' }";
            $route_formatted = S/$p/$param/ given $route_formatted;
        }

        # Build the request
        print qq:to/END/;
            Magento::HTTP::request
                method  => '$http_method',
                config  => \$config,
                uri     => "{$route_formatted}{"?\$query_string" when $route ~~ /'search'/}"{",\n        content => to-json \$data" when $http_method ~~ 'POST'|'PUT'};
        END

        # Close the routine
        print "\}\n\n";
    }
}
