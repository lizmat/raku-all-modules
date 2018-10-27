use v6;
use Test;

use SQL::NamedPlaceholder;

{
    my ($sql, $bind) = bind-named(q:to/EOQ/, { blog_id => [1,2,3] });
SELECT * FROM entry
    WHERE blog_id IN (:blog_id)
    ORDER BY datetime DESC
EOQ

    is $sql, q:to/EOQ/;
SELECT * FROM entry
    WHERE blog_id IN (?, ?, ?)
    ORDER BY datetime DESC
EOQ

    is-deeply $bind, [1,2,3];
}

{
    my ($sql, $bind) = bind-named(q:to/EOQ/, { blog_id => [Nil] });
SELECT * FROM entry
    WHERE blog_id IN (:blog_id)
    ORDER BY datetime DESC
EOQ

    is $sql, q:to/EOQ/;
SELECT * FROM entry
    WHERE blog_id IN (?)
    ORDER BY datetime DESC
EOQ

    is-deeply $bind, [Nil];
}

done-testing;
