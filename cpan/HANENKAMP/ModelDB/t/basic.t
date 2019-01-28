use v6;

use Test;

use DBIish;
use ModelDB;

use lib 't/lib';
use MyTest::Accounts;

my $tmpfile = [~] ('a'...'z','0'...'9','A'...'Z').roll(20);
my IO $database = $*TMPDIR.add($tmpfile);
my $dbh = DBIish.connect('SQLite', :$database);
LEAVE $database.unlink;
my $schema = MyTest::Accounts::Schema.new(:$dbh);

isa-ok $schema, ModelDB::Schema;
does-ok $schema.accounts, ModelDB::Table[MyTest::Accounts::Model::Account];
does-ok $schema.lines, ModelDB::Table[MyTest::Accounts::Model::GeneralLedger];
does-ok $schema.entries, ModelDB::Table[MyTest::Accounts::Model::LedgerLine];

done-testing;
