use MONKEY-SEE-NO-EVAL;
use HTTP::Status;
use MIME::Types;
use Log;
use X::Hematite;
use Hematite::Request;
use Hematite::Response;

unit class Hematite::Context;

# static vars
my MIME::Types $MimeTypes;

# instance vars
has $.app;
has Hematite::Request $.request;
has Hematite::Response $.response;
has %!captures = (
    'list'  => Nil,
    'named' => Nil
);
has %.stash = ();
has Log $.log;

# methods
method new($app, Hash $env) {
    return self.bless(
        app => $app,
        env => $env,
    );
}

submethod BUILD(*%args) {
    $!app      = %args{'app'};
    $!request  = Hematite::Request.new(%args{'env'});
    $!response = Hematite::Response.new(200, Content-Type => 'text/html, charset=utf-8');
    $!log      = Log.new(
        pattern => '[%d][%X{request_id}][%c] %m%n',
        level   => $!app.log.level,
        output  => $!app.log.output,
        mdc     => $!app.log.mdc.Hash,
        ndc     => $!app.log.ndc.Array,
    );

    self.log.mdc.put('request_id',
        sprintf('%s-%s', $*PID, $*THREAD.id));

    # search for the mime.types file
    if (!$MimeTypes) {
        my @mimetype_paths = ('/etc', '/etc/apache2');
        for @mimetype_paths -> $path {
            my $fullpath = $path ~ '/mime.types';
            if ($fullpath.IO.e) {
                $MimeTypes = MIME::Types.new($fullpath);
                last;
            }
        }
    }

    self.log.debug("processing request: " ~ $!request.uri);

    return self;
}

method FALLBACK(Str $name, |args) {
    my $helper = self.app.helper($name);
    return self.$helper(|@(args));
}

method !get-captures(Str $type) {
    return EVAL(%!captures{$type}.perl);
}

method !set-captures(Str $type, $values) returns ::?CLASS {
    if (%!captures{$type}.defined) {
        self.log.debug('captures already setted, skipping it.');
        return self;
    }

    my $copy = EVAL($values.perl);
    %!captures{$type} = $copy;
    return self;
}

method req() returns Hematite::Request  { return self.request; }
method res() returns Hematite::Response { return self.response; }

# route captures
multi method captures() returns Array {
    return self!get-captures('list');
}

# route set list capture params
multi method captures(@captures) {
    return self!set-captures('list', @captures);
}

# route named captures
multi method named-captures() returns Hash {
    return self!get-captures('named');
}

# route set named capture params
multi method named-captures(%captures) {
    return self!set-captures('named', %captures);
}

multi method halt(*%args) {
    X::Hematite::HaltException.new(status => 500, |%args).throw;
}

multi method halt($body) {
    self.halt(body => $body);
}

multi method halt(Int $status) {
    self.halt(status => $status);
}

multi method halt(Int $status, $body) {
    self.halt(status => $status, body => $body);
}

method not-found() { self.halt(404); }

method try-catch(Block :$try, Block :$catch?, Block :$finally?) returns ::?CLASS {
    try {
        $try();

        CATCH {
            my $ex = $_;

            when X::Hematite::DetachException {
                $ex.rethrow;
            }

            default {
                if (!$catch) {
                    $ex.rethrow;
                }

                $catch($ex);
            }
        }

        LEAVE {
            if ($finally) {
                $finally();
            }
        }
    }

    return self;
}

multi method url-for(Str $url is copy, @captures is copy, *%query) returns Str {
    # if the $url hasn't the initial '/' use has context the current url
    my Str $full_url = "";
    if ( $url ~~ /^\// ) { # absolute
        $full_url = self.request.base;
        $full_url = $full_url.subst(/\/$/, "");
    }
    else { # relative
        $full_url = self.request.uri ~ '/';
    }

    # replace captures :w+
    while (@captures.elems > 0 && (my $match = ($url ~~ /:i (\:\w+)/))) {
        my Str $group = ~($match[0]);
        my $value = @captures.shift;
        $url ~~ s/$group/$value/;
    }
    $full_url ~= $url;

    # add query string
    my Str $querystring = '';
    for %query.kv -> $key, $value {
        my $tmp_value = $value;
        if (!$tmp_value.isa(Array)) {
            $tmp_value = [$tmp_value];
        }

        for @($tmp_value) -> $vl {
            if ($querystring.chars > 0) {
                $querystring ~= '&';
            }
            $querystring ~= "$( $key )=$( $vl )";
        }
    }
    if ($querystring.chars > 0) {
        $full_url ~= '?' ~ $querystring;
    }

    return $full_url;
}

multi method url-for(Str $url, *%query) returns Str {
    return self.url-for($url, [], |%query);
}

multi method url-for(Str $url is copy, %captures is copy, *%query) returns Str {
    # replace captures
    for %captures.kv -> $key, $value {
        my $tmp_value = $value;
        if (!$tmp_value.isa(Array)) {
            $tmp_value = [$tmp_value];
        }

        while ($tmp_value.elems > 0 && (my $match = ($url ~~ /:i (\:$key)/))) {
            my Str $group = ~($match[0]);
            my $value = $tmp_value.shift;
            $url ~~ s/$group/$value/;
        }
    }

    return self.url-for($url, |%query);
}

multi method url-for-route(Str $name, $captures, *%query) {
    my $route = self.app.get-route($name);
    if ( !$route ) {
        self.log.warn("no route found with name: { $name }");
        return;
    }

    return self.url-for($route.pattern, $captures, |%query);
}

multi method url-for-route(Str $name, *%query) {
    return self.url-for-route($name, [], |%query);
}

method !render-to-string($data, %options) returns Str {
    my $type = %options{'type'};
    if (!$type) {
        # if is a Str, by default is a template otherwise is json
        $type = $data.isa(Str) ?? 'template' !! 'json';
    }

    %options{'type'} = $type = lc($type);
    return self.app.render-handler($type)($data, |%options);
}

method render-to-string($data, *%options) returns Str {
    return self!render-to-string($data, %options);
}

method render($data, *%options) returns ::?CLASS {
    my $result = self!render-to-string($data, %options);

    my Str $type         = %options<type>;
    my Str $format       = lc(%options<format> // 'html');
    my Str $content_type = $type eq 'template' ?? $format !! $type;
    $content_type = $MimeTypes.type($content_type);

    # guess status
    my Int $status = %options<status> || 200;

    # set content-type
    self.response.set-code($status);
    self.response.field(Content-Type => $content_type);
    self.response.content = $result;

    return self;
}

method detach() { X::Hematite::DetachException.new.throw; }

method redirect(Str $url) returns ::?CLASS {
    self.response.set-code(302);
    self.response.field(location => $url);

    return self;
}

method redirect-and-detach(Str $url) {
    self.redirect($url);
    self.detach;
}

multi method handle-error(X::Hematite::HaltException $ex) returns ::?CLASS {
    my Callable $handler = self.app.error-handler($ex.status);
    $handler ||= self.app.error-handler(X::Hematite::HaltException);

    $handler(self, |$ex.attributes);

    return self;
}

multi method handle-error(Exception $ex) returns ::?CLASS {
    try {
        my Exception:U $type = $ex.WHAT;
        my @types = $type.^parents;
        @types.unshift($type);

        my Callable $handler = Nil;
        for @types -> $tp {
            $handler = self.app.error-handler($tp);
            last if $handler;
        }

        $handler(self, exception => $ex,);

        CATCH {
            my Exception $ex = $_;

            when X::Hematite::HaltException {
                self.handle-error($ex);
            }

            when X::Hematite::DetachException {
                # don't do nothing, stop handle error process
            }
        }
    }

    return self;
}

method stream(Callable $fn) returns ::?CLASS {
    my Channel $channel = Channel.new;

    # check in every half a second if the client is still receving the data,
    # otherwise close the channel
    # we know the client is receiving is the poll is Nil
    my $scheduler = $*SCHEDULER.cue(
        {
            $channel.close if $channel.poll;
        },
        every => 0.5,
    );

    # start a new thread and run the passed function
    start {
        my $orig_request_id = self.log.mdc.get('request_id');
        self.log.mdc.put('request_id',
            sprintf('%s-%s', $orig_request_id, $*THREAD.id));

        self.try-catch(
            try     => sub { $fn(sub ($value) { $channel.send($value); }); },
            catch   => sub ($ex) {
                return if $ex.isa(X::Channel::SendOnClosed);

                # log the error
                self.log.error($ex.gist);
            },
            finally => sub {
                $channel.close;
                self.log.debug('stream closed');
            }
        );

        self.log.mdc.put('request_id', $orig_request_id);
    }.then({
        self.log.debug('stream finished, cancelling the scheduler');
        $scheduler.cancel;
    });

    self.response.content = $channel;

    return self;
}

method serve-file(Str $filepath) returns ::?CLASS {
    # get file extension
    my Str $ext = IO::Path.new($filepath).extension;

    # guess content type
    my Str $content_type = $MimeTypes.type($ext) || 'application/octect-stream';
    self.response.content-type($content_type);

    # serve file
    self.response.content = $filepath.IO.open;

    return self;
}
