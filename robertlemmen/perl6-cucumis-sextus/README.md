# Cucumis Sextus

... a Cucumber-like Behavior-Driven Development (BDD) Test Framework for Perl 6.

## State

This is in very early development, and is lacking lots of features and 
probably has quite a lot of bugs as well. But it can already do some basic
cases, see below. 

### Missing Features

* Failure exceptions from glue code
* Harness improvements to allow parallel execution
* Reporting
* TAP integration

## Usage

This is trying to be faithful and compatible to the "consensus" Cucumber 
implementation, which also means that most of this documentation applies:
https://github.com/cucumber/cucumber/wiki/A-Table-Of-Content and will also
explain background and theory better than I possibly could.

Please let me know if there are any surprising discrepancies.

### Basic Feature Files

By default, cucumis will search for feature files under features/*.feature, the 
syntax of these is the same as in other cumumber implementations. Currently only 
basic scenarios are supported, no tables or templates. An example:

    Feature: Basic Calculator Functions
        In order to check I've written the Calculator class correctly
        As a developer I want to check some basic operations
        So that I can have confidence in my Calculator class.

    Scenario: First Key Press on the Display
        Given a new Calculator object
        And having pressed 1
        Then the display should show 1

### Step Definitions

Cucumis will load all .pm6 files under 'step_definitions' in the same directory 
that holds the feature file in question, e.g. "features/step_definitions/StepDefs.pm6":

    unit module StepDefs;

    use CucumisSextus::Glue;

    Given /'a new Calculator object'/, sub () {
        # implement!
    };

    Step /'having pressed' \s* (\d+)/, sub ($num) {
        # implement!
    };

Step definition modules are using semi-keywords from the CucumisSextus::Glue module 
and a regular expression to define step definitions. The "Step" keywords matches any
ype/verb in the scenario steps, and serves as a sort of wildcard. 

When cucumis executes a feature file, it will find the appropriate step definition 
for each step, and execute it. If there is no step definition or there is a problem 
with it, it will report an error.

Note that the step definitions can have arguments that are taken from captures
within the regular expression, as in the "having pressed example above. You can
even use non-capturing groups in the regex and slurpy arguments (quite cool!):


    Step /'having pressed' \s+ (\S+) [\s+ 'and' \s+ (\S+)]*/, sub (+@btns) {
        for @btns -> $b {
            # implement!
        }
    }

### Execution

In order to execute the tests described in a feature file, the "cucumis6" tool can 
be used:

    cucumis6 features

### Tags

You can tag your features and scenarios like this:

    @calc @basic 
    Feature: Basic Calculator Functions
        In order to check I've written the Calculator class correctly
        As a developer I want to check some basic operations
        So that I can have confidence in my Calculator class.

    @positive
    Scenario: First Key Press on the Display
        Given a new Calculator object
        And having pressed 1
        Then the display should show 1

And then select only certain features and scenarios (the latter inherit all the 
tags from the corresponding feature as well as have their own tags) when executing 
cucumis:

    cucumis6 --tags=@calc

You can negate the matches with a '~', and OR them together with commas:

    cucumis6 --tags=@calc,@print
    cucumis6 --tags=~@positive

And you can AND them together by repeatedly specifying --tags:

    cucumis6 --tags=@calc --tags@basic

### Background Scenarios

You can define "background" scenarios:

    Feature: Basic Calculator Functions
    In order to check I've written the Calculator class correctly
    As a developer I want to check some basic operations
    So that I can have confidence in my Calculator class.

    Background: Unboxing a new Calculator
        Given a freshly unboxed Calculator
        And having it switched on

    Scenario: First Key Press on the Display
        Given a new Calculator object
        And having pressed 1
        Then the display should show 1
    
    Scenario: Second Key Press on the Display
        Given a new Calculator object
        And having pressed 1
        And having pressed 2
        Then the display should show 12

These background scenarios will get executed before each of the other 
scenarios of the feature. There can only be one background scenario and
it needs to be the first one in the feature.

### Tables

Your steps can contain tabular data:

    Scenario: Separation of calculations
        Given a new Calculator object
        And having successfully performed the following calculations
            | first | operator | second | result |
            | 0.5   | +        | 0.1    | 0.6    |
            | 0.01  | /        | 0.01   | 1      |
            | 10    | *        | 1      | 10     |
        And having pressed 3
        Then the display should show 3

Your step definition code will get the table passed in as a array of 
hashes, in the final parameter after the captures. The keys come from the
first line of the table in your feature file, and you get one entry per 
following row:

    Step /'having successfully performed the following calculations'/, sub (@table) {
        say @table.perl;
    }

would yield:

    [{:first("0.5"), :operator("+"), :result("0.6"), :second("0.1")}, 
     {:first("0.01"), :operator("/"), :result("1"), :second("0.01")}, 
     {:first("10"), :operator("*"), :result("10"), :second("1")}]

### Multiline Data

In a way similar to tables, you can add multiline verbatim data to your step
definitions by starting and ending such a section with three quotes:

    Feature: Basic Calculator Functions
    In order to check I've written the Calculator class correctly
    As a developer I want to check some basic operations
    So that I can have confidence in my Calculator class.

    Scenario: Ticker Tape
        Given a new Calculator object
        And having entered the following sequence
        """
        1 + 2 + 3 + 4 + 5 + 6 -
        100
        * 13 \=\=\= + 2 =
        """
        Then the display should show -1025

Note that while the indentation of the three quotes themselves, like any other line
in a feature file, is not relevant, that indentation is removed from each line in the
multiline data. This also means that your indentation needs to be somewhat conistent 
or cucumis will fail to do so.

The multiline data is passed to your step definition as a single argument after any
captures, just like with tables. Note that you can only use multiline data or tables 
in a step, not both.

### Hooks

You can create "before" and "after" hooks in your glue code, these will be 
executed before and after each scenario respectively. Before hooks will be 
executed in the order they are registered, and after hooks in reverse order. 
Note however that registration order is unpredicatble across multiple glue 
code modules. These hooks get executed for *any* scenario, so you typically 
want to inspect the feature and scenario passed in before doing anything:

    Before sub ($feature, $scenario) {
        if $feature.tags.first(* ~~ 'hooked') {
            # implement!
        }
    }

    After sub ($feature, $scenario) {
        # implement!
    }

### Outlines and Examples

You can write a single scenario and execute it multiple times for different 
sets of input and output values using outlines and examples:

    Scenario Outline: Basic arithmetic
        Given a new Calculator object
        And having keyed <first>
        And having keyed <operator>
        And having keyed <second>
        And having pressed =
        Then the display should show <result>
        Examples:
        | first | operator | second | result |
        | 5.0   | +        | 5.0    | 10     |
        | 6     | /        | 3      | 2      |
        | 10    | *        | 7.550  | 75.5   |
        | 3     | -        | 10     | -7     |

Note that the glue code regular expression has to match the substituted value, 
not the original one from the step text.

### Other Languages

If you want to write your feature files in your native language rather than in
english, you can certianly do that by putting a language directive into the first
line of your feature file:

    # language: de
    Funktionalität: Einfache Taschenrechner Operationen

    Szenario: Eine Taste wird gedrueckt
        Angenommen ich habe einen Taschenrechner
        Und Ich habe die Taste 1 gedrueckt
        Dann sollte der Bildschirm 1 anzeigen

If you are able to speak a language with cool characters like chinese or thai, 
please get in touch, I need prettier examples!

## Feedback and Contact

Please let me know what you think: Robert Lemmen <robertle@semistable.com>
