use CucumisSextus::Reporter;
use Terminal::ANSIColor;

unit class CucumisSextus::Reporter::Simple does CucumisSextus::Reporter;


has $.features-executed = 0;
has $.features-skipped = 0;

has $.scenarios-executed = 0;
has $.scenarios-skipped = 0;
has $.scenarios-succeeded = 0;
has $.scenarios-failed = 0;

has $.steps-executed = 0;

# XXX how do we deal with example/outline replacements?

method before-feature($feature) {
    $!features-executed++;
    print BOLD;
    for $feature.file.lines[$feature.line-from .. $feature.line-to] {
        say $_;
    }
    print RESET;
}

method before-scenario($feature, $scenario) { 
    $!scenarios-executed++;
    print BOLD;
    for $feature.file.lines[$scenario.line-from .. $scenario.line-to] {
        say $_;
    }
    print RESET;
}

method skipped-feature($feature) { 
    $!features-skipped++;
    print color('yellow');
    for $feature.file.lines[$feature.line-from .. $feature.line-to] {
        say $_;
    }
    print color('reset');
}

method skipped-scenario($feature, $scenario) { 
    $!scenarios-skipped++;
    print color('yellow');
    for $feature.file.lines[$scenario.line-from .. $scenario.line-to] {
        say $_;
    }
    print color('reset');
}

method step($feature, $scenario, $step, $result) { 
    $!steps-executed++;
    if $result {
        print color('green');
    }
    else {
        print color('red');
    }
    for $feature.file.lines[$step.line-from .. $step.line-to] {
        say $_;
    }
    print color('reset');
}

method after-scenario($feature, $scenario, $result) { 
    if $result {
        $!scenarios-succeeded++;
    }
    else {
        $!scenarios-failed++;
    }
}

method after-run() {
    say BOLD, "$!scenarios-executed scenario" ~ ($!scenarios-executed > 1 ?? 's' !! '') ~ " executed, ", RESET,
    color('yellow'), "$!scenarios-skipped skipped," , 
    color('green'), " $!scenarios-succeeded succeeded,", 
    color('red'), " $!scenarios-failed failed", 
    color('reset');
}
