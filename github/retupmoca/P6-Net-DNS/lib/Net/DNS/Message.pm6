unit class Net::DNS::Message;

use Net::DNS::Message::Header;
use Net::DNS::Message::Question;
use Net::DNS::Message::Resource;

has Net::DNS::Message::Header $.header is rw;
has Net::DNS::Message::Question @.question is rw;
has Net::DNS::Message::Resource @.answer is rw;
has Net::DNS::Message::Resource @.authority is rw;
has Net::DNS::Message::Resource @.additional is rw;

has Int $.parsed-bytes;

multi method new($data is copy) {
    my %name-offsets;
    my $header = Net::DNS::Message::Header.new($data);
    my $parsed-bytes = $header.parsed-bytes;
    $data = Buf.new($data[$header.parsed-bytes .. *]);

    my @question;
    for 1 .. $header.qdcount {
        my $q = Net::DNS::Message::Question.new($data, %name-offsets, $parsed-bytes);
        $parsed-bytes += $q.parsed-bytes;
        $data = Buf.new($data[$q.parsed-bytes .. *]);
        @question.push($q);
    }

    my @answer;
    for 1 .. $header.ancount {
        my $a = Net::DNS::Message::Resource.new($data, %name-offsets, $parsed-bytes);
        $parsed-bytes += $a.parsed-bytes;
        $data = Buf.new($data[$a.parsed-bytes .. *]);
        @answer.push($a);
    }

    my @authority;
    for 1 .. $header.nscount {
        my $a = Net::DNS::Message::Resource.new($data, %name-offsets, $parsed-bytes);
        $parsed-bytes += $a.parsed-bytes;
        $data = Buf.new($data[$a.parsed-bytes .. *]);
        @authority.push($a);
    }

    my @additional;
    for 1 .. $header.arcount {
        my $a = Net::DNS::Message::Resource.new($data, %name-offsets, $parsed-bytes);
        $parsed-bytes += $a.parsed-bytes;
        $data = Buf.new($data[$a.parsed-bytes .. *]);
        @additional.push($a);
    }

    self.bless(:$header, :@question, :@answer, :@authority, :@additional, :$parsed-bytes);
}

multi method new() {
    self.bless;
}

method Buf {
    return [~] $.header.Buf,
               |@.question».Buf,
               |@.answer».Buf,
               |@.authority».Buf,
               |@.additional».Buf;
}

method Blob {
    return Blob.new(self.Buf);
}
