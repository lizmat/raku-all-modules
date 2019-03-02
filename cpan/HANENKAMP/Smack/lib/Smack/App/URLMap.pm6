use v6;

use Smack::Component;

unit class Smack::App::URLMap is Smack::Component;

has Bool $.debug = ?%*ENV<SMACK_URLMAP_DEBUG>;
has @!mapping;

method !add-mount($host, Str() $location is copy, &app) {
    $location ~~ s! "/" $!!;

    with $host {
        push @!mapping, $( "$host", $location, &app );
    }
    else {
        push @!mapping, $( Any, $location, &app );
    }
}

multi method mount(
    Str:D() $path where /^ https? "://" .*? "/" /,
    &app,
) {
    $path ~~ /^
        https? "://"
        $<host>     = [ .*? ]
        $<location> = [ "/" .* ]
    /;

    self!add-mount($<host>, $<location>, &app);
}

multi method mount(
    Str:D() $path where /^ "/" /,
    &app,
) {
    self!add-mount(Any, $path, &app);
}

multi method mount(
    Str:D() $host,
    Str:D() $location where /^ "/" /,
    &app,
) {
    self!add-mount($host, $location, &app);
}

multi method mount(|c) {
    die "Paths need to start with /";
}

method configure(%config) {
    # sort by $host length then $location length
    @!mapping .= sort({ (.[0] ~~ Str ?? .[0].chars !! 0), .[1].chars })
              .= reverse

              # And configure anything internally
              .= map({ (.[0], .[1], .[2].returns ~~ Callable ?? .[2].(%config) !! .[2]) });
}

method call(%env) {
    my $path-info   = %env<PATH_INFO>;
    my $script-name = %env<SCRIPT_NAME> // '';
    my $http-host   = %env<HTTP_HOST>;
    my $server-name = %env<SERVER_NAME>;

    if $http-host and %env<SERVER_PORT> -> $port {
        $http-host ~~ s/":" $port $//;
    }

    for @!mapping -> ($host, $location, &app) {
        my $path = $path-info; # copy

        # Check for matching host and location
        next unless $http-host | $server-name ~~ $host;
        next unless $path.starts-with($location);

        # Pull of the location and make sure this is a valid path
        $path .= substr($location.chars);
        next unless $path eq ''
                 or $path.starts-with('/');

        # MATCHED!

        # Temporarily modify the environment and run the app
        {
            # TODO Use this? When I do this in rakudo-2017.03... it does not
            # work. I guess temp does not survive the transition across
            # threads? If so, the copy I do is the best.
            # temp %env<PATH_INFO>   = $path;
            # temp %env<SCRIPT_NAME> = $script-name ~ $location;
            # return app(%env);
            my %inner-env = %env;
            %inner-env<PATH_INFO>   = $path;
            %inner-env<SCRIPT_NAME> = $script-name ~ $location;
            return app(%inner-env);
        }
    }

    # FAILED!

    404,
    [ Content-Type => 'text/plain' ],
    [ 'Not Found' ]
}
