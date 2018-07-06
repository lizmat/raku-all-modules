use Cookie::Baker;
use Hematite::Context;

unit class Hematite::Handler does Callable;

has $.app;
has Callable $.stack;

method CALL-ME(Hash $env) {
    my $context_class = self.app.config{'context_class'};
    if (!$context_class.isa(Hematite::Context)) {
        $context_class = Hematite::Context;
    }

    my Hematite::Context $ctx = $context_class.new(self.app, $env);

    try {
        # call middleware stack
        self.stack.($ctx);

        CATCH {
            my Exception $ex = $_;

            default {
                $ctx.handle-error($ex);
            }
        }
    }

    for $ctx.res.cookies.kv -> $name, $attrs {
        my $value = $attrs{'value'}:delete;
        my $bake  = bake-cookie($name, $value, |%($attrs));
        if ( $ctx.res.header.field('Set-Cookie') ) {
            $ctx.res.header.push-field(Set-Cookie => $bake);
            next;
        }

        $ctx.res.header.field(Set-Cookie => $bake);
    }

    # return context response
    my Int $status = $ctx.response.code;
    my $body       = $ctx.response.content;

    my @headers = ();
    for $ctx.response.header.hash.kv -> $name, $value {
        if ($name eq 'Content-Type') { next; }

        for $value.list -> $vl {
            @headers.push($name => $vl);
        }
    }

    # set content-type charset if not present
    my Str $charset      = $ctx.response.charset || 'utf8';
    my Str $content_type = $ctx.response.content-type || 'text/html';
    $content_type = "{ $content_type }, charset={ $charset }";
    @headers.push('Content-Type' => $content_type);

    # body
    if (!$body.isa(Channel) && !$body.isa(IO::Handle)) {
        if (!$body.isa(Array)) {
            $body = Array.new($body.defined ?? $body !! "");
        }
    }

    return $status, @headers, $body;
}
