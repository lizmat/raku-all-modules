use Net::DNS::Message::DomainName;

unit class Net::DNS::Message::Question does Net::DNS::Message::DomainName;

use experimental :pack;

has Str @.qname is rw;
has Int $.qtype is rw = 0;
has Int $.qclass is rw = 0;

has Int $.parsed-bytes;

multi method new($data is copy, %name-offsets, $start-offset) {
    my $domain-name = self.parse-domain-name($data, %name-offsets, $start-offset);
    my @qname = $domain-name<name>.list;
    my $parsed-bytes = $domain-name<bytes>;
    
    $data = Buf.new($data[$parsed-bytes..*]);

    my ($qtype, $qclass) = $data.unpack('nn');
    $parsed-bytes += 4;

    self.bless(:@qname, :$qtype, :$qclass, :$parsed-bytes);
}

multi method new () {
    self.bless();
}

method Buf {
    my $out = Buf.new;
    for @.qname {
        my $len = pack('C', $_.chars);
        my $str = $_.encode('ascii');
        $out = Buf.new($out.list, $len.list, $str.list);
    }
    return Buf.new($out.list, pack('Cnn', (0, $.qtype, $.qclass)).list);
}

method Blob {
    Blob.new(self.Buf);
}
