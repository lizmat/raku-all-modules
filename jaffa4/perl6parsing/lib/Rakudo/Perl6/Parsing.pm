use Perl6::Grammar:from<NQP>; 
use Perl6::Actions:from<NQP>; 

use QRegex:from<NQP>; 

use nqp;

unit class Rakudo::Perl6::Parsing;


has Mu $.parser;

#say Perl6::Parsing.new();
has @.tokens;

has $.text;

method new() {
  self.bless(  );
}

method parse($text)
{
  my $str = '#soething
;
#anotherone
#anotherone
=begin comment

=end comment
   my $b=4; $b++; { say \'hello\' ; if ($b~~/regex/) {} #somthing 
 } #end of all

sub test($f)
{

}
';
  my $*LINEPOSCACHE;
  $!text  = $text;
  $!parser := Perl6::Grammar.parse( $text, :actions(Perl6::Actions.new())  ); 

  return $!parser;
}

has %visited_objects;
has %visited_matches;

has $.callback;

multi method walktree($isprint, $level,$key1="root")
{
  %visited_objects= ();
  %visited_matches = ();
  self.walk($isprint,$!parser, $level,$key1);
}

multi method walksubtree($isprint,Mu $tree, $level,$key1?)
{
  %!visited_objects= ();
  %!visited_matches = ();
  self.walk($isprint,$tree, $level,$key1);
}

method printree()
{
  self.walktree(True,0,"root");
}

method walk($isprint,Mu $tree, $level,$key1?)
{
#say ">>level"~$level;
#if ($level>40)
{
 #exit 0;
}
#say ">>"~$isprint;
  my $type = $tree.HOW.name($tree);

  my $indent = "  " x $level;
  if ($isprint)
  {
    print "{$indent}level:"~$level;
# print "{$indent}entering by key:"~$key1;
    print " "~$tree.HOW.name($tree);
    say " bool:"~$tree.Bool;
  }
 
  my $id = nqp::objectid($tree);
 if (%!visited_objects{$id}:exists)
{  say "this subtree exists already, not expanding" if $isprint;
  return ;
}

%!visited_objects{$id} = True;
  
  if ($type eq "List")
  {
    #say "parcel "~$tree[0];
    for @($tree) -> $i
    {
        
      say "{$indent}parcel "~$i.HOW.name($i) if $isprint;
      self.walk($isprint,$i,$level+1,"parcel "~$level);
    }
    return;
  }
  
  if ($type eq "Pair" or $type eq "Str")
  {
    return;
  }
  
  if (!$tree.Bool)
  {
    say "{$indent}bool:"~$tree.hash.elems if $isprint;
    say  "{$indent}bool:"~$tree.list.elems if $isprint;
    say  "{$indent}bool:"~+$tree if $isprint;
  }
  #if $tree.^can('from')
  if ($type eq "NQPMatch")
  {
    say "{$indent}Str:"~$tree.Str~" from:"~$tree.from~" to:"~$tree.to if $isprint;
    %visited_matches{$tree.from}.push( item ($key1,$tree.from,$tree.to) );
  }
  my $i=0;
  for $tree.list() ->$value 
  {
    say "{$indent}elem:"~$tree.list().elems  if $isprint;
      #exit 0;
    self.walk($isprint,$value,$level+1,$key1~" "~$i++);
  }
  
  my Mu $h := $tree.hash();
  
  for keys $tree.hash() ->$key 
  {
   #say "{$indent}key0:";
    say "{$indent}key:"~$key if $isprint;
    if ($key)
    {
        self.walk($isprint,$tree.hash(){$key},$level+1,$key);
    }
  }
  
}


method dumpranges()
{
  my $str;
  for sort { $^a <=> $^b },  keys %visited_matches 
  {
    $str~=  %visited_matches{$_}.perl~"\n";
  }
  return $str;

}
method tokenise()
{
  self.walktree(False,0,"root");
  my @tokens;
  my %starts_ends;
  
  for sort { $^a <=> $^b },  keys %visited_matches 
  {
    #say "hello $_" ~  %visited_matches{$_}.perl;
    my $min_to = 999999999999;
    #my $type = "";
    my %types;
    for @(%visited_matches{$_}) -> @item
    {
      %starts_ends{$_}{@item[0]} = @item[2]; #start
      %starts_ends{@item[2]}{@item[0]~"_end"} = -1; #end
    }
  }

  my $prevpos = -1;
  for sort { $^a <=> $^b },  keys %starts_ends
  { 
   #say $prevpos;
   if ($prevpos != -1)
   {
     push @tokens, [$(%starts_ends{$prevpos}),$prevpos, $_];
    #say "here" ~@tokens.elems;
   }
   $prevpos = $_;
   
  }
  @!tokens= @tokens;
  return @tokens;
}

method dumptokens()
{
  my $str;
  for @.tokens -> @rec
  {
  # print "something";
   # print "<"~@rec[0].perl~">@rec[2]-@rec[1]\n";
   #print "<"~@rec.perl~">\n";
    $str~= "{@rec[1]}<"~(join ",",keys @rec[0])~">"~substr($!text,@rec[1],@rec[2]-@rec[1])~"<<<\n";
  }
  return $str;
}
