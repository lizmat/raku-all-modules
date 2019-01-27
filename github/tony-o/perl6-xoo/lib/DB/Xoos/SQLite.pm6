use DB::Xoos;
unit class DB::Xoos::SQLite does DB::Xoos;

use DB::Xoos::DSN;
use DBIish;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = 'SQLite';
  $!prefix = %options<prefix> // '';
  self.load-models(%options<model-dirs>//[]);
}

multi method connect(Str:D $dsn, :%options) {
  my %connect-params = parse-dsn($dsn);

  die 'unable to parse DSN '~$dsn unless %connect-params.elems;

  self.connect(
    :db(DBIish.connect('SQLite', database => %connect-params<host>, |(:options<db>//{}))),
    :%options,
  );
}
