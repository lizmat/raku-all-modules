unit class Ini::Storage;

use Path::Util;
#use dprint;
#save configuration settings

has $filename;

has $disk;

has $changed;

has %.hash;

has %.list;

has @.group;

method new($filename,$isdisk) {
 # my $proto    = shift;
 # my $filename = shift;
 # my $class    = ref($proto) || $proto;
 # my $isdisk   = shift;
 # my $self     = {};

  #definitions
  my $p = Path::Util.getdir($filename);
  #print "filepath [$p]";
  my $fn = $filename;
  if ( not defined $p ) {
    $p = %*ENV<USERPROFILE> // %*ENV<HOME>;
  #  d::w "settings", "p:$p";
    if ( defined $p ) {
      $fn= $p ~ Path::Util.fsseparator ~ Path::Util.getbasename($filename); 
    }
    else {
    #  $!filename = $filename;
    }
  }
  else {
   #$!filename = $filename;
  }
  #  say "here $isdisk";
  my $disk;
  if ( !defined($isdisk) || $isdisk  ) {
    $disk= 1;
  }
  else {
    $disk = 0;
  }
   # say "here $disk";
 # $!changed = 0;
  #bless( $self, $class );
  
 
  return self.bless(disk => $disk, filename => $fn, changed => 0);
 # return $self;
}

submethod BUILD(:$disk, :$filename, :$changed) {
        $!disk = $disk;
        $!filename = $filename;
        $!changed = $changed;
        
   if ( $disk ) {
   # say "before";
    my $status= self.ReadFile;
    if ( $status == 1 or $status == 0) {
  #    return $self;
    }
    else {
   #   return undef;
    }
  }
    }

submethod DESTROY {
  self.Flush;
}

method GetFilename {
  #say ">>>"~$!filename;
  return $!filename;
}

method SetFilename($newfn) {
  $!filename=$newfn;
  $!changed = 1;
}

method Read($key,$default) {
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  #print "XXread:%!hash{$group}{$entry}\n";
  #say "( $group, $entry ) %!hash.EXISTS-KEY($group)) %!hash.EXISTS-KEY($entry)";
  if ((not %!hash.EXISTS-KEY($group)) or
  (not  %!hash{$group}.EXISTS-KEY($entry) ))
  {
    return $default;
  }
  else
  {
    return %!hash{$group}{$entry};
  }
}

method Exchange($key,$key2) {
 $key ~~ /\/?(.+?)\/(.+)/;
 my ( $group, $entry ) = $/[0].Str, $/[1].Str;
 $key2 ~~ /\/?(.+?)\/(.+)/;
 my ( $group2, $entry2 ) =  $/[0].Str, $/[1].Str;
 if (%!hash.EXISTS-KEY($group) && %!hash{$group}.EXISTS-KEY($entry))
 {
  my $val=%!hash{$group}{$entry};
  if (%!hash.EXISTS-KEY($group2) && %!hash{$group2}.EXISTS-KEY($entry2))
  {
   my $val2=%!hash{$group2}{$entry2};
   %!hash{$group}{$entry}=$val2;
   %!hash{$group2}{$entry2}=$val;
   $!changed = 1;
  }
 }
}

method GetEntryName($group,$no is copy)
{
  $no--;
 return %!list{$group}[$no];
}

method FindRegInGroup($group)
{

}

method Write($key,$value) {
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  my $exists = 0;
  #print "write $group $entry $value\n";
  
  for ( @!group  ) {
    if ( $_ eq $group ) {
      $exists = 1;
    }
  }
  if ( not $exists ) {
    push @!group , $group;
  #  d::w "settings", "another group\n";
  }
  if ( %!hash{$group}{$entry}:exists ) {

    %!hash{$group}{$entry} = $value;
   #  print "hello2 write $group $entry $value\n";
  }
  else {
   # print "hello2\n";

    %!hash{$group}{$entry} = $value;
    %!list{$group}.push: $entry;
   
   # say "here $group $entry "~ %!list{$group}[0];
  }
  
  #say "list:"~%!list.perl;
#  for my $i ( @{ %!list{$group} } ) {
#    print "check $i=%!hash{$group}{$i}\n";
#  }
  $!changed = 1;
}

method Copy($obj) {
  for ( @( $obj.group ) ) {
    for ( @( $obj.list{$_} ) ) -> $i {
      self.Write( "/$_/$i", $obj.hash{$_}{$i} );
    }
  }
}

method CountEntries($group) {
  my $c;
  if (defined %!list{$group})
  {
    return +@( %!list{$group} );
  }
  return 0;
}

method CopyGroup($obj,$group,$newgroupname?) {
  $newgroupname = $newgroupname // $group;
  for  ( @( $obj.list{$group} ) ) -> $i {
    self.Write( "/$newgroupname/$i", $obj.hash{$group}{$i} );
  }
}

method DeleteEntry($key) {
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  #d::w "settings", "delete $group $entry\n";
  if ( defined %!hash{$group}{$entry} ) {
    %!hash{$group}{$entry}:delete;
    my $i = 0;
    for ( @( %!list{$group} ) ) {
      if ( $_ eq $entry ) {
        last;
      }
      $i++;
    }
   
    splice @( %!list{$group} ), $i, 1;
   # d::w "settings", "del:@{ %!list{$group} } $i\n";
    $!changed = 1;
  }
 # for my $i ( @{ %!list{$group} } ) {
 #   print "check $i=%!hash{$group}{$i}\n";
 # }
}

method RenameEntry($key,$keynew)
{
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  $keynew ~~ /\/?(.+?)\/(.+)/;
  my ( $groupnew, $entrynew ) =  $/[0].Str, $/[1].Str;
#  d::w "settings", "rename $group $entry\n";
  my $val;
  if ( %!hash{$group}{$entry}:exists and not 
   %!hash{$groupnew}{$entrynew}:exists) {
    $val=%!hash{$group}{$entry};
    %!hash{$group}{$entry}:delete;
    my $i = 0;
    for ( @( %!list{$group} ) ) {
      if ( $_ eq $entry ) {
        last;
      }
      $i++;
    }
   # d::w "settings", "del:@{ %!list{$group} } $i\n";
    splice @( %!list{$group} ), $i, 1;
    $!changed = 1;
    self.Write($keynew,$val);
  }
#  for my $i ( @{ %!list{$group} } ) {
#    print "check $i=%!hash{$group}{$i}\n";
#  }
}

method DeleteEntryFromArray($key)
{
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  $entry~~ /(.+?)(\d+)$/;
  my ($arrayname,$no)= $/[0].Str, $/[1].Str;
  d::w "settings", "deletefromarray $group $entry $arrayname,$no\n";
  if (not $/[0])
  {
    return;
  }
  self.DeleteEntry($key);
  my @list=  @( %!list{$group} );
  for  @list -> $i {
    if ($i~~ /$arrayname(\d+)$/)
    {
      if ($1>$no)
      {
        self.RenameEntry("$group/$arrayname"~$/[0].Str,"$group/$arrayname"~($/[0].Str-1));
      }
    }
    #print "check $i=%!hash{$group}{$i}\n";
  }
}

method GetLastArrayIndex($key)
{
 # my $array  = shift;
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $array ) = $/[0].Str, $/[1].Str;
  my $maxi=-1;
  for ( @( %!list{$group} ) ) {
        if (/^$array(\d+)$/)
        {

           if ($/[0].Str > $maxi)
           {
             $maxi=$/[0].Str;
           }
        }
  }
  return $maxi;
}

method DeleteGroup($group) {
  if ( %!hash.key_exists($group) ) {
    %!hash{$group}:delete;
    %!list{$group}:delete;
    $!changed = 1;
    my $i = 0;
    for  @!group  {
      if ( $_ eq $group ) {
        splice  @!group, $i, 1;
        last;
      }
      $i++;
    }
 #   for my $i ( @{ %!list{$group} } ) {
 #   print "check $i=%!hash{$group}{$i}\n";
#  }
  }
}

method GroupExists($group)
{

return  %!hash.EXISTS-KEY($group);

}



method Exists($key) {
  $key ~~ /\/?(.+?)\/(.+)/;
  my ( $group, $entry ) = $/[0].Str, $/[1].Str;
  return ( %!hash.EXISTS-KEY($group) and %!hash{$group}.EXISTS-KEY($entry) ); 
}

method GetGroups
{
return @!group;
}

method GetEntriesInGroup($group) {
  return %!hash{$group};
}

method FindIndexInArrayByValue($group,$arrayname,$value) {

my %ref=%(%!hash{$group});
  for (keys %ref)
    {
      if (/^($arrayname(\d+))$/)
       {
        if (%ref{$/[0].Str} eq $value)
        { return $/[0][0].Str;}
      }
    }
  return -1;
}

method FindAValueInRecordByKey($group,$arrayname,$value,$arrayname2) {
my $index=self.FindIndexInArrayByValue($group,$arrayname,$value);
return Mu if ($index==-1);

my $ref=%!hash{$group};
  for (keys %$ref)
    {
      if (/^($arrayname2(\d+))$/)
       {
        if ($/[0][0].Str eq $index)
        { return $ref{$/[0].Str};}
      }
    }
  return Mu;
}



method GetArrayInGroupK($key) {
$key ~~ /\/?(.+?)\/(.+)/;
my ( $group, $entry ) = $0,$1;
return self.GetArrayInGroupGE($group, $entry);
}




method GetArrayInGroupGE($group,$name) {
  my $ref=%!hash{$group};
  my $res;
  my @arr;
 # say "here $group "~%!hash{$group}.perl;
  for (keys %$ref)
    {
      if (/^($name(\d+))$/)
       {
      @arr[$/[0][0].Str]=$ref{$/[0].Str};
      }
    }
  return @arr;
}



##`(

method SetArrayInGroup ($group,$name,@arr) {
  my $ref=%!hash{$group};
  my $res;
 # my @arr;
  for (keys %$ref)
    {
     if (/^($name(\d+))$/)
       {
      self.DeleteEntry("$group/$_");
      }
    }
  #loop (my $i=0;$i<@($arr).elems;$i++)
   for (0..@arr.end) -> $i 
  {
 
  self.Write("$group/$name$i",@arr[$i]) if defined @arr[$i];
  }
}

#)


method ReadFile() {
  my $currgroup;
#  d::w "settings", "read file\n";

  my $f = $!filename;
  #say "entering $f";
  
  
  if ($!filename.IO ~~ :e ) {
  #  d::w "settings", "bele $this->{filename}\n";
  #  d::w "settings", "bele2 $this->{filename}\n";
    my $file = slurp $!filename;
    
    my $p = 0;

    while ( $file ~~ m:c($p)/^^\s*\[(\N+?)\]/ ) {
      push @!group , $/[0].Str;
      $currgroup = $/[0].Str;
    #  d::w "settings", "bele3 $currgroup\n";
        $p = $/.to;
      if ( defined $currgroup ) {
        while ( $file ~~ m:P5:c($p)/(?m)^\s*(\w+)\s*\=(.*)|^\s*\[(.+?)\]/) {
          if ( defined $2 ) {
            $p = $/[2].from - 1;
            last;
          }
          else
          {
            $p = $/.to;
          }
          my $decoded=$1;
          my $key=$0;
          #say "decoded $0 $1";
           $decoded~~s:g/\\x0a/\x0a/;
           $decoded~~s:g/\\x0d/\x0d/;
           $decoded~~s:g/\\\\/\\/;    
          %!hash{$currgroup}{$key} = $decoded;
      #    d::w "settings", "$currgroup: $key $decoded\n";
          push @( %!list{$currgroup} ), $key;
        }
      }
    }
  }
  else {
    return 0;
  }
  #say ">>>>>>"~%!list.perl;
  return 1;
}

method WriteFile {
 # d::w "settings", "WriteFile\n";
  my $F = open $!filename,:w or return "fileerror";
 # d::w "settings", "on\n";
  for ( @!group  ) {
    print $F: "[$_]\n";
    for @( %!list{$_} ) -> $i {
     my $encoded=%!hash{$_}{$i};
     #$DB::single=2;
      $encoded~~s:g/\\/\\\\/;
      $encoded~~s:g/\x0a/\\x0a/;
      $encoded~~s:g/\x0d/\\x0d/;
      print $F: "$i=$encoded\n";
   #   d::w "settings", "WriteFile:$_ $i\n";
    }
  }
  close #F;
  return 1;
}

method PrintGroup($group) {

 # d::w "settings", "[$group]\n";
    for  @( %!list{$group} ) ->  $i  {
      print  "$i=%!hash{$group}{$i}\n";
    }

}

method SetDisk($disk)
{
 $!disk= $disk;
}

method Flush {
#  d::w "settings", "flush $!changed\n";
  if ( $!disk and $!changed ) { self.WriteFile; }
  $!changed = 0;
}


