unit role Net::DNS::Message::Resource::AAAA;

class Net::DNS::AAAA {
    has @.owner-name;
    has @.octets;

    method Str {
        my $str;
        for 0..^+@.octets {
            $str ~= @.octets[$_].fmt("%02x");
            if $_ && $_ % 2 && $_ != (+@.octets - 1) {
                $str ~= ':';
            }
        }
        return $str;
    }
}

method rdata-parsed {
    return Net::DNS::AAAA.new(:owner-name(@.name), :octets($.rdata.list));
}
