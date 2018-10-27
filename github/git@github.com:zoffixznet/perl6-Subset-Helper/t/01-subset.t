use lib 'lib';
use Test;
use Test::Output;
use Subset::Helper;

subset WhateverCodeNoMessage of Int
    where subset-is * > 10;
subset WhateverCodeMessage of Int
    where subset-is * > 10, 'Must be positive';
subset BlockNoMessage of Int
    where subset-is { $_ > 10 };
subset BlockMessage of Int
    where subset-is { $_ > 10 }, 'Must be positive';

sub whatever (WhateverCodeNoMessage $) {}
sub whatever-message (WhateverCodeMessage $) {}
sub block (BlockNoMessage $) {}
sub block-message (BlockMessage $) {} 
    
lives-ok { whatever 42 }, 'WhateverCode with no message and valid value';
dies-ok { whatever -20 }, 'WhateverCode with no message and invalid value';

lives-ok { whatever-message 42 }, 'WhateverCode with message and valid value';
output-like { whatever-message -20; CATCH { default { } } },
    /'Must be positive'/,
    'WhateverCode with message and invalid value';

lives-ok { block 42 }, 'block with no message and valid value';
dies-ok { block -20 }, 'block with no message and invalid value';

lives-ok { block-message 42 }, 'block with message and valid value';
output-like { block-message -20; CATCH { default { } } },
    /'Must be positive'/,
    'block with message and invalid value';
    
done-testing;