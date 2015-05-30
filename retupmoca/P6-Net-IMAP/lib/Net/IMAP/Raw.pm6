unit class Net::IMAP::Raw;

has $.conn is rw;
has $.reqcode is rw = 'aaaa';

method get-response($code?){
    my $line = $.conn.get;
    return $line unless $code;
    my $response = $line;
    while $line.substr(0, $code.chars) ne $code {
        $line = $.conn.get;
        $response ~= "\r\n"~$line;
    }
    return $response;
}

method send($stuff) {
    my $code = $.reqcode;
    $.reqcode = $.reqcode.succ;
    $.conn.send($code ~ " $stuff\r\n");
    return self.get-response($code);
}

method capability {
    return self.send('CAPABILITY');
}

method noop {
    return self.send('NOOP');
}

method logout {
    return self.send('LOGOUT');
}

method login($user, $pass) {
    return self.send("LOGIN $user $pass");
}

method select($mailbox) {
    return self.send("SELECT $mailbox");
}

method examine($mailbox) {
    return self.send("EXAMINE $mailbox");
}

method create($mailbox) {
    return self.send("CREATE $mailbox");
}

method delete($mailbox) {
    return self.send("DELETE $mailbox");
}

method rename($oldbox, $newbox) {
    return self.send("RENAME $oldbox $newbox");
}

method subscribe($mailbox) {
    return self.send("SUBSCRIBE $mailbox");
}

method unsubscribe($mailbox) {
    return self.send("UNSUBSCRIBE $mailbox");
}

method list($ref, $mbox) {
    return self.send("LIST $ref $mbox");
}

method lsub($ref, $mbox) {
    return self.send("LSUB $ref $mbox");
}

method status($mbox, $type) {
    return self.send("STATUS $mbox ({ $type.join(' ') })");
}

method append($name, $message, :$flags, :$datetime) {
    my $code = $.reqcode;
    $.reqcode = $.reqcode.succ;
    my $string = "APPEND $name";
    if $flags {
        $string ~= " ({ $flags.join(' ') })";
    }
    if $datetime {
        $string ~= " $datetime";
    }
    $.conn.send($code ~ " $string\r\n");
    my $resp = self.get-response;
    if $resp ~~ m:i/^\+\s/ {
        $.conn.send($message);
        return self.get-response($code);
    } else {
        unless $resp ~~ /^$code/ {
            $resp ~= "\r\n" ~ self.get-response($code);
        }
        return $resp;
    }
}

method check {
    return self.send("CHECK");
}

method close {
    return self.send("CLOSE");
}

method expunge {
    return self.send("EXPUNGE");
}

method uid-search(*%query) {
    return self.send("UID SEARCH "~self!generate-search-query(%query));
}
method search(*%query) {
    return self.send("SEARCH "~self!generate-search-query(%query));
}
method !generate-search-query(%query) {
    my $output;
    if %query<charset> {
        $output ~= " CHARSET %query<charset>";
    }
    for %query.kv -> $k, $v {
        next unless $v;
        given $k {
            when any(<seq sid>) {
                $output ~= " $v";
            }
            when 'not' {
                $output ~= " NOT ({ self!generate-search-query($v) })";
            }
            when 'or' {
                $output ~= " OR ({ self!generate-search-query($v[0]) })";
                $output ~= " ({ self!generate-search-query($v[1]) })";
            }
            when any(<all answered deleted draft flagged new old recent seen unanswered undeleted undraft unflagged unseen>) {
                $output ~= " " ~ $k.uc;
            }
            when any(<bcc before body cc from keyword larger on sentbefore senton sentsince since smaller subject text to uid unkeyword>) {
                $output ~= " " ~ $k.uc ~ " $v";
            }
            when 'header' {
                $output ~= " HEADER $v[0] $v[1]";
            }
        }
    }
    return $output;
}

method uid-fetch($seq, $items) {
    return self.send("UID FETCH $seq ({ $items.join(' ') })");
}
method fetch($seq, $items) {
    return self.send("FETCH $seq ({ $items.join(' ') })");
}

method uid-store($seq, $action, $values) {
    return self.send("UID STORE $seq $action ({ $values.join(' ') })");
}
method store($seq, $action, $values) {
    return self.send("STORE $seq $action ({ $values.join(' ') })");
}

method uid-copy($seq, $mbox) {
    return self.send("UID COPY $seq $mbox");
}
method copy($seq, $mbox) {
    return self.send("COPY $seq $mbox");
}
