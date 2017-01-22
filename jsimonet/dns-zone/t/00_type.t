use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

# This file tests basic types (int8, int16, ...),
# some resource record data (srv, soa, ...)
# and the "type" rule which uses them.

# Type
my @toTestAreOk = (
	{ str => '0'                                , rule => 'd8'         },
	{ str => '255'                              , rule => 'd8'         },
	{ str => '0'                                , rule => 'd16'        },
	{ str => '65535'                            , rule => 'd16'        },
	{ str => '0'                                , rule => 'd32'        },
	{ str => '4294967295'                       , rule => 'd32'        },
	{ str => '0'                                , rule => 'h16'        },
	{ str => 'a'                                , rule => 'h16'        },
	{ str => 'ffff'                             , rule => 'h16'        },
	{ str => 'text'                             , rule => 'text'       },
	{ str => 'te xt'                            , rule => 'text'       },
	{ str => '" te xt "'                        , rule => 'quotedText' },
	{ str => '" te\n xt "'                      , rule => 'quotedText' },
	{ str => '1'                                , rule => 'mxPref'     },
	{ str => '12'                               , rule => 'mxPref'     },
	{ str => '123 456 789 dom'                  , rule => 'rdataSRV'   },
	{ str => "123(\n456\n789\n)dom"             , rule => 'rdataSRV'   },
	{ str => 'dom action 2016100601 12 34 56 78', rule => 'rdataSOA'   },
	{ str => '@ action 2016100601 12 34 56 78'  , rule => 'rdataSOA'   },
	{ str => 'dom @ 2016100601 12 34 56 78'     , rule => 'rdataSOA'   },
	{ str => '@ @ 2016100601 12 34 56 78'       , rule => 'rdataSOA'   },
	{ str => 'a 10.0.0.1'                       , rule => 'type'       },
	{ str => 'A 10.0.0.2'                       , rule => 'type'       },
	{ str => 'aaaa 1000::2000'                  , rule => 'type'       },
	{ str => 'a6 2000::aaaa'                    , rule => 'type'       },
	{ str => 'cname firstcname'                 , rule => 'type'       },
	{ str => 'CNAme secondcname'                , rule => 'type'       },
);

my @toTestAreNOk = (
	{ str => '256'                  , rule => 'd8'         } ,
	{ str => '-1'                   , rule => 'd8'         } ,
	{ str => 'a'                    , rule => 'd8'         } ,
	{ str => '-1'                   , rule => 'd16'        } ,
	{ str => '65536'                , rule => 'd16'        } ,
	{ str => 'a'                    , rule => 'd16'        } ,
	{ str => '4294967296'           , rule => 'd32'        } ,
	{ str => '-1'                   , rule => 'd32'        } ,
	{ str => 'a'                    , rule => 'd32'        } ,
	{ str => '-1'                   , rule => 'h16'        } ,
	{ str => 'gggg'                 , rule => 'h16'        } ,
	{ str => '"text'                , rule => 'text'       } ,
	{ str => "\"text"               , rule => 'text'       } ,
	{ str => "\"te\nxt"             , rule => 'text'       } ,
	{ str => '"text'                , rule => 'quotedText' } ,
	{ str => '123'                  , rule => 'mxPref'     },
	{ str => '1a3'                  , rule => 'mxPref'     },
	{ str => '123 456 789'          , rule => 'rdataSRV'   },
	{ str => '123 456 789dom'       , rule => 'rdataSRV'   },
	{ str => '65536 456 789 dom'    , rule => 'rdataSRV'   },
	{ str => ''                     , rule => 'type'       } ,
	{ str => 'a'                    , rule => 'type'       } ,
	{ str => 'aa 1000::2000'        , rule => 'type'       } ,
	{ str => ' cname tooMuchSpaces' , rule => 'type'       } ,
	{ str => "\tcname tooMuchSpaces", rule => 'type'       } ,
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> %t
{
	ok DNS::Zone::Grammars::Modern.parse(%t<str>, rule => %t<rule> ), "%t<str> with rule %t<rule>";
}

for @toTestAreNOk -> %t
{
	nok DNS::Zone::Grammars::Modern.parse(%t<str>, rule => %t<rule> ), "%t<str> with rule %t<rule>";
}

done-testing;
