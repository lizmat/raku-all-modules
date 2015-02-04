use v6;
use Test;

use Text::CSV;

my $input =
qq[[[subject,predicate,object\n]]] ~
qq[[[dog,bites,man\n]]] ~
qq[[[child,gets,cake\n]]] ~
q[[[arthur,extracts,excalibur]]];

my @AoA = [<subject predicate object>],
          [<dog bites man>],
          [<child gets cake>],
          [<arthur extracts excalibur>];

is_deeply Text::CSV.parse($input),
          @AoA,
          'with no :output parameter, an AoA is returned, header included';

is_deeply Text::CSV.parse($input, :output<arrays>),
          @AoA,
          'with :output<arrays>, an AoA is returned, header included';

my @last-of-AoA = @AoA[1..*];

is_deeply Text::CSV.parse($input, :skip-header),
          @last-of-AoA,
          'with :skip-header, the first line is left out';

my @AoH = { :subject<dog>,    :predicate<bites>,    :object<man>       },
          { :subject<child>,  :predicate<gets>,     :object<cake>      },
          { :subject<arthur>, :predicate<extracts>, :object<excalibur> };

is_deeply Text::CSV.parse($input, :output<hashes>),
          @AoH,
          'with :output<hashes>, an AoH is returned, header as hash keys';

is_deeply Text::CSV.parse($input, :output<hashes>, :!skip-header),
          @AoH,
          'with :output<hashes>, turning :skip-header off is a no-op';

is_deeply Text::CSV.parse($input, :output<hashes>, :skip-header),
          @AoH,
          'with :output<hashes>, turning :skip-header on is a no-op';

class Sentence {
    has Str $.subject;
    has Str $.predicate;
    has Str $.object;
}

my @AoO =
    Sentence.new( :subject<dog>,    :predicate<bites>,    :object<man>       ),
    Sentence.new( :subject<child>,  :predicate<gets>,     :object<cake>      ),
    Sentence.new( :subject<arthur>, :predicate<extracts>, :object<excalibur> );

my @result = Text::CSV.parse($input, :output(Sentence));

for @AoO.kv -> $index, $expected {
    my $got = @result[$index];
    ok $got ~~ Sentence, "got a Sentence $index";
    is $got.subject,   $expected.subject,   "the right subject   $index";
    is $got.predicate, $expected.predicate, "the right predicate $index";
    is $got.object,    $expected.object,    "the right object    $index";
}

done;

# vim:ft=perl6
