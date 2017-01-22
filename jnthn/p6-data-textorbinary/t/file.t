use Test;
use Data::TextOrBinary;

ok is-text('t/test-data/text'.IO), 'Text file correctly detected as text';
nok is-text('t/test-data/binary'.IO), 'Binary file correctly detected as binary';

done-testing;
