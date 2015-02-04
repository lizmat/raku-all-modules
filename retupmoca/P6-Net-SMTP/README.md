P6-Net-SMTP
===========

A pure-perl6 implementation of a SMTP client.

This module includes two different modes of operation: raw mode (sending raw SMTP
commands), and a simple mode (just send this email!).

## Example Usage ##

    # raw interface
    my $client = Net::SMTP.new(:server("your.server.here"), :port(587), :debug, :raw);
    $client.get-response; # 220 your.server.here ...
    $client.ehlo; # 250-STARTTLS\r\n250 ...
    $client.mail-from('from@your.server.here'); # 250 OK
    $client.rcpt-to('to@your.server.here'); # 250 OK
    $client.data; # 354 Enter message
    $client.payload($email); # 250 OK
    $client.quit; # 221 closing connection

    #simple interface
    my $client = Net::SMTP.new(:server("your.server.here"), :port(587), :debug);
    $client.auth($username, $password);
    $client.send($from, @to, $message);
    $client.send($message); # find From/To/CC/(BCC)? lines
    $client.quit;

## Simple mode methods ##

Note that all of these methods should return a true value on success or a Failure
object if something goes wrong.

 -  `new(:$server!, :$port = 25, :$hostname, :$debug, :$socket, :$ssl, :$starttls, :$plain)`
    
    Creates a new SMTP client and opens the connection to the server.

    `$server` is required and defines what server to connect to. Note that this
    does not do a MX lookup - if you need to find the MX server, use Net::DNS or
    similar.
    
    `$port` defaults to 25, and defines what port to connect to on the remote
    server.

    `$hostname` defaults to calling `gethostname()`, and determines the hostname
    given to the server in the initial HELO or EHLO message

    `$debug` when set to a true value, will print the SMTP traffic to stderr.

    `$socket` allows you to define a class other than IO::Socket::INET to
    be used for network communication. If you pass a defined object, Net::SMTP
    will assume it is a ready-to-use socket.
    
    By default, this module will use STARTTLS if the server reveals that it is supported,
    otherwise it uses plain-text communication. To override this, you can pass one of
    `$ssl` for an initial SSL connection, `$starttls` to force STARTTLS usage, or
    `$plain` to disable transport encryption completely.

 -  `auth-methods()`

    Returns a list of auth methods that are both supported by the server and by
    this module.

 -  `auth-methods-raw()`

    Returns a raw list of authenticatio methods supported by the server. Response
    is a space-seperated string.

 -  `auth($username, $password, :@methods, :@disallow, :$force)`

    Authenticates with the SMTP server with the given $username and $password.

    Currently supports CRAM-MD5, LOGIN, PLAIN.

    You can set @methods to explicitly declare which methods you would like to try,
    in your order of preference. If not set, @methods will default to the result
    of auth-methods().

    @disallow can be set to disable authentication methods from being attempted
    (to disable the insecure auth types, for example).

    $force, if set, means that this module won't check the list of server supported
    authentication types - it will simply assume the server supports everything.
    This is possibly useful if you have an SMTP server that doesn't support EHLO,
    but still supports authentication.

 -  `send($from, $to, $message, :$keep-going)`

    Sends an email $message (which can be a Str or something with a Str method)
    from $from; and to $to (which can be either a single address or a list of
    addresses). If $keep-going is set, will attempt to send the message even if
    one of the recipients fails.

 -  `send($message, :$keep-going)`

    Attempts to extract from and to information from the email headers (using
    Email::Simple), and then calls the above send method.

    Note that if you pass a Email::Simple or Email::MIME object, this method will
    not create a new Email::Simple, it will just use what you pass.

 -  `quit`

    Closes the connection to the server.

## Raw mode methods ##

 -  `new(:raw, :$server!, :$port = 25, :$debug, :$socket)`

    Creates a new SMTP client and opens the connection to the server.

    `$server` is required and defines what server to connect to. Note that this
    does not do a MX lookup - if you need to find the MX server, use Net::DNS or
    similar.
    
    `$port` defaults to 25, and defines what port to connect to on the remote
    server.

    `$debug` when set to a true value, will print the SMTP traffic to stderr.

    `$socket` allows you to define a class other than IO::Socket::INET to
    be used for network communication. If you pass a defined object, Net::SMTP
    will assume it is a ready-to-use socket.

    
 -  `get-response`
 -  `send($stuff)`
 -  `ehlo($hostname = gethostname())`
 -  `helo($hostname = gethostname())`
 -  `starttls()`
 -  `switch-to-ssl()`
 -  `auth-login($username, $password)`
 -  `auth-plain($username, $password)`
 -  `mail-from($address)`
 -  `rcpt-to($address)`
 -  `data`
 -  `payload($mail)`
 -  `rset`
 -  `quit`
