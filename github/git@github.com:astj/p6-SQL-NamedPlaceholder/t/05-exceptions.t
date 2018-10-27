use v6;
use Test;

use SQL::NamedPlaceholder;

# throws-like { bind-named('', {}) }, Exception, message => 'requires $sql';
throws-like { bind-named('SELECT * FROM entry WHERE id = ?', {}) }, Exception, message => "'id' does not exist in bind hash";

done-testing;
