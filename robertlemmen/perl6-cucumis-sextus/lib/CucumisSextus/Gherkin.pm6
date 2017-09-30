unit module CucumisSextus::Gherkin;

use X::CucumisSextus::FeatureParseFailure;
use CucumisSextus::Tags;

class Feature {
    has $.filename is rw;
    has $.name is rw;
    has $.line is rw;
    has @.scenarios is rw;
    has $.background is rw;
    has @.tags is rw;
}

class Scenario {
    has $.name is rw;
    has $.line is rw;
    has @.steps is rw;
    has @.tags is rw;
}

class Step {
    has $.verb is rw;
    has $.text is rw;
    has $.line is rw;
    has @.table is rw;
}

# XXX this will get long, we could put it into it's own module
my $keywords = {
    'en' => {   'feature'          => /'Feature'|'Business Need'|'Ability'/,
                'scenario'         => 'Scenario',
                'background'       => 'Background',
                'scenario-outline' => /'Scenario Outline'|'Scenario Template'/,
                'examples'         => /'Examples'|'Scenarios'/,
                'given'            => /'*'|'Given'/,
                'when'             => /'*'|'When'/,
                'then'             => /'*'|'Then'/,
                'and'              => /'*'|'And'/,
                'but'              => /'*'|'But'/,
            },
};

sub parse-feature-file($filename) is export {
    my $lang = 'en';
    my $feature;
    my $scenario;
    my $step;
    my $last-verb;
    my @tags;
    my @column-header;

    # XXX tags are madness: https://github.com/cucumber/cucumber/wiki/Tags
    # XXX description lines for features and scenarios

    my $line-number = 1;
    for $filename.IO.lines {
        if m/^ \s* $/ {
            # blank line, end step/scenario
            @column-header = ();
        }
        elsif m/^ \s* '#'/ {
            # comment, ignore
        }
        elsif my @ctags = parse-tags($_) {
            # tags, add to list
            # XXX surely tags can't happen just anywhere...
            @tags.append(@ctags);
        }
        # XXX all over the place: space after colon single, multiple, optional?
        elsif m/^ <{ $keywords{$lang}{'feature'} }> ':' \s* (.+) $/ {
            if ! defined $feature {
                $feature = Feature.new;
                $feature.filename = $filename;
                $feature.name = ~$0;
                $feature.tags = @tags;
                $feature.line = $line-number;
                @tags = ();
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: multiple features per file");
            }
        }
        elsif m/^ \s* <{ $keywords{$lang}{'scenario'} }> ':' \s* (.+) $/ {
            if defined $feature {
                # XXX end previous step
                $scenario = Scenario.new;
                $scenario.name = ~$0;
                $scenario.tags = @tags;
                $scenario.line = $line-number;
                $feature.scenarios.push($scenario);

                $last-verb = Nil;
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: scenario definition without feature");
            }
        }
        elsif m/^ \s* <{ $keywords{$lang}{'background'} }> ':' \s* (.+) $/ {
            if defined $feature {
                if $feature.background {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: multiple background scenarios for feature");
                }
                if $feature.scenarios {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: background scenario after regular scenario");
                }

                $scenario = Scenario.new;
                $scenario.name = ~$0;
                $scenario.tags = @tags;
                $scenario.line = $line-number;
                $feature.background = $scenario;

                $last-verb = Nil;
            }
            else {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: background definition without feature");
            }
        }
        elsif m/^ \s* <{ $keywords{$lang}{'scenario'} }> ':' \s* (.+) $/ {
        }
        elsif m/^ \s* <{ $keywords{$lang}{'given'} }> \s* (.+) $/ {
            my $verb = 'given';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line = $line-number;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* <{ $keywords{$lang}{'when'} }> \s* (.+) $/ {
            my $verb = 'when';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line = $line-number;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* <{ $keywords{$lang}{'then'} }> \s* (.+) $/ {
            my $verb = 'then';
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $0;
            $step.line = $line-number;
            $scenario.steps.push($step);
            $last-verb = $verb;
        }
        elsif m/^ \s* (   <{ $keywords{$lang}{'and'} }>
                        | <{ $keywords{$lang}{'but'} }> )
                            \s* (.+) $/ {

            if ! defined $last-verb {
                die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                    ~ "at $filename:$line-number: 'and'/'but' steps may not appear first in a "
                    ~ "scenario");
            }
            my $verb = $last-verb;
            $step = Step.new;
            $step.verb = $verb;
            $step.text = $1;
            $step.line = $line-number;
            $scenario.steps.push($step);
        }
        # XXX scenario outlines
        elsif m/^ \s* <{ $keywords{$lang}{'examples'} }> \s* (.+) $/ {
            # XXX
        }
        elsif m/^ \s* \| (.*) \| \s* $/ {
            # XXX when can this occur?
            my @fields = $0.trim.split('|')>>.trim;
            if @column-header {
                if @fields.elems != @column-header.elems {
                    die X::CucumisSextus::FeatureParseFailure.new("Failed to parse feature file " 
                        ~ "at $filename:$line-number: inconsistent number of columns across table");
                }
                my %hash = @column-header Z=> @fields;
                $step.table.push(%hash);
            }
            else {
                @column-header = @fields;
            }
            # XXX first line is column headers, turn others into hashes
        }
        $line-number++;
    }
    return $feature;
}
