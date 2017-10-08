use v6;

use Test;

plan 22;

use Form::Grammar;

given Form::Grammar {
    ok(.parse('abcdefghijklm nopqrstuvwxyz.'), 'Plain literal string parses');
    ok(.parse('{[[[[[[}'), 'Simple left block field parses');
    ok(.parse('{]]]}'), 'Simple right block field parses');
    ok(.parse('{<<<<<<<<}'), 'Simple left line field parses');
    ok(.parse('{>>>>>}'), 'Simple right line field parses');
    ok(.parse('{[[]]}'), 'Simple block justified field parses');
    ok(.parse('{<<<>>}'), 'Simple line justified field parses');
    ok(.parse('{>><<}'), 'Simple centred line field parses');
    ok(.parse('{]]]][[[}'), 'Simple centred block field parses');
    ok(.parse('abc {[[[[} def'), 'Left block field inside literals parses');
    ok(.parse('{<<<}wibble'), 'Left line field before literal parses');
    ok(.parse('floob{<<>}'), 'Centred line field after literal parses');
    ok(.parse('{|||||||}'), 'Centred line field (alternative)');
    ok(.parse('{IIII}'), 'Centred block field (alternative)');
    ok(.parse('{>>>>>>=}'), 'Middled end marker');
    ok(.parse('{=>>>>>>}'), 'Middled start marker');
    ok(.parse('{>>>>>>_}'), 'Bottomed end marker');
    ok(.parse('{_>>>>>>}'), 'Bottomed start marker');
    ok(.parse(q[{''''''''''}]), "Verbatim line field");
    ok(.parse('{""""""""""}'), "Verbatim block field");
    ok(.parse('{]]].[[}'), 'Simple number block field parses');
    ok(.parse('{>>>.<<}'), 'Simple number line field parses');
}

# vim: ft=perl6 sw=4 ts=4 noexpandtab
