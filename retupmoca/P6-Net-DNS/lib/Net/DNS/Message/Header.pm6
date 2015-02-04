class Net::DNS::Message::Header;

has Int $.id is rw = 0;
has Int $.qr is rw = 0;
has Int $.opcode is rw = 0;
has Int $.aa is rw = 0;
has Int $.tc is rw = 0;
has Int $.rd is rw = 0;
has Int $.ra is rw = 0;
has Int $.z is rw = 0;
has Int $.rcode is rw = 0;
has Int $.qdcount is rw = 0;
has Int $.ancount is rw = 0;
has Int $.nscount is rw = 0;
has Int $.arcount is rw = 0;

has Int $.parsed-bytes;

multi method new(Blob $data) {
    my ($id, $flags, $qdcount, $ancount, $nscount, $arcount) = $data.unpack('nnnnnn');
    my $qr = ($flags +> 15) +& 0x01;
    my $opcode = ($flags +> 11) +& 0x0F;
    my $aa = ($flags +> 10) +& 0x01;
    my $tc = ($flags +> 9) +& 0x01;
    my $rd = ($flags +> 8) +& 0x01;
    my $ra = ($flags +> 7) +& 0x01;
    my $z = ($flags +> 4) +& 0x07;
    my $rcode = $flags +& 0x0F;

    self.bless(:$id, :$qr, :$opcode, :$aa, :$tc, :$rd, :$ra, :$z, :$rcode, :$qdcount, :$ancount, :$nscount, :$arcount, :parsed-bytes(12));
}

multi method new () {
    self.bless();
}

method Buf {
    my $flags = (($.qr +& 0x01) +< 15)
                +| (($.opcode +& 0x0F) +< 11)
                +| (($.aa +& 0x01) +< 10)
                +| (($.tc +& 0x01) +< 9)
                +| (($.rd +& 0x01) +< 8)
                +| (($.ra +& 0x01) +< 7)
                +| (($.z  +& 0x07) +< 4)
                +| ($.rcode +& 0x0F);
    my @data = ($.id, $flags, $.qdcount, $.ancount, $.nscount, $.arcount);
    return pack('nnnnnn', @data);
}

method Blob {
    Blob.new(self.Buf);
}
