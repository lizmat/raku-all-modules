use DBIish;
use DB::ORM::Quicky::Model;
use DB::ORM::Quicky::Search;

class DB::ORM::Quicky {
  has $!db;
  has $!driver;
  has $.debug = False;
  has %.config;
  has $!quote = Any;
  has $!col-id = Any;
   
  method connect(:$driver, :%options) {
    $!db     = DBIish.connect($driver, |%options) or die $!;
    $!driver = $driver;
  }

  method create($table) {
    my $model = DB::ORM::Quicky::Model.new(:dbtype($!driver), :$table, :$!db, :$.debug, :orm(self));
    return $model;
  }

  method search($table, %params) {
    my $search = DB::ORM::Quicky::Search.new(:dbtype($!driver), :$table, :$!db, :%params, :$.debug, :orm(self));
    return $search;
  }

  method default-id {
    if Any ~~ $!col-id {
      if %.config<default-col-id>.defined {
        $!col-id = %.config<default-col-id>;
      } elsif $*SQL-COL-ID {
        $!col-id = $*SQL-COL-ID;
      } else {
       $!col-id = 'DBORMID';
      }
    }
    $!col-id;
  }

  method quote($str) {
    if Any ~~ $!quote {
      if %.config<quote>.defined {
        $!quote = %.config<quote>;
      } elsif $*SQL-QUOTE {
        $!quote = $*SQL-QUOTE;
      } else {
        $!quote = '"' if ($!quote // '') eq '' && $!driver ne 'pg';
        $!quote = '`' if ($!quote // '') eq '' && $!driver eq 'mysql';
      }
    }
    my $quote = $str.starts-with($!quote) ?? '' !! $!quote; 
    return $quote ~ $str ~ $quote; 
  }
};
