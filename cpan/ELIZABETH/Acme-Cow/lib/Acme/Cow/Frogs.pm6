use v6.c;

use Acme::Cow;

unit class Acme::Cow::Frogs:ver<0.0.2>:auth<cpan:ELIZABETH> is Acme::Cow;

my $frogs = Q:to/EOC/; 
{$balloon}
                                              {$tr}
                                            {$tr}
          oO)-.                       .-(Oo
         /__  _\                     /_  __\
         \  \(  |     ()~()         |  )/  /
          \__|\ |    (-___-)        | /|__/
          '  '--'    ==`-'==        '--'  '
EOC

method new(|c) { callwith( |c, over => 46 ) }
method as_string() { callwith($frogs) }
