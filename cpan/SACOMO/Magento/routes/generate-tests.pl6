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

    # These tests are meant to run against
    # live development system. Do not run
    # this against a production system.

    use Test;
    use lib 'lib', 'xt'.IO.child('lib');

    use Magento::Config;
    use Magento::{$mod_name};
    use {$mod_name};

    my \%config = Magento::Config::from-file config_file => \$*HOME.child('.6mag-testing').child('config.yml');
    END

    my $this_sub_index = 1;

    for sort({ tokenize($^a) gt tokenize($^b) }, lines $routes) -> $line {
        my ($http_method, $route) = ~<< $line.match: / ^ ('GET'|'PUT'|'POST'|'DELETE') \s* (\S*) $ /;
        my @params = $route.split('/')[2..*].grep({ $_ ~~ /':'/});
        push @params, 'search_criteria' when $route ~~ /'search'/;

        # Base subroutine name
        my $sub_name = decamelize (S/'-'$// given $route.split('/')[2..*].grep({ $_ !~~ /':'/}).join('-')), '-';

        # Count all subs that want to use the same name
        my $sub_name_count = @sub_names.grep(/^ $sub_name $/).elems;

        # Use proto for multis with same name
        if $this_sub_index eq 1 {
            push @processed_multis, $sub_name;
            # Start a new subtest
            say "\nsubtest \{";
        }

        # Print the route above the sub definition
        print "\n    # $line";
        print "\n    my \%t{$this_sub_index}_data = {$mod_name}::{$sub_name}();\n" when $http_method ~~ 'POST'|'PUT';
        print "\n    my \$t{$this_sub_index}_results =\n";
        print "        {$sub_name}{'-delete' when $http_method ~~ 'DELETE'} ";
        print "\n            " when @params.elems > 0 || $http_method ~~ 'POST'|'PUT';
        print "\%config{@params.elems > 0 || $http_method ~~ 'POST'|'PUT' ?? ',' !! ''}";
        my $param_max_length =
            (@params.elems > 0
             ?? @params.sort({ $^a.chars > $^b.chars }).head.subst(/':'/, '').chars
             !! 1);
        my $max_space = ($http_method ~~ 'POST'|'PUT' ?? ($param_max_length > 4 ?? $param_max_length !! 4) !! $param_max_length) + 1;
        my @signature = @params.map: -> $p {
             my $param = decamelize (S/':'// given $p), '_';
             my $space = ($param.chars < $max_space ?? $max_space - $param.chars !! 1);
             "        $param" ~ \
            (' ' x ($space eq 0 ?? 1 !! $space)) ~ \
            "=> ''";
        }

        # Add data parameter for POST / PUT tests
        my $space = $max_space > 4 ?? $max_space - 4 !! 1;
        push @signature, "        data" ~ (' ' x ($space <= 0 ?? 1 !! $space)) ~ \
            "=> \%t{$this_sub_index}_data" when $http_method ~~ 'POST'|'PUT';

        print "\n    " ~ @signature.join(",\n") when @signature.elems > 0;
        print ";";
        say "\n    is True, True, '{S/'-'/ / given $sub_name}" ~ \
            do given $http_method {
                when 'GET' {
                    @params.grep(/<[Ii]>'d'/) ?? ' by id' !! ' all';
                }
                when 'POST' {
                    ' new';
                }
                when 'PUT' {
                    ' update';
                }
                when 'DELETE' {
                    ' delete';
                }
            } ~ "';";

        say "\n\}, '{tc S/'-'/ / given $sub_name}';" when $this_sub_index eq $sub_name_count || $sub_name_count eq 0;
        $this_sub_index = $this_sub_index < $sub_name_count ?? ++$this_sub_index !! 1;
    }

    say "\ndone-testing;";
}
