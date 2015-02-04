P6-Net-POP3
===========

A pure-perl implementation of a POP3 client.

SSL/STARTTLS is not currently suppored.

## Example Usage ##

    ####
    # raw interface
    ####
    my $pop = Net::POP3.new(:server("your.server.here"), :port(110), :debug, :raw);
    $pop.get-response # +OK
    
    $pop.apop-login("username", "password");
    # or (less secure)
    $pop.user("username");
    $pop.pass("password");

    my $message-list = $pop.list; # +OK 2 messages\r\n1 120\r\n...
    say $pop.retr(1); # +OK \r\nFrom:...
    $pop.dele(1);
    $pop.quit;

    ####
    # simple interface
    ####
    my $pop = Net::POP3.new(:server("your.server.here"), :port(110), :debug);
    $pop.auth("username", "password"); # tries apop, then falls back to user/pass
    my $count = $pop.message-count;
    my @messages = $pop.get-messages;
    for @messages {
        my $unique-id = .uid;
        my $raw-data = .data;
        my $email-mime = .mime; # returns Email::MIME object
                                # (requires Email::MIME installed to work)
        .delete;
    }
    $pop.quit;

## Simple mode methods ##

Note that all of these methods should return a true value (or a valid false response,
such as '0' from message-count) on success or a Failure object on failure.

 -  `new(:$server!, :$port, :$debug, :$socket)`

    Creates a new POP3 client and opens a connection to the server.

    `$port` defaults to 110.

    `$debug` will print the network traffic to $*ERR if set.

    `$socket` allows you to use a class other than IO::Socket::INET for
    network communication. If you pass in a defined object, Net::POP3 will assume
    it is an already connected socket.

 -  `auth($username, $password)`

    Authenticates with the server. Attempts APOP first, and if the server doesn't
    support APOP or if the APOP login fails, will attempt a USER + PASS plain text
    login.

 -  `message-count()`

    Returns the number of messages in your mailbox.

 -  `get-message(:$sid, :$uid)`

    Returns a Net::POP3::Message object that refers to the message with the specified
    session id ($sid, the standard POP3 message number) or unique id ($uid, as returned
    from UIDL. NYI)

 -  `get-messages()`

    Returns a list of Net::POP3::Message objects, one for each message in the current
    mailstore.

 -  `quit()`

    Commits any message deletions and closes the connection to the server.

### Net::POP3::Message Methods ###

This class contains the actual message from the POP3 server.

 -  `size()`

    Returns the size of the message, in octets.

 -  `uid()`

    Returns the unique id of the message (as returned by UIDL)

 -  `delete()`

    Deletes this message from the POP3 server. Will not take effect until .quit is
    called on the main object.

 -  `data()`

    Returns the raw email message as a string.

 -  `mime()`

    Returns the email message as an Email::MIME object. Note that this will fail
    if Email::MIME is not installed.
