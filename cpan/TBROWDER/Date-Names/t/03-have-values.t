use v6;
use Test;

plan 417;

use Date::Names;

# Have values
for 1..12 -> $mon {
    ok %Date::Names::mon{$mon};
    for @lang -> $L {
        ok %Date::Names::mon{$L}{$mon};
    }

    ok %Date::Names::mon2<fr>{$mon};

    ok %Date::Names::mon3{$mon};
    for <de en es nl ru> -> $L {
        ok %Date::Names::mon3{$L}{$mon};
    }

    # the following don't yet have values
    for <fr it nb> -> $L {
        nok %Date::Names::mon3{$L}{$mon}, "no value yet";
    }
}

for 1..7 -> $day {
    ok %Date::Names::dow{$day};
    for @lang -> $L {
        ok %Date::Names::dow{$L}{$day};
    }

    ok %Date::Names::dow3{$day};
    for <en es fr nl> -> $L {
        ok %Date::Names::dow3{$L}{$day};
    }

    # the following don't yet have values
    for <de it nb ru> -> $L {
        nok %Date::Names::dow3{$L}{$day}, "no value yet";
    }

    ok %Date::Names::dow2{$day};
    for <de en es nl ru> -> $L {
        ok %Date::Names::dow2{$L}{$day};
    }

    # the following don't yet have values
    for <fr it nb> -> $L {
        nok %Date::Names::dow2{$L}{$day}, "no value yet";
    }
}
