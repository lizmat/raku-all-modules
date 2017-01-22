use DB::ORM::Quicky::Model;

class DB::ORM::Quicky::Search {
  has $.sth is rw;
  has %.params;
  has $.table;
  has $.db;
  has $.dbtype;
  has $.error is rw = Any;
  has $.debug = False;
  has $!quote = '';
  has $!cursor = 0;

  method all {
    self.search;
    return Nil if $.error !~~ Any;
    my @rows;
    while my $row = $!sth.fetchrow_hashref {
      my $n = DB::ORM::Quicky::Model.new(:$.table, :$.db, :$.dbtype, :skipcreate(True));
      $n.set(%($row));
      $n.id = $row<DBORMID>;
      @rows.push($n);
    }
    $.sth.finish if $.sth.^can('finish');
    $!cursor = 0;
    return @rows;
  }

  method first {
    $!cursor = 0;
    return $.next;
  }

  has $.CC is rw = 0;
  method next {
    $!cursor = 0 if $!cursor !~~ / ^ \d+ $ /;
    self.search(True);
    return Nil if $.error !~~ Any;
    my $row = $!sth.fetchrow_hashref;
    my $n = DB::ORM::Quicky::Model.new(:$.table, :$.db, :$.dbtype, :skipcreate(True));
    return Nil if %($row).keys.elems == 0;
    $n.set(%($row));
    $n.id = $row<DBORMID>;
    $!sth.finish if $.sth.^can('finish');
    $!cursor++;
    return $n;
  }

  method delete {
    self.search(False, 'DELETE', ());
  }

  method count {
    self.search(False, 'SELECT COUNT(*) c');
    my $c = $!sth.fetchrow_hashref<c>;
    $!sth.finish if $.sth.^can('finish');
    return $c;
  }

  method !fquote($str) {
    my $quote = $str.starts-with($!quote) ?? '' !! $!quote; 
    return $quote ~ $str ~ $quote; 
  }

  method search($index? = False, $method? = 'SELECT *', @sort? = (DBORMID => 'asc',) ) {
    $!quote = '`' if $!quote eq '' && $!dbtype eq 'mysql';
    $!quote = '"' if $!quote eq '';
    my $sql = '';
    my @val;
    for %!params.keys.sort({ $^b eq '-join' && $^a ne '-join' ?? More !! $^a eq '-join' ?? Less !! $^a cmp $^b }) -> $key {
      my %ret = %(self!processtosql($key));
      if %ret<sql> ne '' && $sql eq '' && $key ne '-join' {
        $sql ~= 'WHERE ';
      } elsif %ret<sql> ne '' && $key ne '-join' {
        $sql ~= ' AND ';
      }
      $sql ~= %ret<sql>;
      @val.push($_) for @(%ret<val>); 
    }
    $sql = "$method FROM {self!fquote($.table)} $sql ";
    $sql ~= "ORDER BY " if @sort.elems > 0;
    for @sort -> $pair {
      $sql ~= "{self!fquote($pair.key)} {$pair.value}," if $pair ~~ Pair;
      $sql ~= "{self!fquote($pair)}," if $pair !~~ Pair;
    };
    $sql ~~ s/ ',' $ / / if @sort.elems > 0;
    if so $index {
      $sql ~= self!postgrescursor($!cursor) if $!dbtype eq 'Pg';
      $sql ~= self!mysqlcursor($!cursor) if $!dbtype eq 'mysql';
      $sql ~= self!sqlite3cursor($!cursor) if $!dbtype eq 'SQLite';
    }
    DB::ORM::Quicky::Model.new(:$.table, :$.db, :$.dbtype);
    my $rval = False;
    try {
      $sql.say if $!debug;
      $.sth = $.db.prepare($sql);
      $.sth.execute(@val);
      $rval = True;
      $.error = Any;
      CATCH { .say; }
    };
    $.error = $!db.errstr if not $rval;
    return $rval;
  }

  method !processtosql($key, %params = %.params, :$in-join = Nil) {
    my $str = '';
    my @val;
    if $key.lc eq '-and' || $key.lc eq '-or' {
      my $ao = $key.lc eq '-and' ?? 'AND ' !! 'OR ';
      $str ~= '(';
      for @(%params{$key}) -> $next {
        if $next.value ~~ Hash|Array {
          my %t = %(self!processtosql($next.key, $next, :$in-join));
          $str ~= %t<sql> ~ " $ao";
          @val.push($_) for @(%t<val>);
        } elsif $next ~~ Pair {
          my %t = %(self!processtosql($next.key, %($next), :$in-join));
          $str ~= %t<sql> ~ " $ao";
          @val.push($_) for @(%t<val>);
        } elsif $next ~~ Hash {
          my %t = %(self!processtosql($next, %params{$key}, :$in-join));
          $str ~= %t<sql> ~ " $ao";
          @val.push($_) for @(%t<val>);
        } 
      }
      $str ~~ s/[ 'OR ' | 'AND ']$/)/;
    } elsif $key.lc eq '-join' { 
      $str ~= %params{$key}<-type> // 'left outer';
      $str ~= ' join ' ~ %params{$key}<-table>;
      $str ~= ' on ';
      for @(%params{$key}<-on>) -> $next {
        my %ret = %(self!processtosql($next.key, $next, in-join => %params{$key}<-table>));
        $str ~= %ret<sql>;
        @val.push($_) for @(%ret<val>);
      }
    } elsif %params{$key} ~~ Array {
      $str ~= '(';
      for @(%params{$key}) -> $v {
        $str ~= "{self!fquote($key)} = ? OR ";
        @val.push($v);
      }
      $str ~~ s/'OR ' $/)/;
    } else {
      if $key.lc eq '-raw' {
        if %params{$key} ~~ Pair {
          $str ~= %params{$key}.key;
          if %params{$key} ~~ Array {
            @val.push($_) for @(%params{$key}.value);
          } else {
            @val.push(%params{$key}.value);
          }
        } else {
          $str ~= %params{$key};
        }
      } elsif %params{$key} ~~ Pair && %params{$key}.key.lc eq ('-gt','-lt','-eq', '-like').any {
        my $op = %params{$key}.key.lc;
        $op = $op eq '-gt' ?? '>' !! $op eq '-lt' ?? '<' !! $op eq '-like' ?? 'like' !! '=';
        $str ~= "{($in-join ?? self!fquote($in-join) ~ '.' !! '') ~ self!fquote($key)} $op {$in-join ?? self!fquote($!table) ~ '.' ~ self!fquote(%params{$key}.value) !! '?'}"; 
        @val.push(%params{$key}.value) unless $in-join;
      } else { 
        $str ~= "{($in-join ?? self!fquote($in-join) ~ '.' !! '') ~ self!fquote($key)} = {$in-join ?? self!fquote($!table) ~ '.' ~ self!fquote(%params{$key}) !! '?'} ";
        @val.push(%params{$key}) unless $in-join;
      }
    }
    return { sql => $str, val => @val };
  }

  method !postgrescursor($offset, $count = 1) {
    return "LIMIT $count OFFSET $offset";
  }

  method !mysqlcursor($offset, $count = 1) {
    return "LIMIT $offset, $count";
  }

  method !sqlite3cursor($offset, $count = 1) {
    return "LIMIT $offset, $count";
  }
};
