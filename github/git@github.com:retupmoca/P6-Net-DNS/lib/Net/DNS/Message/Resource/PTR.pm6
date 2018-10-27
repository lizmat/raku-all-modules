unit role Net::DNS::Message::Resource::PTR;

my class Net::DNS::PTR {
    has @.owner-name;
    has @.name;

    method Str {
        @.name.join('.');
    }
}

method rdata-parsed {
    my $rdata-length = $.rdata.elems;
    my $name = self.parse-domain-name($.rdata, %.name-offsets, $.start-offset + $.parsed-bytes - $rdata-length);
    return Net::DNS::PTR.new(:owner-name(@.name), :name($name<name>.list));
}
