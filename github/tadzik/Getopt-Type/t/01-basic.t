use Test;
use Getopt::Type;

{
    my %here;
    sub foo(*%opts where getopt(<force push>)) {
        %here = %opts
    }
    lives-ok { foo(:force) }
    ok %here<force>;
    nok %here<push>;
    lives-ok { foo(:push) }
    nok %here<force>;
    ok %here<push>;
    dies-ok  { foo(:whatever)  }
}

{
    my %here;
    sub foo(*%opts where getopt(<f|force v|verbose n|never>)) {
        %here = %opts
    }
    sub check-contents {
        ok %here<f>;  ok %here<force>;
        ok %here<v>;  ok %here<verbose>;
        nok %here<n>; nok %here<never>;
    }
    lives-ok { foo(:f, :v) }
    check-contents;
    lives-ok { foo(:f, :verbose) }
    check-contents;
    lives-ok { foo(:force, :v) }
    check-contents;
    lives-ok { foo(:force, :verbose) }
    check-contents;
    lives-ok { foo(:fv) }
    check-contents;
}

done-testing;
