use v6;

use Email::Simple::Header;
use Email::MIME::Encoder::Base64;
use MIME::QuotedPrint;

unit class Email::MIME::Header is Email::Simple::Header;

grammar EncodedHeader {
    regex TOP {
        \=\?<charset>\?<encoding>\?<text>\?\=
    }
    regex charset {
        <-[?]>*
    }
    regex encoding {
        .
    }
    regex text {
        <-[?]>*
    }
}

my %cte-coders = ('base64' => Email::MIME::Encoder::Base64,
                  'quoted-printable' => MIME::QuotedPrint);

method set-encoding-handler($encoding, $handler){
    %cte-coders{$encoding} = $handler;
}

method header-str($header, :$multi) {
    my $values = self.header($header, :$multi);
    for $values.list -> $value is rw {
        while my $stuff = EncodedHeader.parse($value) {
            my $newstuff;
            my $charset = ~$stuff<charset>;
            my $encoding = ~$stuff<encoding>;
            my $text = ~$stuff<text>;

            # TODO make this more flexible
            if $encoding.uc eq 'Q' {
                $newstuff = %cte-coders<quoted-printable>.decode($text, :mime-header).decode($charset);
            } elsif $encoding.uc eq 'B' {
                $newstuff = %cte-coders<base64>.decode($text, :mime-header).decode($charset);
            }

            my $oldstuff = ~$stuff;
            $value ~~ s/$oldstuff/$newstuff/;
        }
    }

    return $values;
}

method header-str-set($header, *@lines is copy) {
    for @lines -> $value is rw {
        my $encode = False;
        my $blob = $value.encode('utf8');
        for $blob.list {
            if $_ > 126 || $_ < 32 {
                $encode = True;
            }
        }

        if $encode {
            # TODO use base64 instead?
            my $encoded = %cte-coders<quoted-printable>.encode($blob, :mime-header);
            $value = '=?UTF-8?Q?' ~ $encoded ~ '?=';
        }
    }
    self.header-set($header, |@lines);
}

method header-str-pairs {
    return gather {
        for self.headers -> $name {
            take [ $name, self.header-str($name) ];
        }
    };
}
