P6-Net-IMAP
===========

An IMAP client library.

## Example Usage ##

    my $i = Net::IMAP.new(:$server);
    $i.authenticate($user, $pass);
    $i.select('INBOX');
    my @messages = $i.search(:all);
    for @messages {
        say .mime.header('subject');
    }

## Simple interface methods ##

 -  `new(:$server, :$port = 143, :$debug, :$socket, :$ssl, :$starttls, :$plain)`

 -  `authenticate($user, $pass)`

 -  `mailboxes(:$subscribed)`

 -  `create($mailbox)`

 -  `delete($mailbox)`

 -  `rename($old-box, $new-box)`

 -  `subscribe($mailbox)`

 -  `unsubscribe($mailbox)`

 -  `select($mailbox)`

 -  `append($message)`

 -  `get-message(:$sid, :$uid)`

 -  `search(*%params)`

 -  `logout()`, `quit()`

### Net::IMAP::Message methods ###

 -  `sid`

 -  `uid`

 -  `flags(@new?)`

 -  `copy($mailbox)`

 -  `delete`

 -  `data`

 -  `mime-headers`

 -  `mime`

## Raw interface methods ##

 -  `get-response`

 -  `capability`

 -  `noop`

 -  `logout`

 -  `starttls`

 -  `switch-to-ssl`

 -  `login($user, $pass)`

 -  `select($mailbox)`

 -  `examine($mailbox)`

 -  `create($mailbox)`

 -  `delete($mailbox)`

 -  `rename($oldbox, $newbox)`

 -  `subscribe($mailbox)`

 -  `unsubscribe($mailbox)`

 -  `list($ref, $mbox)`

 -  `lsub($ref, $mbox)`

 -  `status($mbox, $type)`

 -  `append($name, $message, :$flags, :$datetime)`

 -  `check`

 -  `close`

 -  `expunge`

 -  `uid-search(*%query)`

 -  `search(*%query)`

 -  `uid-fetch($seq, $items)`

 -  `fetch($seq, $items)`

 -  `uid-store($seq, $action, $values)`

 -  `store($seq, $action, $values)`

 -  `uid-copy($seq, $mbox)`

 -  `copy($seq, $mbox)`
