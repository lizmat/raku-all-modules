unit role Net::DNS::Message::DomainName;

method parse-domain-name($data is copy, %name-offsets is rw, $start-offset) {
    my @offset-list = (0);
    my $parsed-bytes = 1;
    my $len = $data.unpack('C');
    $data = Buf.new($data[1..*]);
    my @name;
    while $len > 0 {
        if $len >= 192 {
            $parsed-bytes += 1;
            @offset-list.push(0);
            @name.push(%name-offsets{$data[0]}.list);
            $data = Buf.new($data[1..*]);
            $len = 0;
        } else {
            $parsed-bytes += $len;
            @offset-list.push($parsed-bytes);
            @name.push(Buf.new($data[0..^$len]).decode('ascii'));
            $data = Buf.new($data[$len..*]);
            $len = $data.unpack('C');
            $parsed-bytes += 1;
            $data = Buf.new($data[1..*]);
        }
    }

    for 1..^+@offset-list {
        my $i = $_ - 1;
        %name-offsets{$start-offset + @offset-list[$i]} = @name[$i..*];
    }
    return (bytes => $parsed-bytes, name => @name).hash;
}
