use v6;
use Test;

use SQL::NamedPlaceholder;

my ($sql, $bind) = bind-named(q:to/EOQ/, { blog_id => 3, limit => 5 });
SELECT * FROM entry
    WHERE blog_id = :blog_id
    ORDER BY datetime DESC
    LIMIT :limit
EOQ

is $sql, q:to/EOQ/;
SELECT * FROM entry
    WHERE blog_id = ?
    ORDER BY datetime DESC
    LIMIT ?
EOQ

is-deeply $bind, [3,5];

done-testing;
