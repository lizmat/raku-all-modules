use v6;

## This is a base class for database driven models. 
## Your Model class must define a $.rowclass attribute, which must be
## either the class name or a type object representing a Row sub-class.

## TODO: Using the Row class, the ability to create the table described by it.
##       For this to work, we'll need to provide additional meta information.

class DB::Model::Easy {

  use DBIish;

  has $.rowclass;                 ## Our row class. Must be overridden.
  has $.driver;                   ## Driver for DBIish connection.
  has %.opts;                     ## Options for DBIish connection.
  has $.table;                    ## Our database table.
  has $.caller;                   ## The object that called us. Optional.

  has $!dbh;                      ## Our database handler.

  method dbh {
    if ! $!dbh.defined {
      $!dbh = DBIish.connect($.driver, |%.opts);
    }
    return $!dbh;
  }

  ## A sub-class representing a simple SQL SELECT statement.
  ## This has VERY basic commands. 
  ## If you need more control, use the prepare() and
  ## execute() methods of the Model directly instead of using get().
  class SelectStatement {
    has $.model;         ## Our parent model.
    has $.sql is rw;     ## The SQL text.
    has @.bind is rw;    ## The binding values.

    submethod BUILD (:$model, :$fields='*') {
      $!model = $model;
      $!sql = "SELECT $fields FROM {$model.table}";
    }

    method !is-where {
      if $!sql !~~ /WHERE/ {
        $!sql ~= ' WHERE';
      }
    }

    method !simple-where ($op, $or, %opts) {
      my $join = $or ?? 'OR' !! 'AND';
      self!is-where;
      $!sql ~= ' (';
      my @queries;
      for %opts.kv -> $key, $val {
        @queries.push: " $key $op ?";
        @!bind.push: $val;
      }
      $!sql ~= @queries.join(" $join");
      $!sql ~= ' )';
      return self;
    }

    method with (Bool :$or?, *%opts) {
      self!simple-where('=', $or, %opts);
    }

    method not (Bool :$or?, *%opts) {
      self!simple-where('!=', $or, %opts);
    }

    method gt (Bool :$or?, *%opts) {
      self!simple-where('>', $or, %opts);
    }

    method lt (Bool :$or?, *%opts) {
      self!simple-where('<', $or, %opts);
    }

    method gte (Bool :$or?, *%opts) {
      self!simple-where('>=', $or, %opts);
    }

    method lte (Bool :$or?, *%opts) {
      self!simple-where('<=', $or, %opts);
    }

    method like (Bool :$or?, *%opts) {
      self!simple-where('LIKE', $or, %opts);
    }

    method and {
      $!sql ~= ' AND';
      return self;
    }

    method or {
      $!sql ~= ' OR';
      return self;
    }

    ## Return a single row.
    method row {
      $!sql ~= ' LIMIT 1';
      my $stmt = $.model.prepare-select($!sql);
      my $results = $stmt.execute(|@!bind);
      if $results.elems > 0 {
        return $results[0];
      }
      return Nil;
    }

    ## Return all matching rows.
    method rows {
      my $stmt = $.model.prepare-select($!sql);
      return $stmt.execute(|@!bind);
    }
  } ## End of class SelectStatement.

  method row-class {
    my $class = $.rowclass;
    if ($class ~~ Str) {
      require $class;
      $class = ::($!rowclass);
    }
    return $class;
  }

  ## Represents a prepared SELECT statement. Returns an array of result objects.
  ## NOTE: Do not use this class with anything but SELECT statements.
  class PreparedSelectStatement {
    has $.model;
    has $.sth;

    method execute (*@bind) {
      my @results;
      $.sth.execute(|@bind);
      my $class = $.model.row-class;
      while $.sth.fetchrow-hash -> %hash {
        my $row = $class.new(:model(self), :data(%hash));
        @results.push: $row;
      }
      $.sth.finish;
      return @results;
    }
  }

  ## Return a SelectStatement object.
  method get ($fields='*') {
    SelectStatement.new(:model(self), :$fields);
  }

  ## Prepare a SELECT statement.
  method prepare-select ($statement) {
    my $sth = $.dbh.prepare($statement);
    PreparedSelectStatement.new(:model(self), :$sth);
  }

  ## Create a new row.
  method newrow (*%data) {
    my $class = self.row-class;
    return $class.new(:model(self), :%data, :new-item);
  }

  ## Prepare wrapper.
  method prepare ($statement) {
    $.dbh.prepare($statement);
  }

} ## end class DB::Model::Easy

