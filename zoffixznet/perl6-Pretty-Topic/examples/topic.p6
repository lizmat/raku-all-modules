use lib <lib>;
use Pretty::Topic '♥';

say ^4 .map: { $_ + 10 }; # fugly
say ^4 .map: { ♥  + 10 }; # purty!

given <meow woof>.pick  {
    when ♥ ~~ /meo/ { say 'Tis a kitty!' }
    when ♥ ~~ /oof/ { say 'Tis a doggy!' }
}
