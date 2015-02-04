use Perl6::Parsing;
class Perl6::Tracer;
constant $debug = 0;

has @.tokens;
method new() {
  self.bless(  );
}
method trace(%options,$text)
{
  my $parser = Perl6::Parsing.new();
  $parser.parse( $text ); 
  @!tokens = $parser.tokenise();
  #say @!tokens.perl;
  if ( @!tokens == 0 ) {
    return;
  }
  my @*token_out;
  my $lineno = 1;
  
  sub insertline()
  {
    push @*token_out, "note \"line  $lineno\";";
  }
  
  my $tracenext = False;


  insertline();
  
  for @!tokens.kv -> $i, @token
  {
    say @token.perl if $debug ;
    my $token =  $text.substr(@token[1],@token[2]-@token[1]);
    say ">>{$token}<< $tracenext" if $debug ;
    if ($token ~~ /\n/)
    {
      " "~~ /s/; # because perl6 buggy. this restores the start of regex search pos to 0.
      while ($token ~~ m:c/\n/)
      {
        $lineno++;
      }
    }
    my $trace = False;
   
    
    if ( $token~~/\}$|^\}/ && (@!tokens.elems>$i+1 && (@!tokens[$i+1][0].exists_key("blockoid_end"))))
    {
      insertline();
      $tracenext = False;
    }
     if ((@token[0][0].exists_key("routine_def_end")))
      { 
        $tracenext = True;
      }
      
      if ((@token[0][0].exists_key("routine_declarator")))
      { 
        $tracenext = False;
      }
    if ( $token~~/\;$|^\;/)
    {
      for %(@token[0]).keys -> $key
      {
        #say "key:$key\n";
        if $key ~~ /:s parcel (\d+)_end/
        {
          $tracenext = True;
        }
      }
    }
    elsif ($tracenext)
    {
      for %(@token[0]).keys -> $key
      {
        #say "key:$key\n";
        if $key ~~ /:s parcel (\d+)<!before _>/
        {
          $trace = True;
        }
      }
      if ($trace)
      {
        insertline();
        $trace = False;
        $tracenext = False;
      }
    }
    if ($trace)
    {
      push @*token_out, $token ;
      insertline();
    }
    else
    {
      push @*token_out, $token ;
    }
    if ($token~~/^\{|\{$/ && (@token[0].exists_key("blockoid")))
    { 
      $tracenext = True;
    }
  }
  #for @token_out
  #{
  # print $_;
  #}
  return join "",@*token_out;
}
