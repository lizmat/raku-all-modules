
use Test;
use Getopt::Advance;
use Getopt::Advance::Exception;

plan 10;

{
    my OptionSet $optset .= new;

    $optset.insert-cmd("plus", "Using plus feature");
    $optset.insert-cmd("multi", "Using multi feature");
    $optset.insert-pos("other", "Using other feature", :front, sub ($arg) {
        &ga-try-next("want try next optionset");
    });
    $optset.insert-pos("type", 1, sub ($arg) {
        say $arg;
    });
    $optset.insert-pos("control", * - 2, sub ($arg) {
        say $arg;
    });
    $optset.push("h|help=b", "print this help message.");
    $optset.push("c|count=i!", "set count.");
    $optset.push("w|=s!", "wide string.");
    $optset.push("quite=b/", "quite mode.");

    dies-ok {
        getopt(["addx", ], $optset);
    }, "auto helper";
}

{
    my OptionSet $optset .= new;

    $optset.insert-cmd("plus");
    $optset.insert-cmd("multi");
    $optset.insert-pos("type", 1, sub ($arg) {
        say $arg;
    });
    $optset.insert-pos("control", * - 2, sub ($arg) {
        say $arg;
    });
    $optset.push("h|help=b", "print this help message.");
    $optset.push("v|version=b", "print the version message.");
    $optset.push("c|count=i!", "set count.");
    $optset.push("w|=s!", "wide string.");
    $optset.push("quite=b/", "quite mode.");

    lives-ok {
        getopt(["plus", "-c", 2, "-w", "string", "-h"], $optset, :autohv);
    }, "auto helper";

    $optset.reset-cmd("plus");
    $optset.reset('h');

    lives-ok {
        getopt(["plus", "-c", 2, "-w", "string", "-v"], $optset, :autohv, version => "v0.0.1 create by araraloren.\n");
    }, "auto helper";

    $optset.reset-cmd("plus");

    lives-ok {
        getopt(["plus", "-c", 2, "-w", "string", "-h"], $optset, :autohv, :disable-pos-help);
    }, "auto helper that disable POS";

    $optset.reset-cmd("plus");

    lives-ok {
        getopt(["plus", "-c", 2, "-w", "string", "-h"], $optset, :autohv, :disable-cmd-help);
    }, "auto helper that disable CMD";

    $optset.reset-cmd("plus");

    lives-ok {
        getopt(["plus", "-c", 2, "-w", "string", "-v"], $optset, :autohv, :disable-cmd-help, :disable-pos-help);
    }, "auto helper that disable CMD";
}

{
    use Getopt::Advance::Utils;
    use Getopt::Advance::Exception;

    my OptionSet @oss;

    for ^3 {
        @oss[$_] .= new;
        @oss[$_].push('?=b', 'print the help message.');
    }

    @oss[0].insert-cmd(
        "help",
        "Print help for all optionset",
    );

    set-autohv("?", "v");

    dies-ok {
        getopt([ "-w", ], @oss, :autohv);
    }, "multiple optionset help";

    @oss[1].insert-cmd(
        "fetch",
        'Fetch something from website ?',
    );
    @oss[0].push("debug=b", 'open debug mode');
    @oss[1].push("proxy=s", 'set proxy');
    @oss[1].push("quite=b/", 'open quite mode');
    @oss[2].push("update=b", 'update before going on');
    @oss[2].insert-pos(
        :front,
        "directory",
        'set the directory need to process',
    );

    dies-ok {
        getopt([ "-w", ], @oss, :autohv);
    }, "multiple optionset help";

    dies-ok {
        getopt([ "-w", ], @oss, :autohv, :one-section-cmd, :compact-help);
    }, "multiple optionset help with one-section-cmd and compact-help";

    @oss[2].insert-cmd(
        "auto",
        "auto search the directory",
    );

    dies-ok {
        getopt([ "-w", ], @oss, :autohv, :one-section-cmd, :compact-help);
    }, "multiple optionset help with one-section-cmd and compact-help";
}
