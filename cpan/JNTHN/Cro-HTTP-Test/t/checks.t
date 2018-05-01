use Cro::HTTP::Test;

sub routes() is export {
    use Cro::HTTP::Router;
    route {
        get -> 'text' {
            content 'text/plain', 'just a simple text body';
        }
        get -> 'binary' {
            content 'application/octet-stream', Blob.new(1,2,4,9);
        }
        get -> 'headers' {
            header 'X-foo', '123';
            header 'X-BAR', 'mat';
            content 'text/plain', 'unimportant';
        }
    }
}

plan 20;

test-service routes(), {
    test get('/text'),
        status => 200,
        content-type => 'text/plain',
        body-text => 'just a simple text body';
    test get('/text'),
        status => 200,
        content-type => 'text/plain',
        body-text => /simple/;
    test get('/text'),
        status => 200,
        content-type => 'text/plain',
        body-text => *.chars == 23;
    test get('/text'),
        status => 200,
        content-type => 'text/plain',
        body-blob => *.elems == 23;

    test get('/binary'),
        status => 200,
        content-type => 'application/octet-stream',
        body-blob => * eq Blob.new(1,2,4,9);
    test get('/binary'),
        status => 200,
        content-type => 'application/octet-stream',
        body-blob => *.elems == 4;

    test get('/headers'),
        header => (X-foo => '123');
    test get('/headers'),
        header => (X-foo => 123);
    test get('/headers'),
        headers => (X-foo => '123');
    test get('/headers'),
        headers => (X-foo => 123);

    test get('/headers'),
        header => { X-foo => '123' };
    test get('/headers'),
        headers => { X-foo => '123' };
    test get('/headers'),
        headers => { X-foo => '123', X-bar => 'mat' };

    test get('/headers'),
        header => [ X-foo => '123' ];
    test get('/headers'),
        headers => [ X-foo => '123' ];
    test get('/headers'),
        headers => [ X-foo => '123', X-bar => 'mat' ];

    test get('/headers'),
        header => (X-bar => /t/);
    test get('/headers'),
        headers => (X-bar => /t/);
    test get('/headers'),
        headers => { X-foo => * > 100, X-bar => /t/ };
    test get('/headers'),
        headers => [ X-bar => /m/ ];
}
