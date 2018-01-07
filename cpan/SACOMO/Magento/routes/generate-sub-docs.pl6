#!/usr/bin/env perl6

use v6;

use HTTP::Tinyish;
use JSON::Fast;
use String::CamelCase;

sub nowrap($str) {
    "<div style='white-space: nowrap;'>{$str}</div>";
}

sub MAIN(:$ver = '2.2') {

    my $testing_dir    = $*HOME.child('.6mag-testing');
    my $latest_schema  = $testing_dir.child('latest-schema.json');

    my $api_schema_raw = do if $testing_dir.child('latest-schema.json').IO.f {
        # Cached schema exists
        slurp $latest_schema;
    } else {
        # Cached schema missing, pull from API docs and cache
        my $schema = HTTP::Tinyish.new.get("http://devdocs.magento.com/swagger/schemas/latest-{$ver}.schema.json")<content>;
        spurt $latest_schema, $schema andthen $schema;
    }

    # Load schema
    my %schema = from-json($api_schema_raw)<paths>;

    # Parse each module pm6 and print
    dir('lib'.IO.child('Magento')).sort.map: -> $file {
        next if $file.path ~~ / 'Auth'|'CLI'|'Config'|'HTTP'|'Utils' /;
        my $module_name = S/ '.'\S* $ // given $file.basename;

        # Section header
        say "## Magento::{$module_name}";

        my $module_raw = slurp $file;
        # Extract subroutine annotation, signature, name, http method
        my @routines = $module_raw.\
            match: / [ '#' \s* ] ( \S* ) \s* ( \S* ) \v 'our ' \S* \s* (\S*) '(' \v ( .*? <-[\)]> ) [ \v ')' ] /, :g;

        # Table header
        say "|Subroutine" ~ \
            "|Parameters" ~ \
            "|Description" ~ \
            "|HTTP<br/>Method" ~ \
            "|Path" ~ \
            "|\n|:---|:---|:---|:---|:---|";

        # Row details
        for @routines -> $details {
            my ($http_method, $path, $subname, $signature ) = ~<< $details;
            my $alt_path = $path;

            # Create alternative path name: :id vs {id}
            $path.split('/')[2..*].grep({ $_ ~~ /':'/}).map: -> $opt {
                my $p6var = S/':'// given $opt;
                my $alt_opt = "\{$p6var\}";
                $alt_path = S/ $opt /{$alt_opt}/ given $alt_path;
            }

            next unless %schema{$alt_path} || %schema{$path};

            my %path_data = do if %schema{$alt_path}.defined {
                %schema{$alt_path}
            } else {
                %schema{$path};
            }

            next unless %path_data && %path_data{$http_method.lc};

			my %endpoint = %path_data{$http_method.lc};

			my $description = do given $subname {
                when 'integration-token' {
                    'Create access token user given the admin / customer credentials.'
                }
                default {
                    %endpoint<description>
                }
            }

			$path = do given $subname {
                when 'integration-token' {
                    '/V1/integration/[admin\\|customer]/token'
                }
                default {
                    $path
                }
            }

            # Print row
			say "|{nowrap $subname}" ~ \
				"|{nowrap S:g/\n/<br\/>/ given $signature}" ~ \
				"|{$description}" ~ \
				"|{$http_method}" ~ \
				"|{nowrap $path}|";

        }
    }
}
