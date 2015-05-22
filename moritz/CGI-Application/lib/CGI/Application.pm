unit class CGI::Application;

# XXX: should be dump-html
has %.run-modes   is rw = (start => 'dump');
has $.start-mode  is rw = 'start';

has $.mode-param  is rw = 'rm';

has $.error-mode  is rw;

# TODO: type-restrict it to any <header none redirect>
has $.header-type is rw = 'header';
has %.header-props is rw = {};

has $.current-runmode is rw;

has %.callbacks = (
    prerun   => [<prerun>],
    postrun  => [<postrun>],
    error    => [<error>],
    teardown => [<teardown>],
);

# the CGI object or hash
has %.query is rw;


multi method run() {
    my $rm = $.__get_runmode($.mode-param);
    $.current-runmode = $rm;

    # undefine $.__PRERUN_MODE_LOCKED;
    $.call-hook('prerun', $rm);
    # $.__PRERUN_MODE_LOCKED = 1
    # my $prerun-mode = $.prerun-mode;
    # if $prerun-mode {
    #    $rm = $prerun-mode;
    #    $.current-runmode = $rm;
    # }

    my $body = $.__get_body($rm);

    $.call-hook('postrun', $body);

    my $headers = $._send_headers();

    my $output = $headers ~ $body;

    print $output unless $*CGI_APP_RETURN_ONLY || %*ENV<CGI_APP_RETURN_ONLY>;

    $.call-hook('teardown');

    return $output;
}

multi method call-hook($hook, *@args, *%opts) {
    die "Unknown hook ($hook)" unless %.callbacks{$hook};

    my %executed_callback;
    for @( %.callbacks{$hook} ) -> $callback {
        next if %executed_callback{$callback};
        try { self.*"$callback"(|@args, |%opts) };
        %executed_callback{$callback} = 1;
        die "Error executing callback '$callback' in $hook stage: $!" if $!;
    }
    # TODO: callbacks in classes. (blocking on: understanding them first)

}

multi method __get_runmode($rm-param) {
#    warn "In __get_runmode\n";
    my $rm = do given $rm-param {
        when Callable       { .(self)     }
        when Associative    { .<run-mode> }
        default             { %.query{$_} }
    }
#    warn "Run mode (before): $rm.perl()";
    $rm = $.start-mode unless defined($rm) && $rm.chars;
#    warn "Run mode (after): $rm.perl()";
    return $rm;
}

multi method __get_runmeth($rm) {
    my $m = %.run-modes{$rm};
    # TODO: implement AUTOLOAD/CANDO mode
    die "No such run mode '$rm'\n" unless defined $m;
    return $m;
}

multi method __get_body($rm) {
    my $method = $.__get_runmeth($rm);
    my $body;
    try {
        $body = $method ~~ Callable ?? $method() !! self."$method"();
        CATCH {
            default {
                $.call-hook('error', $!);
                if $.error-mode {
                    $body = self."$.error-mode"();
                } else {
                    die "Error executing run mode '$rm': $!";
                }
            }
        }
    }
    return $body;
}

method !header-helper-redirect() {
    return '' unless $.header-type eq 'redirect';
    die "Need a new URL for redirecting" unless %.header-props<url>;
    return    "Status: 302 Found\r\n"
            ~ "Location: %.header-props<url>\r\n";
}

multi method _send_headers() {
    return '' if $.header-type eq 'none';
    # TODO: more general stuff
    return self!header-helper-redirect 
           ~ "Content-Type: text/html\r\n\r\n";
}

multi method dump() {
    [~] gather {
        take "Runmode: '$.current-runmode'\n" if defined $.current-runmode;
        take "Query parameters: %.query.perl()\n";
        # TODO: dump %*ENV
    }
}

# Callbacks, to be overridden if necessary

method prerun(*@args) {
    # do nothing for now.
}
method postrun(*@args) {
    # do nothing for now.
}

method teardown() {};

# vim: ft=perl6
