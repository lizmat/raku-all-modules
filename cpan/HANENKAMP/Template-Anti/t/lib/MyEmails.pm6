
use Template::Anti;

class BlankText is Template::Anti::Format {
    method parse($source) {
        class {
            has $.source is rw;

            method set($blank, $value) {
                $!source ~~ s:g/ "_{$blank}_" /$value/;
                Mu
            }

            method Str { $.source }
        }.new(:$source);
    }

    method prepare-original($master) {
        $master.clone;
    }

    method embedded-source($master) {
        my $code;
        ($master.source, $code) = $master.source.split("\n__CODE__\n", 2);

        use MONKEY-SEE-NO-EVAL;
        my $sub = $code.EVAL;

        $sub;
    }

    method render($final) { $final.source }
}

class MyEmails {
    method hello($email, *%data)
    is anti-template(
        :source<welcome.txt>,
        :format(BlankText),
    ) {
        $email.set($_, %data{ $_ }) for <name dark-lord>;
    }

    method hello-embedded($email, %adata)
    is anti-template(
        :source<welcome-embedded.txt>,
        :format(BlankText),
    ) {
        ...
    }
}

