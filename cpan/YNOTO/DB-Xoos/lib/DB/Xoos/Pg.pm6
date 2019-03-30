use DB::Xoos;
unit class DB::Xoos::Pg does DB::Xoos;

use DB::Xoos::DSN;
use DB::Xoos::Pg::Dynamic;
use DB::Pg;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = 'Pg';
  $!prefix = %options<prefix> // '';
  my %dynamic = %options<dynamic-loader> ?? generate-structure(:db-conn($db)) !! ();
  self.load-models(%options<model-dirs>//[], :%dynamic);
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

  my $conninfo = join " ",
    ('dbname=' ~ %db-opts<database>),
    ('host=' ~ %db-opts<host>),
    ('user=' ~ %db-opts<user> if %db-opts<user>.defined),
    ('pass=' ~ %db-opts<password> if %db-opts<password>.defined);

  $db = DB::Pg.new(:$conninfo);

  self.connect(
    :$db
    :%options,
  );
}
