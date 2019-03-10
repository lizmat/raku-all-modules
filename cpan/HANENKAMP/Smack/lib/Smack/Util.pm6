use v6;

# TODO Sterling's Truths for Life #124: Never write code in a module containing
# “util” in the name.
#
# MOVE ALL OF THIS SOMEWHERE ELSE!

unit module Smack::Util;

use HTTP::Headers;

# TODO It would be super nice to cache request-headers and response-headers within a given %env, but we have to be wary of cache invalidation of @headers is modified.

sub request-headers(%env) is export {

    my sub setup-headers(%env) {
        my $h = HTTP::Headers.new;
        $h.Content-Type   = %env<CONTENT_TYPE>;
        $h.Content-Length = %env<CONTENT_LENGTH>;
        for %env.kv -> $name is copy, $value {
            $name.=subst(/^ 'HTTP_' /, '');
            $h{ $name } = $value;
        }

        $h
    }

    setup-headers(%env);
}

sub request-encoding(
    Str :$charset,
    :%env,
    Str:D :$fallback = 'ISO-8859-1',
) is export {

    $charset
        // request-headers(:%env).Content-Type.charset
        // $fallback
}

sub response-headers(
    $headers,
    :%env) is export {

    return $headers if $headers ~~ HTTP::Headers;

    HTTP::Headers.new($headers, :quiet)
}

sub response-encoding(
    Str :$charset,
    :$headers,
    :%env,
    Str:D :$fallback = 'UTF-8') is export {

    $charset
        // response-headers($headers, :%env).Content-Type.charset
        // (%env.defined && %env<p6sgi.body.encoding>)
        // $fallback
}

our sub header-remove(@h, $remove) is export {
    @h .= grep(*.key ne $remove)
}

our sub header-set(@h, *@headers, *%headers) is export {
    for flat @headers, %headers -> $p {
        my ($k, $v) = $p.kv;

        my @i = @h.grep({ .key eq $k }, :k);
        if @i {
            # Replace first header value with this
            my $i = shift @i;
            @h[$i] = $k => $v;

            # Delete the rest
            @h[ @i ] :delete;
            @h .= grep(Pair);
        }

        else {
            # No existing header value, add it
            push @h, $k => $v;
        }
    }
}

proto unpack-response(|) is export { * }

multi unpack-response(@res (Int() $status, @headers, Supply() $entity), &response-handler) {
    response-handler($status, @headers, $entity);
}

multi unpack-response(Promise:D $p, &response-handler) {
    my $res = await $p;
    unpack-response($res, &response-handler);
}

=begin pod

=head2 sub infix:<then-with-response>

    sub infix:<then-with-response> ($res, &callback --> Promise:D)

This operator can be used by middleware as a shorthand to perform common tasks. The promise, C<$res>, is a response from an P6WAPI application, either a Promise or the 3-element list. The given callback, C<&callback>, will be called with the 3-element list form, similar to this:

    sub callback(Int:D $code, @headers, Supply:D $entity)

The result of the callback will determine what is done next.

=item C<Nil>. If an undefined value is returned (such as Nil), then the response is returned as it was passed to the callback without any change.

=item C<Supply>. If the value returned is a supply, the entity is replaced int eh response, but the status code and headers are returned as they were given to the callback with no changes.

=item I<Anything else>. Anything else will be treated as a replacement response. This should probably be a Promise, but any acceptable P6WAPI response should be possible.

=end pod

sub infix:<then-with-response> (Promise:D $p, &c --> Promise:D) is export {
    $p.then: -> $then {
        with unpack-response($then, &c) {
            when Supply {
                my ($s, $h) = |$then.result;
                $s, $h, $_
            }
            default { $_ }
        }
        else {
            $then.result
        }
    }
}

multi stringify-encode(Blob $the-stuff,
    :%env, :$headers, Str :$charset) returns Blob is export {
    $the-stuff
}

multi stringify-encode(
    Str:D() $the-stuff,
    :%env,
    :$headers,
    Str :$charset,
) returns Blob is export {
    my $cs = response-encoding(:$charset, :%env, :$headers);
    $the-stuff.encode($cs);
}

multi stringify-encode(
    $the-stuff,
    :%env,
    :$headers,
    Str :$charset,
) returns Blob is export {
    my $cs = response-encoding(:$charset, :%env, :$headers);
    ''.encode($cs);
}

sub status-with-no-entity-body(Int(Any) $status) is export returns Bool:D {
    return $status < 200
        || $status == 204
        || $status == 304;
}

sub encode-html(Str() $str) returns Str is export {
    $str.trans(
        [ '&',     '>',    '<',    '"',      "'"     ] =>
        [ '&amp;', '&gt;', '&lt;', '&quot;', '&#39;' ]
    );
}

# TODO How do we prevent multiple runs of this going at the same time? Some sort
# of cache in %env would help.
sub content-length(%env, Supply() $body, Promise $p is rw, Bool :$defer = False) returns Supply is export {
    $p .= new without $p;
    my $v = $p.vow;

    my $content-length = 0;

    if $defer {
        $body.do({
            when Blob | Str {
                $content-length += stringify-encode($_, :%env).bytes;
            }
        }).on-close({ $v.keep($content-length) });
    }
    else {
        my @body-cache;

        $body.act(
            {
                @body-cache.push: $_;

                when Blob | Str {
                    $content-length += stringify-encode($_, :%env).bytes;
                }
            },
            done => { $v.keep($content-length) },
        );

        @body-cache.Supply;
    }
}
