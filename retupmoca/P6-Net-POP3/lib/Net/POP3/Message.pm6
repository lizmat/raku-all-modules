class Net::POP3::Message;

has $.pop;
has $.sid;
has $.deleted = False;
has $!size;
has $!uid;
has $!data;

class X::Net::POP3::NoSize is Exception { };
class X::Net::POP3::NoUID is Exception { };
class X::Net::POP3::NoData is Exception { };

method new(:$pop!, :$sid!, :$size, :$uid) {
    my $self = self.bless(:$sid, :$pop);
    $self._init($size, $uid);
    return $self;
}
method _init($size, $uid) {
    $!size = $size if $size;
    $!uid = $uid if $uid;
}

method size {
    unless $!size {
        my $response = $.pop.raw.list($.sid);
        if $response ~~ /^\+OK ' ' (\d+) ' ' (\d+)$/ {
            $!size = $1;
        } else {
            return fail(X::Net::POP3::NoSize.new);
        }
    }
    return $!size;
}

method uid {
    unless $!uid {
        my $response = $.pop.raw.uidl($.sid);
        if $response ~~ /^\+OK ' ' (\d+) ' ' (.+)$/ {
            $!uid = $1;
        } else {
            return fail(X::Net::POP3::NoUID.new);
        }
    }
    return $!uid;
}

method data {
    unless $!data {
        my $response = $.pop.raw.retr($.sid);
        if $response.substr(0,3) eq '+OK' {
            $response ~~ s/^\+OK <-[\r]>* \r\n//;
            $!data = $response;
        } else {
            return fail(X::Net::POP3::NoData.new);
        }
    }
    return $!data;
}

method mime {
    my $data = self.data;
    return $data unless $data;

    $! = Nil;
    my $mime-class;
    try { require Email::MIME; };
    if $! || !($mime-class = ::('Email::MIME')) {
        return fail "Email::MIME not installed!";
    }
    
    return $mime-class.new($data);
}

method delete {
    my $response = $.pop.raw.dele($.sid);
    return fail(X::Net::POP3::NoDelete.new) unless $response.substr(0,3) eq '+OK';
    $!deleted = True;
    return True;
}
