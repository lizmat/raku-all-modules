unit role Net::DNS::Message::Resource::MX;

class Net::DNS::MX {
    has @.owner-name;
    has $.priority;
    has @.name;

    method Str {
        @.name.join('.');
    }
}

method rdata-parsed {
    my $rdata-size = $.rdata.elems;
    my $priority = $.rdata.unpack('n');
    my $name = self.parse-domain-name(Buf.new($.rdata[2..*]),
                                      %.name-offsets,
                                      $.start-offset + $.parsed-bytes - $rdata-size + 2);
    return Net::DNS::MX.new(:owner-name(@.name), :$priority, :name($name<name>.list));
}
