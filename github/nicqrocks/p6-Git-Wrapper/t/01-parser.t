
use Test;

#Make sure that the parser works.

#Add the local lib folder.
use lib "{$*PROGRAM.dirname}/../lib";
use Git::Log::Parser;


my @commits = Q[commit c1c787b3a1a4d9a7bc5be3fcaaa05d6fc21c6762
Author: Nic <nicq20@gmail.com>
Date:   Thu Jan 12 12:30:34 2017 -0500

    Added a basic test to load the module

    Two line commit message!
],
Q[commit 4723d7953d2c9d3b3c90ecc84450399b44876b74
Author: Jonathan Scott Duff <duff@pobox.com>
Date:   Fri Oct 30 10:38:15 2015 -0500

    Use run() rather than open()
],
Q[commit 4f0c22dadb0d6f03594fdcff8433616e918ed8ec
Merge: abc123 zyx987
Author: Jim Smith <example@example.com>
Date:   Fri Jan 13 09:30:38 2017 -0500

    This is an example commit to test the parser.
];


plan 2;

#Try each test indivigually.
subtest {
    for @commits -> $c {
        ok Git::Log::Parser.parse($c), "Can parse commit, index {$++}";
    }
}

#Join them together and try again.
ok Git::Log::Parser.parse(@commits.join("\n")), "Can parse commit log";

done-testing;
