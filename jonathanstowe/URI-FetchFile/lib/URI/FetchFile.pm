use v6.c;

use File::Which;

=begin pod

=head1 NAME

URI::FetchFile - retrieve a file from the internet by any means necessary

=head1 SYNOPSIS

=begin code

use URI::FetchFile;

if fetch-uri('http://rakudo.org/downloads/star/rakudo-star-2016.10.tar.gz', 'rakudo-star-2016.10.tar.gz') {
    # do something with the file
}
else {
    die "couldn't get file";
}

=end code

=head1 DESCRIPTION

This provides a simple method of retrieving a single file via HTTP using the
best available method whilst trying to limit the dependencies.

It is intended to be used by installers or builders that may need to retrieve
a file but otherwise have no need for an HTTP client.

It will try to use the first available method from:

=item HTTP::UserAgent

=item LWP::Simple

=item curl

=item wget

Failing with a C<X::NoProvider> if it can't use any of them.


=head1 ROUTINES

=head2 sub fetch-uri

    sub fetch-uri(Str $uri, Str $file ) returns Bool is export(:DEFAULT)

This will attempt to get the resource identified by URI and save the
returned resource in the specified $file.  If the resource cannot be
retrieved then this will return False (and the file won't be created.)
If none of the providers are available an exception will be thrown.

=end pod

class URI::FetchFile {

    role Provider {
        method fetch(Provider:U: :$uri, :$file) returns Bool {
            ...
        }

        method is-available() returns Bool {
            ...
        }
    }

    role Class[Str $class-name] {
        my $type;
        method class-name() returns Str {
            $class-name;
        }

        my Bool $tried = False;

        method type() {
            if ! $tried {
                $type = try require ::($class-name);
            }
            $type;
        }

        method is-available() returns Bool {
            not $.type === Any;
        }
    }

    class Provider::LWP::Simple does Class['LWP::Simple'] does Provider {
        method fetch(:$uri, :$file) returns Bool {
            my Bool $rc = False;

            if $.is-available {
                $rc = $.type.getstore($uri, $file);
            }
            $rc;
        }
    }

    class Provider::HTTP::UserAgent does Class['HTTP::UserAgent'] does Provider {
        method fetch(:$uri, :$file) returns Bool {
            my Bool $rc = False;
            if $.is-available {
	            my $res =  $.type.new.get($uri);
	            if $res.is-success {
		            my $out = $file.IO.open(:w);
		            if $res.is-binary {
			            $out.write: $res.content;
		            }
		            else {
			            $out.print: $res.content;
		            }
		            $out.close;
                    $rc = True;
	            }
            }
            $rc;
        }
    }

    role Executable[Str $executable-name] {

        my Str $executable;

        method executable-name() returns Str {
            $executable-name;
        }

        method executable() returns Str {
            if ! $executable.defined {
                $executable = which($executable-name);
            }
            $executable;
        }

        method is-available() returns Bool {
            so $.executable;
        }

    }

    class Provider::Curl does Executable['curl'] does Provider {
        method fetch(:$uri, :$file) returns Bool {
            my $rc = False;
            if $.is-available {
                my $p = run($.executable,'-f', '-s', '-o', $file, $uri );
                if !$p.exitcode {
                    $rc = True;
                }
            }
            return $rc;
        }
    }

    class Provider::Wget does Executable['wget'] does Provider {
        method fetch(:$uri, :$file) returns Bool {
            my $rc = False;
            if $.is-available {
                my $p = run($.executable,'-q', '-O', $file, $uri );
                if !$p.exitcode {
                    $rc = True;
                }
                else {
                    # wget will create the file even if it doesn't retrieve anything
                    $file.IO.unlink if $file.IO.e;
                }
            }
            return $rc;
        }
    }

    class X::NoProvider is Exception {
        method message() returns Str {
            "No working provider can be found to fetch file";
        }
    }

    my @providers = (Provider::HTTP::UserAgent, Provider::LWP::Simple, Provider::Curl, Provider::Wget);

    method set-providers(*@new-providers) {
        @providers = @new-providers.grep(Provider);
    }

    sub fetch-uri(Str $uri, Str $file ) returns Bool is export(:DEFAULT) {
        my Bool $rc = False;

        my Int $tried = 0;
        for @providers -> $provider {
            if $provider.is-available {
                $rc = $provider.fetch(:$uri, :$file);
                last;
            }
            else {
                $tried++;
            }
        }
        if $tried == @providers.elems {
            X::NoProvider.new.throw;
        }
        $rc;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
