unit module Base64;

my @chars64base = flat 'A'..'Z','a'..'z','0'..'9';
my @chars64std  = chars64with('+', '/');
my @chars64uri  = chars64with('-', '_');

# todo:
# add multis that use supplies for streaming in/out

our proto sub encode-base64(|) is export {*}
multi sub encode-base64(Str $str, |c) {
    samewith(Blob.new($str.ords), |c)
}
multi sub encode-base64(Bool :$uri! where *.so, |c) {
    samewith(:alpha(@chars64uri), |c)
}
multi sub encode-base64(Bool :$str! where *.so, |c --> Str) {
    samewith(|c).join;
}
multi sub encode-base64(:$pad = '=', |c)            {
    die ":\$pad must be a single character (or empty) Str, or a Boolean"
        unless ($pad ~~ Str && $pad.chars == 0|1) || $pad ~~ Bool;
    callwith(:pad($pad ~~ Bool ?? ?$pad ?? '=' !! '' !! $pad), |c)
}

multi sub encode-base64(Blob $blob, :$pad, :@alpha, |c --> Seq) {
    $ = grep *.so, $blob.rotor(3, :partial).map: -> $chunk {
        state $encodings = chars64with(@alpha);
        my $padding = 0;
        my $n = [+] $chunk.pairs.map: -> $c {
            LAST { $padding = !$pad ?? 0 !! do with (3 - ($c.key+1) % 3) { $^a == 3 ?? 0 !! $^a } }
            $c.value +< ((state $m = 24) -= 8)
        }
        my $res = (18, 12, 6, 0).map({ $n +> $_ +& 63 });
        (slip($encodings[$res[*]][0..*-($padding ?? $padding+1 !! 0)]),
            ((^$padding).map({"$pad"}).Slip if $padding)).Slip;
    }
}


our proto sub decode-base64(|) is export {*}
multi sub decode-base64(Blob $blob, |c) {
    samewith($blob.decode, |c)
}
multi sub decode-base64(Bool :$uri! where *.so, |c) {
    samewith(:bin, :alpha(@chars64uri), |c);
}
multi sub decode-base64(Bool :buf(:$bin)! where *.so, |c --> Blob)  {
    Buf.new(samewith(|c) || 0);
}
multi sub decode-base64(:$pad = '=', |c)            {
    die ":\$pad must be a single character (or empty) Str, or a Boolean"
        unless ($pad ~~ Str && $pad.chars == 0|1) || $pad ~~ Bool;
    callwith(:pad($pad ~~ Bool ?? ?$pad ?? '=' !! '' !! $pad), |c)
}

multi sub decode-base64(Str $str, :$pad, :@alpha, |c --> Seq) {
    my $encodings = chars64with(@alpha);
    $str.comb(/@$encodings/).rotor(4, :partial).map: -> $chunk {
        state %lookup = $encodings.kv.hash.antipairs;
        my $n   = [+] $chunk.map: { (%lookup{$_} || 0) +< ((state $m = 24) -= 6) }
        my $res = (16, 8, 0).map: { $n +> $_ +& 255 }
        #slip($res.grep(* > 0));
        slip($res.head( 3 - ( 4 - $chunk.elems ) ) );
    }
}

my sub chars64with(*@chars) { # is cached (rakudo bug)
    my @alpha = do with @chars.elems -> $c {
        die "alphabet contains {$c} of {$c > 2 ?? 64 !! 2} required encodings" unless $c == 0|2|64;
        $c == 64 ?? @chars !! $c == 2 ??  (@chars64base.Slip, @chars.Slip) !! @chars64std;
    }
    if @chars.grep(* ~~ none(@alpha)) -> $dupes {
        die "alphabet contains {64 - $dupes.elems} of 64 required unique encodings"
            ~ "\nduplicates: {$dupes.join(',')}";
    }
    @alpha;
}
