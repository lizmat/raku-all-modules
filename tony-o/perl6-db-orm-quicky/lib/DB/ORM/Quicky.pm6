use DBIish;
use DB::ORM::Quicky::Model;
use DB::ORM::Quicky::Search;

class DB::ORM::Quicky {
  has $!db;
  has $!driver;
   
  method connect(:$driver, :%options) {
    $!db     = DBIish.connect($driver, |%options, :RaiseError<1>) or die $!;
    $!driver = $driver;
  }

  method create($table) {
    my $model = DB::ORM::Quicky::Model.new(:dbtype($!driver), :$table, :$!db);
    return $model;
  }

  method search($table, %params) {
    my $search = DB::ORM::Quicky::Search.new(:dbtype($!driver), :$table, :$!db, :%params);
    return $search;
  }
};
