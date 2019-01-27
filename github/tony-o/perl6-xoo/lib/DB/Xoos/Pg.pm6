use DB::Xoos;
unit class DB::Xoos::Pg does DB::Xoos;

use DB::Xoos::DSN;
use DBIish;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = 'Pg';
  $!prefix = %options<prefix> // '';
  self.load-models(%options<model-dirs>//[]);
}

multi method connect(Str:D $dsn, :%options) {
  my %connect-params = parse-dsn($dsn);

  die 'unable to parse DSN '~$dsn unless %connect-params.elems;

  my $db;
  my %db-opts = |(:%connect-params<db>//{});

  %db-opts<database> = %connect-params<db>   if %connect-params<db>;
  %db-opts<host>     = %connect-params<host> if %connect-params<host>;
  %db-opts<port>     = %connect-params<port> if %connect-params<port>;
  %db-opts<user>     = %connect-params<user> if %connect-params<user>;
  %db-opts<password> = %connect-params<pass> if %connect-params<pass>;

  $db = DBIish.connect('Pg', |%db-opts);

  self.connect(
    :$db
    :%options,
  );
}
