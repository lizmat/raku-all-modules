
use Test;
use Getopt::Advance;
use Getopt::Advance::Exception;

{
    my OptionSet $optset .= new;

    $optset.insert-pos("arthmetic", :front, sub ($, $oparg) {
        given $oparg.value {
            when /plus|multi/ {
                ok True, "ok";
            }

            default {
                &ga-try-next("not recongnize operator");
            }
        }
    });

    lives-ok {
        getopt(<plus 1 2 3 >, $optset);
    }, "plus ok";

    is $optset.get-pos("arthmetic", 0).value, "plus", "value set when pos matched!";

    lives-ok {
        getopt(<multi 1 2 3 >, $optset);
    }, "multi ok";

    is $optset.get-pos("arthmetic", 0).value, "multi", "value set when pos matched!";

    lives-ok {
        getopt([], $optset);
    }, "no argument ok";

    dies-ok {
        getopt(<add 1 2 3 >, $optset);
    }, "other not ok";
}

{
    my OptionSet $optset .= new;

    $optset.insert-pos("dir", :last, sub ($, $oparg) {
        ok $oparg.value (elem) <dir1/ dir2/>, "last parameter";
    });

    lives-ok {
        getopt(<check some dir1/ >, $optset);
    }, "add ok";

    is $optset.get-pos("dir", * - 1).value, "dir1/", "value set when pos matched!";

    lives-ok {
        getopt(<find other dir2/ >, $optset);
    }, "multi ok";

    is $optset.get-pos("dir", * - 1).value, "dir2/", "value set when pos matched!";

    lives-ok {
        getopt([], $optset);
    }, "no argument ok";
}

{
    my OptionSet $optset .= new;

    $optset.insert-pos("dir", * - 1, sub ($, $oparg) {
        ok $oparg.value (elem) <dir1/ dir2/>, "last parameter";
    });

    lives-ok {
        getopt(<check some dir1/ >, $optset);
    }, "add ok";

    lives-ok {
        getopt(<find other dir2/ >, $optset);
    }, "multi ok";

    lives-ok {
        getopt([], $optset);
    }, "no argument ok";
}

{
    my OptionSet $optset .= new;

    $optset.insert-pos("dir", * - 2, sub ($, $oparg) {
        ok $oparg.value (elem) <dir1/ dir2/>, "last parameter";
    });

    lives-ok {
        getopt(<check dir1/ 1>, $optset);
    }, "add ok";

    lives-ok {
        getopt(<find dir2/ 2>, $optset);
    }, "multi ok";

    lives-ok {
        getopt([], $optset);
    }, "no argument ok";
}

done-testing;
