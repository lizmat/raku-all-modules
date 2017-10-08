use lib 'lib';
use Test;
use Terminal::Width;

ok terminal-width() ~~ Int, 'terminal-width returned a number';

done-testing;
