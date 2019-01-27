use v6;

unit module HTTP::Supply::Tools;

my constant CR = 0x0d;
my constant LF = 0x0a;

sub crlf-line(Buf $buf is rw, :$encoding = 'iso-8859-1' --> Str) is export {
    my $line-end;
    BYTE: for 0..$buf.bytes - 2 -> $i {
        # We haven't found the CRLF yet. Keep going.
        next BYTE unless $buf[$i..$i+1] eqv (CR,LF);

        # Found it. Remember the end index.
        $line-end = $i;
        last BYTE;
    }

    # If we never found the end, we don't have a size yet. Drop out.
    return Nil without $line-end;

    # Consume the size string from buf.
    my $line = $buf.subbuf(0, $line-end);
    $buf .= subbuf($line-end + 2);

    $line.decode($encoding);
}

sub make-p6wapi-name($name is copy) is export {
    $name .= trans('-' => '_');
    $name = "HTTP_" ~ $name.uc;
    $name = 'CONTENT_TYPE'   if $name eq 'HTTP_CONTENT_TYPE';
    $name = 'CONTENT_LENGTH' if $name eq 'HTTP_CONTENT_LENGTH';
    return $name;
}


