class DB::ORM::Quicky::Model {
  has %options;
  has $!dbtype;
  has %!statictypes; 
  has $!db;
  has $!table;
  has %!data;
  has @!changed;
  has $.id is rw = -1;
  has $.debug = False;
  has @.fields;
  has $!quote;

  submethod BUILD (:$!dbtype, :$!debug, :$!db, :$!table, :$!quote = '', :$skipcreate = False) {
    %!statictypes = 
        Pg => {
          In => {
            'double precision'  => Num,
            'integer'           => Int,
            'varchar'           => Str,
            'character varying' => Str,
            'text'              => Str,
          },
          Out => {
            Num => 'float',
            Int => 'integer',
            Str => 'varchar',
          },
          Degrade => @(
            Int => Int, 
            Num => Num, 
            Str => Str,
          )
        },
        mysql => {
          In => {
            'double precision'  => Num,
            'int'           => Int,
            'varchar'           => Str,
            'character varying' => Str,
            'text'              => Str,
          },
          Out => {
            Num => 'float',
            Int => 'int',
            Str => 'varchar',
          },
          Degrade => @(
            Int => Int, 
            Num => Num, 
            Str => Str,
          )
        },
        SQLite => {
          In => {
            'float'   => Num,
            'integer' => Int,
            'varchar' => Str,
            'text'    => Str,
          },
          Out => {
            Num => 'float',
            Int => 'integer',
            Str => 'varchar',
          },
          Degrade => @(
            Int => Int,
            Num => Num,
            Str => Str,
          )

        },
    ;
    $!quote = '`' if $!quote eq '' && $!dbtype eq 'mysql';
    $!quote = '"' if $!quote eq '';
    
    if ! $skipcreate {
      my $sql;
      if $!dbtype eq 'Pg' && !self!pgtableexists {
        $sql = "CREATE TABLE {self!fquote($!table)} ( DBORMID integer );"; 
        self!do($sql) 
      }
      if $!dbtype eq 'mysql' && !so self!mysqltableexists {
        $sql = "CREATE TABLE {self!fquote($!table)} ( {self!fquote("DBORMID")} integer );";
        my $s = self!prepare($sql);
        $s.execute;
        $s.finish if $s.^can('finish');
      }
      if $!dbtype eq 'SQLite' && ! self!sqlitetableexists {
        $sql = "CREATE TABLE {self!fquote($!table)} ( DBORMID integer );";
        self!do($sql) 
      }
      $sql.say if $!debug && $sql;
    }
  }
  
  method !fquote($str) { return "$!quote" ~ "$str" ~ "$!quote"; }

  method get($key) {
    return %!data{$key};
  }

  method set(%data) {
    for %data.keys -> $k {
      next if "$k".uc eq 'DBORMID';
      @!changed.push("$k");
      %!data{"$k"} = %data{$k};
    }
    @.fields.push(|%data.keys.sort);
  }

  method delete {
    my $sql = "DELETE FROM {self!fquote($!table)} WHERE {self!fquote('DBORMID')} = ?";
    my $sth = self!prepare($sql);
    $sth.execute($!id);
    $sth.finish if $sth.^can('finish');
    $sql.say if $.debug;
    $!id = -1;
    for %!data.keys -> $k {
      next if "$k".uc eq 'DBORMID';
      @!changed.push("$k");
    }
  }

  method save {
    return if @!changed.elems == 0;
    my %types;
    %types = self!pggetcols if $!dbtype eq 'Pg';
    %types = self!sqlitegetcols if $!dbtype eq 'SQLite';
    %types = self!mysqlgetcols if $!dbtype eq 'mysql';
    #check types
    my @changes;
    my %modcols;
    my $offset = 0;
    for %!data.keys -> $col {
      my ($type, $cflag, $eflag);
      $eflag = $cflag = False;
      $eflag = True if $col eq any %types.keys;
      for %!statictypes{$!dbtype}<Degrade>.values -> $what {
        $type = %!statictypes{$!dbtype}<Out>{%$what.keys[0]} if %!data{$col} ~~ %$what.values[0];
        last if defined $type && $type !~~ Any;
        $cflag = True if %types{$col}<type> ~~ %$what.values[0];
      }
      #check varchar length
      if $eflag && %!statictypes{$!dbtype}<In>{$type} ~~ Str && %!data{$col}.chars > %types{$col}<length> {
        @changes.push("ALTER TABLE {self!fquote($!table)} ALTER COLUMN {self!fquote($col)} TYPE $type\({%!data{$col}.chars}\)");
        %modcols{$col} = "$type\({%!data{$col}.chars}\)";
      }
 
      $type = 'varchar' if !defined $type;
      $type = "$type\({%!data{$col}.chars}\)" if $type eq 'varchar';
      next if $eflag && !$cflag;
      if $eflag && $cflag {
        @changes.push("ALTER TABLE {self!fquote($!table)} ALTER COLUMN {self!fquote($col)} TYPE $type;");
        %modcols{$col} = "$type";
      } else {
        @changes.push("ALTER TABLE {self!fquote($!table)} ADD COLUMN {self!fquote($col)} $type;");
        %modcols{$col} = "$type";
        $offset++;
      }
    }
    #run table type updates
    if $!dbtype ne 'SQLite' || %modcols.keys.elems ==  0 + $offset {
      for @changes -> $sql {
        try {
          self!do($sql);
          $sql.say if $.debug;
          CATCH { .say; }
        };
      }
    } else {
      self!sqlitemodcolumns(%types, %modcols);
    }
    #build insert
    if !defined($!id) || $.id == -1 {
      try {
        my $sql = "ALTER TABLE {self!fquote($!table)} ADD COLUMN {self!fquote('DBORMID')} integer;";
        $sql.say if $.debug;
        self!do($sql);
      };
      my $idsql = "SELECT MAX({self!fquote('DBORMID')}) DBORMID FROM {self!fquote($!table)} LIMIT 1;";
      my $idsth = self!prepare($idsql);
      $idsth.execute();
      $idsql.say if $.debug;
      my @a = $idsth.fetchrow_array;
      $idsth.finish if $idsth.^can('finish');
      $!id   = (@a.elems > 0 && "{@a[0] || ''}".chars > 0 ?? @a[0].Int !! 0) + 1; 
      $idsql = "INSERT INTO {self!fquote($!table)} ({self!fquote('DBORMID')}) VALUES (?)";
      $idsth = self!do($idsql, $!id); 
      $idsql.say if $.debug;
    }
    my @insert = map { %!data{"$_"} }, @!changed;
    my @column = map { "{self!fquote($_)}"     }, @!changed;
    #save data
    my $sql = "UPDATE {self!fquote($!table)} SET {@column.join(' = ?, ')} = ? WHERE {self!fquote('DBORMID')} = ?;";
    my $sth = self!prepare($sql);
    my $r   = $sth.execute(@(@insert, $!id));
    $sth.finish if $sth.^can('finish');
    $sql.say if $.debug;
    
    @!changed = ();
  }

  method !prepare($sql) {
    $sql.say if $.debug;
    return $!db.prepare($sql);
  }

  method !do($sql, *@args) {
    $sql.say if $.debug;
    return $!db.do($sql, |@args);
  }

  method !pgtableexists {
    my $s = self!prepare('select count(*) c from pg_tables where schemaname = ? and tablename = ?');
    $s.execute(('public', $!table));
    my $c = ($s.fetchrow_hashref)<c>;
    $s.finish if $s.^can('finish');
    return $c > 0 ?? True !! False;
  }
  
  method !pggetcols {
    my %types;
    my $sth = self!prepare('select column_name as n, data_type as t, character_maximum_length as l from INFORMATION_SCHEMA.COLUMNS where table_name = ?');
    $sth.execute($!table);
    my %columns;
    while (my $row = $sth.fetchrow_hashref) {
      %columns{$row<n>} = { type => $row<t>, length => $row<l> ~~ /^ \d+ $/ ?? $row<l>.Int !! -1 };
    }

    for %columns.keys -> $k {
      %types{"$k"} = { type => %!statictypes{$!dbtype}<In>{%columns{$k}<type>}, length => %columns{$k}<length> };
    }
    $sth.finish if $sth.^can('finish');
    return %types;
  }

  method !sqlitetableexists {
    my $s = self!prepare('select count(sql) c from sqlite_master where tbl_name = ? and type = ?;');
    $s.execute(($!table, 'table'));
    my $c = ($s.fetchrow_hashref)<c>;
    $s.finish if $s.^can('finish');
    return $c > 0 ?? True !! False;
  }

  method !sqlitegetcols {
    my %types;
    my $sth = self!prepare('select sql from sqlite_master where tbl_name = ? and type = ?;');
    $sth.execute(($!table, 'table'));
    my $cols = $sth.fetchrow_hashref<sql>;
    $cols ~~ s/ ^ .*? '(' (.*) ')' .*? $ /$<>[0]/;
    my @column = $cols.split(/ \s* ',' \s* /);
    my %columns;
    for @column -> $c {
      my @d = $c.trim.reverse.split($c.ords[0] == 34 ?? '" ' !! ' ', 2);
      my $len = -1;
      if @d[1] ~~ / ^ 'varchar' / {
        @d[1].match(/ \d+ /);
        $len  = $<>;
        @d[1] = 'varchar';
      }
      @d[0] ~~ s/ ^ '"' //;
      @d[0] ~~ s/ '"' $ //;
      %types{"{@d[0]}"} = { type => %!statictypes{$!dbtype}<In>{@d[1]}, length => $len.Int }; 
    }
    $sth.finish if $sth.^can('finish');
    return %types;
  }

  method !sqlitemodcolumns(%types, %mods) {
    my @cmd;
    my $sql = "CREATE TABLE {self!fquote("tmp_$!table")} ( ";
    for %types.keys -> $k {
      $sql ~= "{self!fquote($k)} ";
      my $type;
      for %!statictypes{$!dbtype}<In>.keys -> $v {
        $type = $v if %!statictypes{$!dbtype}<In>{$v} ~~ %types{$k}<type>;
        last if defined $type;
      }
      $type = 'varchar' if !defined $type;
      $type ~= "({%types{$k}<length>})" if $type eq 'varchar';
      $sql ~= " {$type}, " if $k ne %mods.keys.any;
      $sql ~= " {%mods{$k}}, " if $k eq %mods.keys.any;
    }
    
    $sql ~~ s/', ' $/);/;

    @cmd.push($sql);

    @cmd.push("INSERT INTO {self!fquote("tmp_$!table")} SELECT * FROM {self!fquote($!table)};");
    @cmd.push("DROP TABLE {self!fquote($!table)};");
    @cmd.push("ALTER TABLE {self!fquote("tmp_$!table")} RENAME TO {self!fquote($!table)};");

    for @cmd -> $cmd {
      self!do($cmd);
    }
  }

  method !mysqltableexists {
    my $s = self!prepare('select count(*) c from information_schema.tables where table_name = ?');
    $s.execute(($!table));
    my $c = ($s.fetchrow_hashref)<c>;
    $s.finish if $s.^can('finish');
    return $c > 0 ?? True !! False;
  }


  method !mysqlgetcols {
    my %types;
    my $sth = self!prepare('select column_name as n, data_type as t, character_maximum_length as l from INFORMATION_SCHEMA.COLUMNS  where table_name = ?');
    $sth.execute($!table);
    my %columns;
    while (my $row = $sth.fetchrow_hashref) {
      %columns{$row<n>} = { type => $row<t>, length => $row<l> ~~ /^ \d+ $/ ?? $row<l>.Int !! -1 };
    }

    for %columns.keys -> $k {
      %types{"$k"} = { type => %!statictypes{$!dbtype}<In>{%columns{$k}<type>}, length => %columns{$k}<length> };
    }
    $sth.finish if $sth.^can('finish');
    return %types;
  }

};
