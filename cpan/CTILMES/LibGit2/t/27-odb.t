use Test;
use LibGit2;

plan 1;

is Git::Odb.hash('this'),
    'a2a3f4f1e30c488bfbd52aabfbcfcc1f5822158d', 'hash';
