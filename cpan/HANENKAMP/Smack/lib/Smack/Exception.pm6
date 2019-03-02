use v6;

class X::Smack::Exception is Exception {
    method response() {
        500,
        [
            Content-Type => 'text/plain',
            Content-Length => 21,
        ],
        [ 'Internal Server Error' ]
    }
}

class X::Smack::Exception::NotFound is X::Smack::Exception {
    method response() {
        404,
        [
            Content-Type   => 'text/plain',
            Content-Length => 9,
        ],
        [ 'Not Found' ]
    }
}

class X::Smack::Exception::BadRequest is X::Smack::Exception {
    method response() {
        400,
        [
            Content-Type   => 'text/plain',
            Content-Length => 11,
        ],
        [ 'Bad Request' ]
    }
}

class X::Smack::Exception::Forbidden is X::Smack::Exception {
    method response() {
        403,
        [
            Content-Type   => 'text/plain',
            Content-Length => 9,
        ],
        [ 'Forbidden' ]
    }
}
