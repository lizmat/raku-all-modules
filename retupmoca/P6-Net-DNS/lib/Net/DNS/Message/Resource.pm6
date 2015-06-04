use Net::DNS::Message::DomainName;

use Net::DNS::Message::Resource::A;
use Net::DNS::Message::Resource::AAAA;
use Net::DNS::Message::Resource::CNAME;
use Net::DNS::Message::Resource::MX;
use Net::DNS::Message::Resource::NS;
use Net::DNS::Message::Resource::PTR;
use Net::DNS::Message::Resource::SPF;
use Net::DNS::Message::Resource::SRV;
use Net::DNS::Message::Resource::TXT;
use Net::DNS::Message::Resource::SOA;

unit class Net::DNS::Message::Resource does Net::DNS::Message::DomainName;

has Str @.name is rw;
has Int $.type is rw = 0;
has Int $.class is rw = 0;
has Int $.ttl is rw = 0;
has Buf $.rdata = Buf.new;

has Int $.start-offset;
has %.name-offsets is rw;
has Int $.parsed-bytes;

multi method new($data is copy, %name-offsets is rw, $start-offset){
    my $domain-name = self.parse-domain-name($data, %name-offsets, $start-offset);
    my @name = $domain-name<name>.list;
    my $parsed-bytes = $domain-name<bytes>;

    $data = Buf.new($data[$parsed-bytes..*]);

    my ($type, $class, $ttl, $rdlength) = $data.unpack('nnNn');
    $parsed-bytes += 10;
    $parsed-bytes += $rdlength;
    $data = Buf.new($data[10..*]);
    my $rdata = Buf.new($data[0..^$rdlength]);

    my $self = self.bless(:@name, :$type, :$class, :$ttl, :$rdata, :$start-offset, :$parsed-bytes);
    $self.set-name-offsets(%name-offsets);

    given $type {
        when 1 { # A
            $self does Net::DNS::Message::Resource::A;
        }
        when 28 { # AAAA
            $self does Net::DNS::Message::Resource::AAAA;
        }
        when 5 { # CNAME
            $self does Net::DNS::Message::Resource::CNAME;
        }
        when 15 { # MX
            $self does Net::DNS::Message::Resource::MX;
        }
        when 2 { # NS
            $self does Net::DNS::Message::Resource::NS;
        }
        when 12 { # PTR
            $self does Net::DNS::Message::Resource::PTR;
        }
        when 99 { # SPF
            $self does Net::DNS::Message::Resource::SPF;
        }
        when 33 { # SRV
            $self does Net::DNS::Message::Resource::SRV;
        }
        when 16 { # TXT
            $self does Net::DNS::Message::Resource::TXT;
        }
        when 6 { # SOA
            $self does Net::DNS::Message::Resource::SOA;
        }
    }

}

multi method new () {
    self.bless();
}

method set-name-offsets(%name-offsets is rw){
    %!name-offsets := %name-offsets;
}

method Buf {
    my $out = Buf.new;
    for @.qname {
        my $len = pack('C', $_.chars);
        my $str = $_.encode('ascii');
        $out = $out ~ $len ~ $str;
    }
    return $out ~ pack('CnnNn', (0, $.type, $.class, $.ttl, $.rdata.elems)) ~ $.rdata;
}

method Blob {
    Blob.new(self.Buf);
}
