use lib <lib>;
use Pretty::Topic 'TOPIC-VAR';
say ^4 .map: { TOPIC-VAR  + 10 };
