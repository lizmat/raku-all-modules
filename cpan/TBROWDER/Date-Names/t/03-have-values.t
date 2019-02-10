use v6;
use Test;

plan 84+84+49+49+49;

use Date::Names :ALL;

# Have values
for 1..12 -> $mon {
    ok %mon{$mon};
    ok %mon<de>{$mon};
    ok %mon<en>{$mon};
    ok %mon<es>{$mon};
    ok %mon<fr>{$mon};
    ok %mon<it>{$mon};
    ok %mon<nl>{$mon};
}

for 1..12 -> $mon {
    ok %mon-abbrev3{$mon};
    ok %mon-abbrev3<en>{$mon};

    # the following don't yet have values
    nok %mon-abbrev3<de>{$mon};
    nok %mon-abbrev3<es>{$mon};
    nok %mon-abbrev3<fr>{$mon};
    nok %mon-abbrev3<it>{$mon};
    nok %mon-abbrev3<nl>{$mon};
}

for 1..7 -> $day {
    ok %dow{$day};
    ok %dow<de>{$day};
    ok %dow<en>{$day};
    ok %dow<es>{$day};
    ok %dow<fr>{$day};
    ok %dow<it>{$day};
    ok %dow<nl>{$day};
}

for 1..7 -> $day {
    ok %dow-abbrev3{$day};
    ok %dow-abbrev3<en>{$day};

    # the following don't yet have values
    nok %dow-abbrev3<de>{$day};
    nok %dow-abbrev3<es>{$day};
    nok %dow-abbrev3<fr>{$day};
    nok %dow-abbrev3<it>{$day};
    nok %dow-abbrev3<nl>{$day};
}

for 1..7 -> $day {
    ok %dow-abbrev2{$day};
    ok %dow-abbrev2<en>{$day};
    ok %dow-abbrev2<de>{$day};

    # the following don't yet have values
    nok %dow-abbrev2<es>{$day};
    nok %dow-abbrev2<fr>{$day};
    nok %dow-abbrev2<it>{$day};
    nok %dow-abbrev2<nl>{$day};
}
