Email::MIME
===========

This is a port of perl 5's Email::MIME.

## Example Usage ##

    use Email::MIME;

    my $eml = Email::MIME.new($raw-mail-text);
    say $eml.body-str;

    my $new = Email::MIME.create(header-str => ['from' => 'root+github@retupmoca.com',
                                                'subject' => 'This is a»test.'],
                                 attributes => {'content-type' => 'text/plain',
                                                'charset' => 'utf-8',
                                                'encoding' => 'quoted-printable'},
                                 body-str => 'Hello«World');
    say ~$new;

## Methods ##

 -  `new(Str $text)`

 -  `create(:$header, :$header-str, :$attributes, :$parts, :$body, :$body-str)`

 -  `filename($force = False)`

 -  `invent-filename($ct?)`

 -  `filename-set($filename)`

 -  `boundary-set($string)`

 -  `content-type()`

 -  `content-type-set($ct)`

 -  `charset-set($charset)`

 -  `name-set($name)`

 -  `format-set($format)`

 -  `disposition-set($disposition)`

 -  `encoding-set($enc)`

 -  `parts()`

    Returns the subparts of the current message. If there are no subparts, will
    return the current message.

 -  `subparts()`

    Returns the subparts of the current message. If there are no subparts, will
    return an empty list.

 -  `walk-parts($callback)`

    Visits each MIME part once, calling `$callback($part)` on each.

 -  `debug-structure()`

    Prints out the part structure of the email.

 -  `parts-set(@parts)`

    Sets the passed `Email::MIME` objects as the parts of the email.

 -  `parts-add(@parts)`

    Adds the passed `Email::MIME` objects to the list of parts in the email.

 -  `body-str( --> Str)`

    Returns the mail body, decoded according to the charset and transfer encoding
    headers.

 -  `body-str-set(Str $body)`

    Sets the mail body to $body, encoding it using the charset and transfer
    encoding configured.

 -  `body( --> Buf)`

    Returns the mail body as a binary blob, after decoding it from the
    transfer encoding.

 -  `body-set(Blob $data)`

    Sets the mail body to `$data`. Will encode $data using the configured
    transfer encoding.

 -  `body-raw()`

    Returns the raw body of the email (What will appear when .Str is called)

 -  `body-raw-set($body)`

    Sets the raw body of the email (What will appear when .Str is called)

 -  `header-str-pairs()`

    Returns the full header data for an email.

 -  `header-str($name, :$multi)`

    Returns the email header with the name `$name`. If `:$multi` is not passed, then
    this will return the first header found. If `:$multi` is set, then this will
    return a list of all headers with the name `$name` (note the change from v1.0!)


 -  `header-str-set($name, *@lines)`

    Sets the header `$name`. Adds one `$name` header for each additional argument
    passed.

 -  `header-names()`

    Returns a list of header names in the email.

 -  `headers()`

    Alias of `header-names()`

 -  `header($name)`

    Returns a list of email headers with the name `$name`. If used in string context,
    will act like the first value of the list. (So you can call
    `say $eml.header('Subject')` and it will work correctly). Note that this will
    not decode any encoded headers.

 -  `header-set($name, *@lines)`

    Sets the header `$name`. Adds one `$name` header for each additional argument
    passed. This will not encode any headers, even if they have non-ascii
    characters.

 -  `header-pairs()`

    Returns the full header data for an email. Note that this will not decode any
    encoded headers.

        $eml.header-pairs(); # --> [['Subject', 'test'], ['From', 'me@example.com']]

 -  `as-string()`, `Str()`

    Returns the full raw email, suitable for piping into sendmail.

 -  `crlf()`

 -  `header-obj()`

 -  `header-obj-set($obj)`

## License ##

All files in this repository are licensed under the terms of the Creative Commons
CC0 License; for details, please see the LICENSE file
