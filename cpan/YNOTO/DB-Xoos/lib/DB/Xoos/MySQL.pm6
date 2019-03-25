use DB::Xoos;
unit class DB::Xoos::MySQL does DB::Xoos;

use DB::Xoos::DSN;
use DB::MySQL;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = 'MySQL';
  $!prefix = %options<prefix> // '';
  self.load-models(%options<model-dirs>//[]);
}

multi method connect(Str:D $dsn, :%options) {
  my %connect-params = parse-dsn($dsn);

  die 'unable to parse DSN' ~ $dsn unless %connect-params.elems;
  my $db;
  my %db-opts = |(:%connect-params<db>//{});

  %db-opts<database> = %connect-params<db>   if %connect-params<db>;
  %db-opts<host>     = %connect-params<host> if %connect-params<host>;
  %db-opts<port>     = %connect-params<port> if %connect-params<port>;
  %db-opts<user>     = %connect-params<user> if %connect-params<user>;
  %db-opts<password> = %connect-params<pass> if %connect-params<pass>;

  $db = DB::MySQL.new(|%db-opts);
  $db.connect;

  self.connect(
    :$db,
    :%options,
  );
}
