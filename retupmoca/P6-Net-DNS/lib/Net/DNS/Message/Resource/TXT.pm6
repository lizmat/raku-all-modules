role Net::DNS::Message::Resource::TXT;

class Net::DNS::TXT {
    has @.owner-name;
    has $.text;

    method Str {
        return $.text;
    }
}

method rdata-parsed {
    my $text = Buf.new($.rdata[1..*]).decode('ascii');
    return Net::DNS::TXT.new(:owner-name(@.name), :$text);
}
