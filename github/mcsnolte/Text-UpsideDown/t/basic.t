use v6;
use lib 'lib';
use Test;
use Text::UpsideDown;

is upside_down('M'), 'W', 'Simple';
is upside_down('foo'), 'ooɟ', 'Foo';
is upside_down('┬─┬'), '┴─┴', 'Table';
is upside_down('┴─┴'), '┬─┬', 'Undo Table';
is upside_down('┻━┻'), '┳━┳', 'Heavy Table';
is upside_down('Finkel!'), '¡ʃǝʞuıℲ', 'Finkel!';
is upside_down('marcel gruenauer'), 'ɹǝnɐuǝnɹƃ ʃǝɔɹɐɯ', 'Author';

done-testing;

