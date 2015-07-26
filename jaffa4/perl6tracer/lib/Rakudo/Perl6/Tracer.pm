use Rakudo::Perl6::Parsing;
unit class Rakudo::Perl6::Tracer;
constant $debug = False;

has @.tokens;
has %options;
has $lineno;
has $text;



method new() {
  self.bless(  );
}

method insertline($p)
  {
    my $rest = "";
    if %options<showline>
    {
      my $line = "";
      for @!tokens[$p..*] -> @token {
       my $token =  $text.substr(@token[1],@token[2]-@token[1]);
        if ($token ~~ /(.*?)\n/)
        {
           $line~= $0;
           last;
        }
        else
        {
         $line~= $token;
        }
      
      }
      $rest =" $line";
      $rest~~s:g/(<[{"$@%]>)/\\$0/;
      
    
    }
    if %options<compiletime> 
    {
      push @*token_out, "BEGIN \{note \"line  $lineno$rest\";};";
    }
    else
    {
      push @*token_out, "note \"line  $lineno$rest\";";
    }
  }
  
method trace(%options,$text)
{
  my $parser = Rakudo::Perl6::Parsing.new();
  %!options = %options;
  $!text = $text;
  $parser.parse( $text ); 
  note "before tokenise" if $debug;
  @!tokens = $parser.tokenise();
  note "after tokenise" if $debug;
  #say @!tokens.perl;
  if ( @!tokens == 0 ) {
    return;
  }
  my @*token_out;
  $lineno = 1;
  
  
  
  my $tracenext = False;


  self.insertline(0);
  
  note "before for" if $debug;
  
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
   
    
    if ( $token~~/\}$|^\}/ && (@!tokens.elems>$i+1 && (@!tokens[$i+1][0].EXISTS-KEY("blockoid_end"))))
    {
      self.insertline($i);
      $tracenext = False;
    }
     if ((@token[0][0].EXISTS-KEY("routine_def_end")))
      { 
        $tracenext = True;
      }
      
      if ((@token[0][0].EXISTS-KEY("routine_declarator")))
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
        self.insertline($i);
        $trace = False;
        $tracenext = False;
      }
    }
    if ($trace)
    {
      push @*token_out, $token ;
      self.insertline($i);
    }
    else
    {
      push @*token_out, $token ;
    }
    if ($token~~/^\{|\{$/ && (@token[0].EXISTS-KEY("blockoid")))
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
