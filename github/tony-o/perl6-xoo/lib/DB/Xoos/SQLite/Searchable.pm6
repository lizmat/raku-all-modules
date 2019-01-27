use DB::Xoos::Searchable;
unit role DB::Xoos::SQLite::Searchable does DB::Xoos::Searchable;

has $!first-next;
has $.quote = {
  :identifier<`>,
  :value<">,
};

method search(%new-filter?, %options?) {
  return self
    unless %new-filter.defined || %options.defined;
  my (%option, %filter);
  if self!filter.keys {
    %filter = %(%(self!filter), %new-filter);
  } else {
    %filter = %new-filter;
  }
  if self!options.keys {
    %option = %(%(self!options), %options);
  } else {
    %option = %options;
  }
  my $clone = self.clone;
  $clone!set-filter(%filter) if %new-filter;
  $clone!set-options(%option) if %options;
  $clone!set-inflate(self!inflate);
  $clone;
}

method dump-filter {
  self!filter;
}

method dump-options {
  self!options;
}

method all(%filter?) {
  return self.search(%filter).all
    if %filter;
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql;
  my $sth   = self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
  my @rows  = $sth.allrows(:array-of-hash);
  my @rtv;
  for @rows -> $row {
    #inflate to model
    my $new-model;
    try {
      CATCH { default {
        warn $_;
        $new-model = $row;
      } }
      $new-model = self.row.new(:field-data($row), :!is-dirty, :driver(self.driver), :db(self.db), :model(self), :dbo(self.dbo));
    };
    @rtv.push($new-model);
  }
  @rtv;
}

method first(%filter?, :$next = False) {
  return self.search(%filter).first
    if %filter;
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql;
  my $sth   = $next && $!first-next ?? $!first-next !! self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
  $!first-next := $sth;
  my $row   = $sth.row(:hash);
  return Nil unless $row.keys.elems;
  my $new-model;
  try {
    CATCH { default {
      say 'not inflating: '~$row.perl;
      warn $_;
      $new-model = $row;
    } }
    $new-model = self.row.new(:field-data($row), :!is-dirty, :driver(self.driver), :db(self.db), :model(self), :dbo(self.dbo));
  };
  $new-model;
}

method next(%filter?) {
  return self.first(%filter, :next);
}

method count(%filter?) {
  return self.search(%filter).count
    if %filter;
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql(field-override => 'count(*) cnt');
  my $sth   = self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
  my @rows  = $sth.allrows(:array-of-hash);
  @rows[0]<cnt> // 0;
}

method update(%values, %filter?) {
  return self.search(%filter).update(%values)
    if %filter;
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql(:update, :update-values(%values));
  my $sth   = self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
}

method delete(%filter?) {
  return self.search(%filter).delete
    if %filter;
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql(:delete);
  my $sth   = self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
}

method insert(%field-data) {
  die 'Please connect to a database first'
    unless self.^can('db');
  my %query = $.sql(:insert, :update-values(%field-data));
  my $sth   = self.db.prepare(%query<sql>);
  $sth.execute(|%query<params>);
  Nil;
}

method sql($page-start?, $page-size?, :$field-override = Nil, :$update = False, :%update-values?, :$delete = False, :$insert = False) {
  my (@*params, $sql);

  if $update {
    $sql  = 'UPDATE ';
    $sql ~= self!gen-table(:for-update);
    $sql ~= self!gen-update-values(%update-values);
    $sql ~= self!gen-filters(key-table => self.table-name) if self!filter;
  } elsif $delete {
    $sql  = 'DELETE FROM ';
    $sql ~= self!gen-table(:for-update);
    $sql ~= self!gen-filters(key-table => self.table-name) if self!filter;
  } elsif $insert {
    $sql  = 'INSERT INTO ';
    $sql ~= self!gen-table(:for-update);
    $sql ~= ' ('~self!gen-field-ins(%update-values)~') ';
    $sql ~= 'VALUES ('~('?'x@*params.elems).split('', :skip-empty).join(', ')~')';
  } else {
    $sql = 'SELECT ';
    if $field-override {
      $sql ~= "$field-override ";
    } else {
      $sql   ~= self!gen-field-sels~' ';
    }
    $sql   ~= self!gen-table;
    $sql   ~= self!gen-joins;
    $sql   ~= self!gen-filters if self!filter;
    $sql   ~= self!gen-order;
  }
  { sql => $sql, params => @*params };
}

method !gen-update-values(%values) {
  ' SET '~%values.keys.map({ self!gen-quote($_, :table(''))~' = '~self!gen-quote(%values{$_})}).join(', ');
}

method !gen-field-sels {
  self!options<fields>.defined && self!options<fields>.keys
    ?? self!options<fields>.map({ self!gen-id($_) }).join(', ')
    !! '*';
}

method !gen-field-ins(%values) {
  my @cols;
  for %values -> $col {
    my ($key, $val) = $col.kv;
    @cols.push(self!gen-id($key));
    @*params.push($val);
  }
  @cols.join(', ');
}

method !gen-table(:$for-update = False) {
  ($for-update??''!!'FROM ')~(self.^can('table-name')
    ?? self!gen-id(self.table-name)~($for-update??''!!' as self')
    !! self!gen-id('dummy')~($for-update??''!!' as self'));
}

method !gen-quote(\val, $force = False, :$table) {
  if !$force && val =:= try val."{val.^name}"() {
    # not a container
    return self!gen-id(val, :$table);
  } else {
    push @*params, val;
    return '?';
  }
}

method !gen-id($value,:$table?) {
  my $qc = MY::<$!quote><identifier> // '"';
  my $sc = MY::<$!quote><separator>  // '.';
  my @s  = $value.split($sc);
  @s.prepend($table)
    if $table.defined && $table ne '' && @s.elems == 1;
  "{$qc}{@s.join($qc~$sc~$qc)}{$qc}";
}

method !gen-pairs($kv, $type = 'AND', $force-placeholder = False, :$key-table?, :$val-table?) {
  my @pairs;
  if $kv ~~ Pair {
    my ($eq, $val);
    if $kv.key ~~ Str && $kv.key eq ('-or'|'-and') {
      @pairs.push: self!gen-pairs($kv.value, $kv.key.uc.substr(1), $force-placeholder, :$key-table, :$val-table)~' )';
      $eq := 'andor';
    } elsif $kv.value ~~ Hash {
      $eq  := $kv.value.keys[0];
      $val := $kv.value.values[0];
    } elsif $kv.value ~~ Block && $kv.value.().elems == 2 {
      $eq  := $kv.value.()[0];
      $val := $kv.value.()[1];
    } elsif $kv.value ~~ Array {
      my @arg;
      for @($kv.value) -> $x {
        @arg.push( self!gen-quote($x, $force-placeholder) );
      }
      $eq  := 'in';
      @pairs.push: self!gen-id($kv.key, :table($key-table))~" $eq ("~@arg.join(', ')~")";
    } else {
      $eq  := '=';
      $val := $kv.value
    }
    @pairs.push: self!gen-id($kv.key, :table($key-table))~" $eq "~self!gen-quote($val, $force-placeholder, :table($val-table))
      if $eq ne ('andor'|'in');
  } elsif $kv ~~ Hash {
    for %($kv).pairs -> $x {
      @pairs.push: '( '~self!gen-pairs($x.key eq ('-or'|'-and') ?? $x.value !! $x, $x.key eq ('-or'|'-and') ?? $x.key.uc.substr(1) !! $type, $force-placeholder, :$key-table, :$val-table)~' )';
    }
  } elsif $kv ~~ Array {
    my $arg;
    for @($kv) -> $x {
      $arg = $x.WHAT ~~ List ?? $x.pairs[0].value !! $x;
      @pairs.push: '( '~self!gen-pairs($arg, $type, $force-placeholder, :$key-table, :$val-table)~' )';
    }
  }
  @pairs.join(" $type ");
}

method !gen-filters(:$key-table = 'self') {
  ' WHERE '~self!gen-pairs(self!filter, 'AND', True, :$key-table);
}

method !gen-join-str(Hash $attr where { $_<table>.defined && $_<on>.defined }) {
  my $join = ' ';
  $join   ~= $attr<type> ?? $attr<type> !! 'left outer';
  $join   ~= ' join ';
  $join   ~= self!gen-id($attr<table>);
  $join   ~= ' as '~$attr<as>
    if $attr<as>.defined;
  $join   ~= ' on ';
  $join   ~= self!gen-pairs($attr<on>, :key-table($attr<as>//$attr<table>), :val-table<self>);
  $join;
}

method !gen-order {
  my @pairs;
  if self!options<order-by>.defined {
    for @(self!options<order-by>) -> $order {
      @pairs.push(
        $order ~~ Pair
          ?? $order.key ~ ' ' ~ $order.value.uc
          !! "$order ASC"
      );
    }
  }
  @pairs.elems == 0 ?? '' !! ' ORDER BY ' ~ join(', ', @pairs);
}

method !gen-joins {
  my $joins = '';
  if self!options<join>.defined {
    if self!options<join> ~~ Array {
      for self!options<join>.values -> %x {
        $joins ~= self!gen-join-str(%x);
      }
    }
    $joins ~= self!gen-join-str(self!options<join>) if self!options<join> ~~ Associative;
  }
  $joins;
}
