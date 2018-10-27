# Email::Simple #

This is my attempt at porting Email::Simple from perl 5 to perl 6 (mostly just because I can)

## Example Usage ##

    use Email::Simple;

    my $eml = Email::Simple.new($raw-mail-text);
    say $eml.body;

    my $new = Email::Simple.create(header => [['To', 'mail@example.com'],
                                              ['From', 'me@example.com'],
                                              ['Subject', 'test']],
                                   body => 'This is a test.');
    say ~$new;

## Methods ##

 -  `new(Str $text, :$header-class = Email::Simple::Header)`

 -  `new(Array $header, Str $body, :$header-class = Email::Simple::Header)`

    Alias of `.create` with positional arguments.

 -  `create(Array :$header, Str :$body, :$header-class = Email::Simple::Header)`

 -  `header($name, :$multi)`

    Returns the email header with the name `$name`. If `:$multi` is not passed, then
    this will return the first header found. If `:$multi` is set, then this will
    return a list of all headers with the name `$name` (note the change from v1.0!)

 -  `header-set($name, *@lines)`

    Sets the header `$name`. Adds one `$name` header for each additional argument
    passed.

 -  `header-names()`

    Returns a list of header names in the email.

 -  `headers()`

    Alias of `header-names()`

 -  `header-pairs()`

    Returns the full header data for an email.

        $eml.header-pairs(); # --> [['Subject', 'test'], ['From', 'me@example.com']]

 -  `body()`

    Returns the mail body. Note that this module does not try to do any decoding, it
    just returns the body as-is.

 -  `body-set($text)`

    Sets the mail body to `$text`. Note that this module does not try to properly
    encode the body.

 -  `as-string()`, `Str()`

    Returns the full raw email, suitable for piping into sendmail.

 -  `crlf()`

 -  `header-obj()`

 -  `header-obj-set($obj)`

## License ##

All files in this repository are licensed under the terms of Create Commons License; for details please see the LICENSE file
