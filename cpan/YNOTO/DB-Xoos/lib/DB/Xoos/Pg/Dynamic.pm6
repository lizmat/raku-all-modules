use DB::Xoos::DSN;
use DB::Pg;
unit module DB::Xoos::Pg::Dynamic;

my %queries =
  list-tables    => "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';",
  list-columns   => "select is_nullable nullable, column_name as \"name\", data_type \"type\", case when substring(column_default, 0, 8) = 'nextval' then true else false end auto_increment, character_maximum_length length from INFORMATION_SCHEMA.COLUMNS where table_name = \$1",
  list-keys      => "SELECT c.column_name \"name\", c.data_type \"type\" FROM information_schema.table_constraints tc JOIN information_schema.constraint_column_usage AS ccu USING (constraint_schema, constraint_name) JOIN information_schema.columns AS c ON c.table_schema = tc.constraint_schema AND tc.table_name = c.table_name AND ccu.column_name = c.column_name WHERE constraint_type = 'PRIMARY KEY' and tc.table_name = \$1",
  list-relations => "SELECT tc.table_name t1_name, kcu.column_name c1_name, ccu.table_name t2_name, ccu.column_name c2_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema WHERE tc.constraint_type = 'FOREIGN KEY' AND (tc.table_name= \$1 or ccu.table_name = \$1)",
;

my %translate =
  'character varying' => 'varchar',
;

sub column-sort {
  ($^a.value<is-primary-key>//False) && !($^b.value<is-primary-key>//False) 
    ?? -1
    !! (!$^a.value<is-primary-key>//False) && ($^b.value<is-primary-key>//False)
      ?? 1
      !!  $^a.key cmp $^b.key
  ;
}

sub generate-structure (Str :$dsn?, :$db-conn?, Bool :$dry-run = False, :@tables? = []) is export {
  die "Please provide :dsn or :db-conn" unless $dsn.defined || $db-conn.defined;
  my $db = $db-conn;
  if !$db-conn.defined {
    my $parsed-dsn = parse-dsn($dsn);
    my $module     = "DB::Xoos::{$parsed-dsn<driver>.tc}";

    CATCH { default { .say; } }

    $db = DB::Pg.new(:conninfo(
      join ' ',
      ('dbname=' ~ $parsed-dsn<db>),
      ('host=' ~ $parsed-dsn<host>),
      ('user=' ~ $parsed-dsn<user> if $parsed-dsn<user>.defined),
      ('pass=' ~ $parsed-dsn<pass> if $parsed-dsn<pass>.defined),
    ));
    #$db.connect($dsn);
  }

  my @define-tables = @tables.elems ?? @tables !! $db.db.query(%queries<list-tables>).arrays;
  { note 'No tables were found in database'; exit 1; }()
    unless @define-tables.elems;

  my %files;
  for @define-tables.map({ $_[0] }) -> $table {
    my @columns   = $db.db.query(%queries<list-columns>, $table).hashes;
    my @keys      = $db.db.query(%queries<list-keys>, $table).hashes;
    my @relations = $db.db.query(%queries<list-relations>, $table).hashes;

    my %col-data;
    my %relations;
    for @columns -> $col {
      %col-data{$col<name>} = {
        type     => %translate{$col<type>}//$col<type>,
        nullable => $col<nullable> eq 'YES' ?? True !! False,
        ($col<auto_increment> ?? auto-increment => True !! ()),
        ($col<length>.defined ?? length => $col<length> !! ()),
      };
    }
    for @keys -> $key {
      %col-data{$key<name>}<is-primary-key> = True;
      %col-data{$key<name>}<nullable> = False;
    }
    for @relations -> $rel {
      my $key = $rel<t1_name> eq $table ?? '1' !! '2';
      my $oky = $key eq '1' ?? '2' !! '1';
      %relations{$rel{"t{$oky}_name"}} = %(
        ($key eq '2' ?? :has-many !! :has-one),
        model  => $rel{"t{$oky}_name"}.split('_').map({.tc}).join,
        relate => {
          $rel{"c{$key}_name"} => $rel{"c{$oky}_name"},
        },
      );
    }
    %files{$table.split('_').map({ .tc }).join} = {
      name      => $table.split('_').map({ .tc }).join,
      table     => $table,
      columns   => %col-data,
      relations => %relations,
    };
  }
  %files;
}
