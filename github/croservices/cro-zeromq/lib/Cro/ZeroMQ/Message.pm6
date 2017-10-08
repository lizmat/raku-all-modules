use Cro::Message;

class Cro::ZeroMQ::Message does Cro::Message {
    has Blob @.parts;

    method parts(--> List) { @!parts.List }
    method body-blob(--> Blob) { @!parts[*-1] }
    method body-text(:$enc = 'utf-8') { @!parts[*-1].decode($enc) }
    method identity() {
        my $res;
        for @!parts {
            if $_ !== Buf.new {
                $res.push: $_;
            } else {
                last;
            }
        }
        $res.elems == 1 ?? $res[0] !! $res;
    }

    multi method new(Str $part)  { self.bless(parts => [$part.encode]) }
    multi method new(Blob $part) { self.bless(parts => [$part]) }
    multi method new(:$parts)    { self.bless(parts => @$parts) }
    multi method new(*@rest) {
        my @res;
        for @rest {
            when Blob {
                @res.push: $_;
            }
            when Str {
                @res.push: Buf.new($_.encode)
            }
            default {
                die "Message part can be only Blob or Str, encountered $_.^name()";
            }
        }
        return self.bless(parts => @res);
    }
}
