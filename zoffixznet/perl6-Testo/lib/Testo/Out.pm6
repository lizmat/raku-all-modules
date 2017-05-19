unit role Testo::Out;
use Testo::Test::Result;
multi method put ($) { … }
multi method put (Testo::Test::Result:D $test) { … }
