unit module StepDefs;

use CucumisSextus::Glue;

my $trace;

Given /'a new Calculator object'/, sub () {
    say "# new-calculator";
    $trace ~= 'A';
};

Given /'a freshly unboxed Calculator'/, sub () {
    say "# unboxed-calculator";
    $trace ~= 'B';
}

Step /'having pressed' \s+ (\S+) [\s+ 'and' \s+ (\S+)]*/, sub (+@btns) {
    for @btns -> $b {
        $trace ~= "C$b";
    }
}

Step /'having pressed' \s* (123)/, sub ($num) {
    say "# broken-having-pressed '$num'";
    $trace ~= "D$num";
};

Step /'having pressed' \s* (\d+) \s* 'again'/, sub () {
    say "# broken-having-pressed-again";
    $trace ~= 'E';
};

Then /'the display should show' \s* (\d+)/, sub ($num) {
    say "# then-display-shows '$num'";
    $trace ~= "F$num";
};

Step /'having it switched on'/, sub () {
    say "# having-switched-on";
    $trace ~= "G";
};

Step /'having successfully performed the following calculations'/, sub (@table) {
    say "# having-performed";
    for @table -> $r {
        $trace ~= "T" ~ $r{'first'} ~ $r{'operator'} ~ $r{'second'};
    }
}

Before sub ($feature, $scenario) {
    if $feature.tags.first(* ~~ 'hooked') {
        $trace ~= '[';
    }
}

After sub ($feature, $scenario) {
    if $feature.tags.first(* ~~ 'hooked') {
        $trace ~= ']';
    }
}

sub clear-trace() is export {
    $trace = '';
}

sub get-trace() is export {
    return $trace;
}
