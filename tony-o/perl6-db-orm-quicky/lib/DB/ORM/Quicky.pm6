use DBIish;
use DB::ORM::Quicky::Model;
use DB::ORM::Quicky::Search;

class DB::ORM::Quicky {
  has $!db;
  has $!driver;
  has $.debug = False;
   
  method connect(:$driver, :%options) {
    $!db     = DBIish.connect($driver, |%options) or die $!;
    $!driver = $driver;
  }

  method create($table) {
    my $model = DB::ORM::Quicky::Model.new(:dbtype($!driver), :$table, :$!db, :$.debug);
    return $model;
  }

  method search($table, %params) {
    my $search = DB::ORM::Quicky::Search.new(:dbtype($!driver), :$table, :$!db, :%params, :$.debug);
    return $search;
  }
};
