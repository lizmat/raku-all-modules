use v6;

use Test;
use lib 't/lib';

class TestFoo {
    use Template::Anti :one-off;

    my class BlankText is Template::Anti::Format {
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

    has &.hello;
    has &.hello-embedded;

    submethod BUILD(:$welcome, :$welcome-embedded) {
        &!hello = anti-template :source($welcome), :format(BlankText), -> $email, *%data {
            $email.set($_, %data{ $_ }) for <name dark-lord>;
        }

        &!hello-embedded = anti-template :source($welcome-embedded), :format(BlankText);
    }
}

my $welcome = "t/view/welcome.txt".IO.slurp;
my $welcome-embedded = "t/view/welcome-embedded.txt".IO.slurp;
my $foo = TestFoo.new(:$welcome, :$welcome-embedded);

my $expect = "t/extend.out".IO.slurp;

is $foo.hello.(:name<Starkiller>, :dark-lord<Darth Vader>), $expect, "custom format works";
is $foo.hello-embedded.(:name<Starkiller>, :dark-lord<Darth Vader>), $expect, "custom format with embedded code works";

done-testing;
