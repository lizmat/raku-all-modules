use v6;
use Test;
use DBIish;

plan 24;

my %TestOpts = (
    MySQL => { :uid<testuser>, :password<testpass> },
    PostgreSQL => { :uid<postgres> }
);

my $drv;
lives-ok {
    $drv = DBIish.install-driver('ODBC');
},								   'Can install driver';

throws-like {
    $drv.connect('NoSush');
}, X::DBDish::ConnectionFailed,
   :code<IM002>, # The ODBC error code expected
   :message(/ '[Driver Manager]' /), # The level of the error
   'Bogus connect';

isa-ok $drv.data-sources, Seq,					  'Can get DataSources';
isa-ok $drv.drivers, Seq,					      'Can get Drivers';

ok (defined my %drvs = $drv.drivers),				      'Drivers to hash';
diag "Drivers installed: %drvs.keys()";

unless +%drvs {
    skip-rest				     "Can't continue without drivers installed";
    exit;
}
my $DRV = %drvs.keys[0]; # Try the first

ok my $dbh = $drv.connect(
    :Driver($DRV), :database<dbdishtest>, |(%TestOpts{$DRV}||())
),								    "Connected to $DRV";

isa-ok $dbh, ::('DBDish::ODBC::Connection');

ok $dbh.fconn-str,				     'Full connection string available';
#dd $dbh.fconn-str;

ok (my @res = $dbh.execute(q|SELECT 'Hola a todos', 5|):rows),  'Can execute statement';
is @res, ['Hola a todos', 5],				             'The right values';

ok (my $sth = $dbh.prepare(q|SELECT 'Hola mundo' as Hello|)),   'Can prepare statement';

isa-ok $sth, ::('DBDish::ODBC::StatementHandle');

is $dbh.Statements.elems, 1,				                'One statement';

ok $sth.execute,					           'statement executed';
is $sth.rows, 1,					            'One row available';
is +$sth.column-names, 1,				       'Expected column number';
is $sth.column-names[0].uc, 'HELLO',			'With the expected column name';
ok my $row = $sth.row,						         'Read the row';
is $row, 'Hola mundo',                                             'The expected value';

nok $sth.row,								 'No more rows';
ok $sth.Finished,						   'Statement finished';
ok $sth.dispose,					    'Can dispose the statement';
is $dbh.Statements.elems,  0,					       'Zero statemens';
ok $dbh.dispose,					   'Can dispose the connection';

diag "Continuará...";
