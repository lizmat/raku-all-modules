use lib 'lib';

use NASA::APOD;
my NASA::APOD $apod .= new: key => 't/key'.IO.lines[0];

say $apod;
