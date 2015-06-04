unit role Net::DNS::Message::Resource::A;

class Net::DNS::A {
    has @.owner-name;
    has @.octets;

    method Str {
        @.octets.join('.');
    }
}

method rdata-parsed {
    return Net::DNS::A.new(:owner-name(@.name), :octets($.rdata.list));
}
