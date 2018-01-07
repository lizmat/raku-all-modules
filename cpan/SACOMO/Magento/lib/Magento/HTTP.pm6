use v6;

use HTTP::Tinyish;
use JSON::Fast;

unit module Magento::HTTP;

sub format-url(
    Str :$uri,
    Str :$method,
    Str :$store_code  = 'default',
    Str :$host,
    Str :$api_version = 'V1'
) {
    my $prefix = "rest/{$api_version}";
    my $_uri   = do given $store_code {
        when 'default' {
            "{$prefix}/{$uri}";
        }
        default {
            $uri !~~ /'integration'/
            ?? (S/"{$prefix}"/rest\/$store_code\/$api_version/ given $uri)
            !! "{$prefix}/{$uri}";
        }
    }

    return "{$host}/{$_uri.trans: /'['/ => '\\[', /']'/ => '\\]'}";
}

our sub request(
    Hash :$config,
    Str  :$host,
    Str  :$method = 'GET',
    Str  :$uri,
    Str  :$content = '',
    Hash :$headers
    --> Any
) {
    # Config variables
    my $magento_host = $host||$config<host>;
    my $format       = $config<format>||'default';
    my $access_token = $config<access_token>;
    my $store_code   = $config<store>||'default';
    my $api_version  = $config<version>||'V1';
    my $url          = format-url host => $magento_host, :$uri, :$method, :$store_code, :$api_version;

    # Header
    my $content_type = 'application/' ~ ($format ~~ 'default' ?? 'json' !! $format);
    my %request_headers = %{
        Content-Type => $content_type,
        Accept       => $content_type,
        $access_token ?? (Authorization => "Bearer $access_token") !! %(),
        $headers ?? |$headers !! %()
    }

    my %res = do given $method {
        when 'DELETE' {
            HTTP::Tinyish.new.delete:
                $url, headers => %request_headers;
        }
        when 'GET' {
            HTTP::Tinyish.new.get:
                $url, headers => %request_headers;
        }
        when 'POST' {
            HTTP::Tinyish.new.post:
                $url, headers => %request_headers, :$content;
        }
        when 'PUT' {
            HTTP::Tinyish.new.put:
                $url, headers => %request_headers, :$content;
        }
    }

    return do given %res<success> {
        when so * {
            do given $format {
                when 'json'|'xml' {
                    %res<content>;
                }
                default {
                    from-json(%res<content>)||False;
                }
            }
        }
        default {
            %{
                message    => from-json(%res<content>)<message>,
                status     => %res<status>,
                parameters => from-json(%res<content>)<parameters>||%{};
            }
        }
    }
}
