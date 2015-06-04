unit role Net::DNS::Message::Resource::SOA;

class Net::DNS::SOA {
    has @.owner-name;
    has @.mname;
    has @.rname;
    has $.serial;
    has $.refresh;
    has $.retry;
    has $.expire;
    has $.minimum;

    method Str {
       ('origin: ',
        @.mname.join('.'),
        "\nmail addr: ",
        @.rname.join('.'),
        "\nserial: ",
        $.serial,
        "\nrefresh: ",
        $.refresh,
        "\nretry: ",
        $.retry,
        "\nexpire: ",
        $.expire,
        "\nminimum: ",
        $.minimum).join;
    }
}

method rdata-parsed {
    my $name-start = $.rdata.elems;
    my $mname = self.parse-domain-name($.rdata, %.name-offsets, $.start-offset + $.parsed-bytes - $name-start);
    my $data = $.rdata.subbuf($mname<bytes>);
    $name-start -= $mname<bytes>;
    my $rname = self.parse-domain-name($data, %.name-offsets, $.start-offset + $.parsed-bytes - $name-start);
    $data = $data.subbuf($rname<bytes>);
    my ($serial, $refresh, $retry, $expire, $minimum) = $data.unpack('NNNNN');

    return Net::DNS::SOA.new(:owner-name(@.name),
                             :mname($mname<name>),
                             :rname($rname<name>),
                             :$serial,
                             :$refresh,
                             :$retry,
                             :$expire,
                             :$minimum);
}
