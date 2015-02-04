#!/usr/bin/env perl6
use v6;
use Test;
use Plosurin;
#my $tmpl = '{import file="some/test.pod" rule="!head,:private"}';
#if Plosurin::Template.parse($tmpl, :actions(Plosurin::TActions.new)
#    ) { "OK".say} else { "BAD".say };
#say $/.pretty;
#say $/.ast.values.^methods().sort().uniq().join(', ').elems;
#say $/.ast.^methods().join(', ');
#say 'POS: ' ~ $/.CURSOR.pos ~ 'chars: ' ~ $/.orig.chars;

my @lexer_tests = 
'<div>Text</div></div>',
[{'Plo::raw_text' => [] }],
'raw text',

'{ print $arrt }',
[{"Plo::command_print" => []}],
0,

'{import file="some/test.pod" rule="!head,:private"}',

[{"Plo::command_import" => {"file" => "some/test.pod", "rule" => "!head,:private"}}],
0,
;

for @lexer_tests -> $template, $check, $test_name {
    my $res = Plosurin::Template.parse($template,  :actions(Plosurin::TActions.new));
    is_deeply [ $/.ast».dumper],$check, $test_name ?? $test_name !! $template;
}

