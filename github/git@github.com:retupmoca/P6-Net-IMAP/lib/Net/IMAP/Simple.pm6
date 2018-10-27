unit class Net::IMAP::Simple;

use Net::IMAP::Message;

has $.raw;
has $.mailbox;
has @.capabilities;

method new(:$raw!, :$ssl, :$tls, :$plain){
    $raw.switch-to-ssl() if $ssl;
    
    my $greeting = $raw.get-response;

    fail "Bad greeting" unless $greeting ~~ /^\*\s+[OK|PREAUTH]/;

    my @capabilities = self.get_capabilities($raw);

    if @capabilities.grep('STARTTLS') {
        if !$ssl && !$plain {
            my $resp = $raw.starttls;
            if $resp ~~ /OK/ {
                $raw.switch-to-ssl;
                @capabilities = self.get_capabilities($raw);
            }
            elsif $tls {
                fail "STARTTLS failed: " ~ $resp;
            }
        }
    }
    else {
        fail "Server doesn't support STARTTLS" if $tls;
    }

    my $self = self.bless(:$raw, :capabilities(@capabilities));

    return $self;
}

method get_capabilities($raw) {
    my @cap_lines = $raw.capability.split("\r\n");
    my @capabilities;
    for @cap_lines -> $line is rw {
        if $line ~~ s/^\*\sCAPABILITY\s// {
            @capabilities.append($line.split(/\s+/).grep({ $_ }));
        }
    }

    return @capabilities;
}

method quit {
    $.raw.logout;
    $.raw.conn.close;
    return True;
}
method logout { self.quit }

method get-message(:$uid, :$sid) {
    if $uid {
        return Net::IMAP::Message.new(:imap(self), :mailbox($.mailbox), :$uid);
    } else {
        return Net::IMAP::Message.new(:imap(self), :mailbox($.mailbox), :$sid);
    }
}

method search(*%params) {
    my $resp = $.raw.search(|%params);
    fail "Bad search" unless $resp ~~ /\w+\hOK\N+$/;
    my @lines = $resp.split("\r\n");
    @lines .= grep(/^\*\h+SEARCH/);
    my @messages = @lines[0].comb(/\d+/);
    @messages .= map({ Net::IMAP::Message.new(:imap(self), :mailbox($.mailbox), :sid($_)) });
    return @messages;
}

method select($mailbox) {
    $!mailbox = $mailbox;
    my $resp = $.raw.select($mailbox);
    fail "Bad select" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method authenticate($user, $pass) {
    my $resp = $.raw.login($user, $pass);
    fail "Bad authenticate" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method create($mailbox) {
    my $resp = $.raw.create($mailbox);
    fail "Bad create" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method delete($mailbox) {
    my $resp = $.raw.delete($mailbox);
    fail "Bad delete" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method rename($old, $new) {
    my $resp = $.raw.rename($old, $new);
    fail "Bad rename" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method subscribe($mailbox) {
    my $resp = $.raw.subscribe($mailbox);
    fail "Bad subscribe" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method unsubscribe($mailbox) {
    my $resp = $.raw.unsubscribe($mailbox);
    fail "Bad unsubscribe" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}

method mailboxes(:$subscribed) {
    my $resp;
    if $subscribed {
        $resp = $.raw.lsub('""', '*');
    } else {
        $resp = $.raw.list('""', '*');
    }
    fail "Bad mailbox list" unless $resp ~~ /\w+\hOK\N+$/;
    my @lines = $resp.split("\r\n");
    my @boxes;
    for @lines {
        if /^\*\s+L...\s+\((.*?)\)\s+\S+\s+(.+)$/ {
            my $flags = $0.Str;
            @boxes.push($1.Str);
        }
    }
    return @boxes;
}

method append($message) {
    my $resp = $.raw.append($.mailbox, ~$message);
    fail "Bad append" unless $resp ~~ /\w+\hOK\N+$/;
    return True;
}
