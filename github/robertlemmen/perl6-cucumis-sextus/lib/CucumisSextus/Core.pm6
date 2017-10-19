unit module CucumisSextus::Core;

use CucumisSextus::Tags;

use X::CucumisSextus::FeatureExecFailure;

my @defined-steps;
my @before-hooks;
my @after-hooks;

class CucumisResult is export {
    has $.executed is rw = 0;
    has $.skipped is rw = 0;
    has $.succeeded is rw = 0;
    has $.failed is rw = 0;

    method Str() {
        "$!executed scenario" ~ ($!executed > 1 ?? 's' !! '') ~ " executed, $!skipped skipped, $!succeeded succeeded, $!failed failed";
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

sub kv-replace($ptext, $kv, $feature, $step) {
    my $text = $ptext;
    while $text ~~ /\< (<-[\>]>+) \>/ {
        my $match = $0;
        if defined $kv{$0} {
            my $replacement = $kv{$match};
            $text ~~ s/\< $match \>/$replacement/;
        }
        else {
            die X::CucumisSextus::FeatureExecFailure.new("No replacement for '<$match>' in step '" ~ $ptext ~ "' at " ~ $feature.file.filename ~ ":" ~ $step.line-from);
        }
    }
    return $text;
}

sub execute-step($feature, $step, $kvsubst, $reporter) {
    my $text = kv-replace($step.text, $kvsubst, $feature, $step);
    my @matchers-found;
    for @defined-steps -> $s {
        my $cm = $s[1];
        if $text.match($cm) && (~$/ eq $text) {
            if $s[0] eq $step.verb|'*' {
                push @matchers-found, $s;
            }
        }
    }
    if @matchers-found.elems == 0 {
        # XXX better detail
        die X::CucumisSextus::FeatureExecFailure.new("No matching glue code found for step '" ~ $text ~ "' at " ~ $feature.file.filename ~ ":" ~ $step.line-from);
    }
    elsif @matchers-found.elems > 1 {
        # XXX better detail
        die X::CucumisSextus::FeatureExecFailure.new("Ambiguous glue code for step '" ~ $text ~ "' at " ~ $feature.file.filename ~ ":" ~ $step.line-from ~ ", candidates are: ");
    }
    else {
        my $s = @matchers-found[0];
        # re-exec to get matches...
        $text.match($s[1]);
        my @args = $/.list.flat>>.Str;
        if $step.table {
           push @args, $step.table;
        }
        if $step.multiline {
            push @args, $step.multiline;
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

sub execute-scenario($feature, $scenario, $kvsubst, $result, $reporter) {
    $result.executed++;
    $reporter.before-scenario($feature, $scenario);
    for $scenario.steps -> $step {
        execute-step($feature, $step, $kvsubst, $reporter);
        # XXX need other args
        $reporter.step($feature, Nil, $step, True);
    }
    $result.succeeded++;
    $reporter.after-scenario($feature, $scenario, True);
    CATCH {
        when X::CucumisSextus::FeatureExecFailure {
            $reporter.after-scenario($feature, $scenario, False);
            # XXX perhaps we should go on and just tally them differently, but what 
            # are they called?
            .throw;
        }
        default {
            $reporter.step($feature, Nil, Nil, False);
            $reporter.after-scenario($feature, $scenario, False);
            # XXX need other args
            $result.failed++;
            # XXX how do we do this through the reporter?
            say "Exception (" ~ .^name ~ ") during step execution: " ~ .Str;
            for .backtrace {
                say "    ", .file, " ", .line;
            }
        }
    }
}

sub execute-feature($feature, @tag-filters, $result, $reporter) is export {
    # XXX if  there is nothing recognizabl;e in the feature, the error handling
    # is terrible, this can be reproduced by e.g. removing the "#language" line
    # from a non-english feature
    $reporter.before-feature($feature); 

    for $feature.scenarios -> $scenario {
        my @effective-tags;
        @effective-tags.append($feature.tags);
        @effective-tags.append($scenario.tags);

        if !all-filters-match(@tag-filters, @effective-tags) {
            $reporter.skipped-scenario($feature, $scenario);
            $result.skipped++;
            next;
        }

        my @subst = [{},];
        if $scenario.examples {
            @subst = $scenario.examples;
        }

        for @subst -> $kvsubst {
            if $feature.background {
                execute-scenario($feature, $feature.background, $kvsubst, $result, $reporter);
            }

            for @before-hooks -> $hook {
                $hook($feature, $scenario);
            }
            execute-scenario($feature, $scenario, $kvsubst, $result, $reporter);
            # XXX we want to run these even if there are failures in the steps
            for @after-hooks.reverse -> $hook {
                $hook($feature, $scenario);
            }
        }
    }
    $reporter.after-feature($feature, True); # XXX actual result
}

