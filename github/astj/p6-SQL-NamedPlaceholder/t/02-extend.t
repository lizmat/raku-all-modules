use v6;
use Test;

use SQL::NamedPlaceholder;

for ('', '`', '"') -> $q {
    for qw/= <=> <> != <= < >= >/ -> $op {
        my ($sql, $bind) = bind-named(qq:to/EOQ/, { blog_id => 3, limit => 5 });
SELECT * FROM {$q}entry{$q}
    WHERE {$q}blog_id{$q} $op ?
    ORDER BY datetime DESC
    LIMIT :limit
EOQ

        is $sql, qq:to/EOQ/;
SELECT * FROM {$q}entry{$q}
    WHERE {$q}blog_id{$q} $op ?
    ORDER BY datetime DESC
    LIMIT ?
EOQ

        is-deeply $bind, [3,5];
    }
}

done-testing;
