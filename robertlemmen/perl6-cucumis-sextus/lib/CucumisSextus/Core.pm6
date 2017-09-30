unit module CucumisSextus::Core;

use CucumisSextus::Tags;

use X::CucumisSextus::FeatureExecFailure;

my @defined-steps;
my @before-hooks;
my @after-hooks;

sub execute-step($feature, $step) {
    my @matchers-found;
    for @defined-steps -> $s {
        my $cm = $s[1];
        if $step.text.match($cm) && (~$/ eq $step.text) {
            if $s[0] eq $step.verb|'*' {
                push @matchers-found, $s;
            }
        }
    }
    if @matchers-found.elems == 0 {
        # XXX better detail
        die X::CucumisSextus::FeatureExecFailure.new("No matching glue code found for step '" ~ $step.text ~ "' at " ~ $feature.filename ~ ":" ~ $step.line);
    }
    elsif @matchers-found.elems > 1 {
        # XXX better detail
        die X::CucumisSextus::FeatureExecFailure.new("Ambiguous glue code for step '" ~ $step.text ~ "' at " ~ $feature.filename ~ ":" ~ $step.line ~ ", candidates are: ");
    }
    else {
        my $s = @matchers-found[0];
        # re-exec to get matches...
        $step.text.match($s[1]);
        my @args = $/.list.flat>>.Str;
        if $step.table {
           push @args, $step.table;
        }
        if $s[2].cando( \(|@args) ) {
            $s[2](|@args);
        }
        else {
            # XXX better detail
            die X::CucumisSextus::FeatureExecFailure.new("Glue code signature does not match step");
        }
    }
}

sub add-stepdef($type, $match, $callable, $file, $line) is export {
    @defined-steps.push([$type, $match, $callable, $file, $line]);
}

sub add-before-hook($hook) is export {
    @before-hooks.push($hook);
}

sub add-after-hook($hook) is export {
    @after-hooks.push($hook);
}

sub clear-stepdefs() is export {
    @defined-steps = ();
    @before-hooks = ();
    @after-hooks = ();
}

sub execute-feature($feature, @tag-filters) is export {
    say "Feature " ~ $feature.name;

    for $feature.scenarios -> $scenario {
        my @effective-tags;
        @effective-tags.append($feature.tags);
        @effective-tags.append($scenario.tags);

        if !all-filters-match(@tag-filters, @effective-tags) {
            say "  Skipping scenario '" ~ $scenario.name ~ "' due to tag filters";
            next;
        }

        if $feature.background {
            say "  Background " ~ $feature.background.name;
            for $feature.background.steps -> $step {
                say "    Step " ~ $step.verb ~ " " ~ $step.text;
                execute-step($feature, $step);
            }
        }

        say "  Scenario " ~ $scenario.name;

        for @before-hooks -> $hook {
            $hook($feature, $scenario);
        }
        for $scenario.steps -> $step {
            say "    Step " ~ $step.verb ~ " " ~ $step.text;
            execute-step($feature, $step);
        }
        # XXX we want to run these even if there are failures in the steps
        for @after-hooks.reverse -> $hook {
            $hook($feature, $scenario);
        }
    }
}

