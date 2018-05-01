use Cro::HTTP::Test;

sub routes() is export {
    use Cro::HTTP::Router;
    route {
        get -> 'cookies', :%cookies is cookie {
            content 'text/plain', %cookies.sort(*.key).map({ "{.key}={.value}" }).join(",");
        }
        get -> 'headers', :@headers is header {
            content 'text/plain', @headers.grep(*.name.starts-with('X-'))
                .sort({ .name, .value }).map({ "{.name}={.value}" }).join(",");
        }
        put -> 'content' {
            content 'text/plain', ~request.content-type;
        }
    }
}

plan 14;

test-service routes(), {
    # Cookies

    test get('/cookies', cookies => { aa => 'foo' }),
        status => 200,
        content-type => 'text/plain',
        body => 'aa=foo';

    test-given cookies => { bb => 'bar' }, {
        test get('/cookies'),
            status => 200,
            content-type => 'text/plain',
            body => 'bb=bar';

        test get('/cookies', cookies => { aa => 'foo' }),
            status => 200,
            content-type => 'text/plain',
            body => 'aa=foo,bb=bar';

        test-given cookies => [ cc => 'baz' ], {
            test get('/cookies'),
                status => 200,
                content-type => 'text/plain',
                body => 'bb=bar,cc=baz';

            test get('/cookies', cookies => { aa => 'foo' }),
                status => 200,
                content-type => 'text/plain',
                body => 'aa=foo,bb=bar,cc=baz';

            test get('/cookies', cookies => { cc => 'win' }),
                status => 200,
                content-type => 'text/plain',
                body => 'bb=bar,cc=win';
        }
    }

    # Headers

    test get('/headers', headers => [ X-aa => 'foo' ]),
        status => 200,
        content-type => 'text/plain',
        body => 'X-aa=foo';

    test-given headers => { X-bb => 'bar' }, {
        test get('/headers'),
            status => 200,
            content-type => 'text/plain',
            body => 'X-bb=bar';

        test get('/headers', headers => { X-aa => 'foo' }),
            status => 200,
            content-type => 'text/plain',
            body => 'X-aa=foo,X-bb=bar';

        test-given headers => [ X-cc => 'baz' ], {
            test get('/headers'),
                status => 200,
                content-type => 'text/plain',
                body => 'X-bb=bar,X-cc=baz';

            test get('/headers', headers => { X-aa => 'foo' }),
                status => 200,
                content-type => 'text/plain',
                body => 'X-aa=foo,X-bb=bar,X-cc=baz';

            test get('/headers', headers => { X-cc => 'win' }),
                status => 200,
                content-type => 'text/plain',
                body => 'X-bb=bar,X-cc=baz,X-cc=win';
        }
    }

    # Content-type and others, which simply get "latest wins" semantics.

    test-given content-type => 'application/json', {
        test put('/content', body-text => '[]'),
            status => 200,
            content-type => 'text/plain',
            body => 'application/json';

        test put('/content', content-type => 'text/plain', body-text => 'foo'),
            status => 200,
            content-type => 'text/plain',
            body => 'text/plain';
    }
}
