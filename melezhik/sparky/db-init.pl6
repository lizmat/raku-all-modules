use v6;
use DBIish;

sub MAIN (
  Str  :$root = '/home/' ~ %*ENV<USER> ~ '/.sparky/projects',
)

{

mkdir $root;

my $db-name = "$root/db.sqlite3";

my $dbh = DBIish.connect("SQLite", database => $db-name );

$dbh.do(q:to/STATEMENT/);
    DROP TABLE IF EXISTS builds
    STATEMENT

$dbh.do(q:to/STATEMENT/);
    CREATE TABLE builds (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        project     varchar(4),
        state       int,
        dt datetime default current_timestamp
    )
    STATEMENT

say "db populated at $db-name";


$dbh.dispose;

}

