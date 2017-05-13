unit module System::Parse;

sub follower(@path, $idx, $PTR) {
  die "Attempting to find \$*{@path[0].uc}.{@path[1..*].join('.')}"
    if !$PTR.^can("{@path[$idx]}") && $idx < @path.elems;
  return $PTR."{@path[$idx]}"()
    if $idx+1 == @path.elems;
  return follower(@path, $idx+1, $PTR."{@path[$idx]}"());   
}

sub merge-tree(@ptr, Bool :$copy = False) {
  my $vkey = @ptr[*-2].keys[0] 
    if @ptr.elems > 1;
  $vkey //= '';
  if $copy || (@ptr.elems == 2 && @ptr[*-1].keys.elems > 0 && @ptr[*-1]{@ptr[*-1].keys[0]}.defined) { 
    if @ptr[*-1] ~~ Str {
      @ptr[*-2] = @ptr[*-1];
    } else { 
      $vkey = @ptr[*-1].keys[0];
      @ptr[*-2]{$vkey} = @ptr[*-1]{$vkey};
    }
  } else {
    @ptr[*-1].keys.map({
      @ptr[*-2]{@ptr[*-2].keys[0]}{$_} = @ptr[*-1]{$_}
        unless $copy;
    }) if @ptr.elems > 1 && @ptr[*-2].keys.elems == 1 && @ptr[*-2]{"$vkey"}.defined && @ptr[*-1] ~~ Hash &&
          !$copy;
    @ptr[*-2]{@ptr[*-2].keys[0]} = @ptr[*-1]
      if @ptr.elems > 1 && @ptr[*-2].keys.elems == 1 && !@ptr[*-2]{"$vkey"}.defined;
  }
  @ptr.pop if @ptr.elems > 1;
}

sub data-resolve($world) {
  if $world ~~ Array {
    my @action;
    for @($world) -> $data {
      if $data ~~ Hash {
        my $new-item = system-collapse(%($data));
        @action.push( $new-item );
        next;
      }
      @action.push($data);
    }
    return @action;
  }
  $world;
}

sub system-collapse(%data, %tree?, @ptr?) is export {
  my ($PTR, @path, @versions, $key);
  my $MAIN = !@ptr.elems;
  my $c    = %data.keys.elems;
  @ptr.push(%tree)
    unless @ptr.elems;
  for %data.keys -> $k {
    $c--;
    merge-tree(@ptr, :copy) 
      if @ptr.elems > 1 && $MAIN;
    given $k {
      when /^'by-kernel'/ { 
        $PTR = $*KERNEL;
      }
      when /^'by-distro'/ {
        $PTR = $*DISTRO;
      }
      when /^'by-backend'/ {
        $PTR = $*BACKEND;
      }
      default {
        $PTR = Nil;
        $key = $k;
        @ptr.push({ $k => Nil });
      }
    };
    if !$PTR.defined {
      my $ptr-elems = @ptr.elems;
      if %data{$k} ~~ Hash {
        system-collapse(%data{$k}, %tree, @ptr);
      } else{
        @ptr.push( data-resolve(%data{$k}) );
      }
      merge-tree(@ptr, :copy($c == 0 && $MAIN && @ptr.elems <= 2));
      next;
    }
    @path = $k.split('.');
    my $val = follower(@path, 1, $PTR);
    if $val ~~ Version {
      my @version-keys = %data{$k}.keys.map({ 
        my $suffix = $_.substr(*-1);
        %(
          version  => Version.new($suffix eq '-' || $suffix eq '+' ?? $_.substr(0, *-1) !! $_),
          suffix   => $suffix eq '-' || $suffix eq '+' ?? $suffix !! Nil,
          data-key => $_,
        );
      }).sort({ $^a<version> cmp $^b<version> }).reverse;
      for @version-keys -> $v {
        next unless 
          $v<version> cmp $val ~~ Same ||
          ($v<version> cmp $val ~~ Less && $v<suffix> eq '+') ||
          ($v<version> cmp $val ~~ More && $v<suffix> eq '-');
        my $rval = %data{$k}{$v<data-key>} ~~ Hash ??
          system-collapse(%data{$k}{$v<data-key>}, %tree, @ptr) !!
          %data{$k}{$v<data-key>};

        die 'Cannot make a decision ..'
          if Nil ~~ $rval;
        @ptr.push( $rval );
        merge-tree(@ptr);
        return;
      }
    } else {
      @versions = %data{$k}.keys.sort({ $^a eq "" ?? 1 !! $^a cmp $^b }); #sort empty key "" last
      my $tree = @versions.grep($val).first // (%data{$k}{""}.defined ?? "" !! Nil);
      die 'Cannot make a decision ..'
        if Nil ~~ $tree;
      if !$tree.defined {
        @ptr.push( %data{$k} // Nil );
      } else {
        system-collapse(%data{$k}{$tree}, %tree, @ptr)
          if %data{$k}{$tree} ~~ Hash;
        @ptr.push( %data{$k}{$tree} )
          unless %data{$k}{$tree} ~~ Hash;
      }
      merge-tree(@ptr, :copy($c == 0 && $MAIN));
      return @ptr[0];
    }
  }
  merge-tree(@ptr, :copy) 
    if $MAIN && @ptr.elems > 1;
  %tree;
}
