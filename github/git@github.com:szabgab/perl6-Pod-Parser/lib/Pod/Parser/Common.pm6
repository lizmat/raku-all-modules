class X::Pod::Parser is Exception {
    has $.msg;
	has $.text;

    method message {
        sprintf "%s for %s",
                $.msg, $.text
    }
}

