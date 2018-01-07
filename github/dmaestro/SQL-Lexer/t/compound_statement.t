use v6;
use Test;

use SQL::Basic;

my $sql_cs = q:to/END_SQL/;
CREATE FUNCTION add_one( num INT )
RETURNS INT
BEGIN
    DECLARE plus INT;
    SET plus = num + 1;
    RETURN plus;
END
;
END_SQL

my $match = SQL::Basic.parse($sql_cs);

ok $match.isa('Match'), 'Successful match returned';

multi sub descend($structure, &destruct, &finish) {
    gather {
        descend($structure, &destruct, &finish, :nogather);
    }
}
multi sub descend($structure, &destruct, &finish, :$nogather!) {
    for $structure.&destruct -> $sub {
        if ($sub.&finish) {
            take $sub;
        }
        else {
            descend($sub.value, &destruct, &finish, :nogather);
        }
    }
}
my @compounds = descend($match, $match.can('caps').first, *.key eq 'compound-statement');

is @compounds.elems, 1,
    'One compound statement matched';
ok @compounds[0].value.Str ~~ / ^ BEGIN .* && .* END $ /,
    'Statement delimited by BEGIN / END';

done-testing;
