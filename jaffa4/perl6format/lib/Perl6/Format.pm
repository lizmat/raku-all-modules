use Perl6::Parsing;
class Perl6::Format;


constant $debug = 0;

#say Perl6::Parsing.new();
has @.tokens;



method new() {
  self.bless(  );
}

method format(%options,$text)
{
  my $parser = Perl6::Parsing.new();
  $parser.parse( $text ); 

  @!tokens = $parser.tokenise();

#say @!tokens.perl;

  if ( @!tokens == 0 ) {
    return;
  }
  
  my $newline     = 1;
  my $level       = 0;
  my $expectedpos = 0;
  my $mode        = -1;
  my @token_out;
  my $indentnext = 0;
  my $indentsize = %options<indentsize> // 2;
  my $nibble = False;

  for @!tokens.kv -> $i, @token
  {
    say @token.perl if $debug ;
    my $token =  $text.substr(@token[1],@token[2]-@token[1]);
    say ">>{$token}<<" if $debug ;
    if ( $token~~/\}$|^\}/ && (@!tokens.elems>$i+1 && (@!tokens[$i+1][0].exists_key("blockoid_end") || @!tokens[$i][0].exists_key("termaltseq_end") )) )
    { 
      $level--;
      say "level--"~$level if $debug ;
    }

    if ($newline)
    {
      if ($token~~/^\S/)
      {
        if (@token_out.elems>0 && @token_out[*-1].chars>0)
        {
          @token_out[*-1] =  @token_out[*-1] ~ (" " x ( $indentsize * $level ));
        }
      else
      {
   #say "here";
 #  exit 0;
        push @token_out, ( " " x ( $indentsize * $level ) );
      }
      say "here2{@token_out[*-1]}{$token}<<" if $debug ;
      }
      else
      {
        $token.=subst(/^<[\ \t]>+/, " " x ( $indentsize * $level ) );
        say "here{$token}<<" if $debug ;
      }
    $newline = 0;
    }
    if ($token~~/^\{|\{$/ && (@token[0].exists_key("blockoid") || @!tokens.elems>$i+1 && @!tokens[$i+1][0].exists_key("termaltseq")))
    { 
      $level++;
      say "level++"~$level if $debug ;
    }
    if (@token[0].exists_key("nibble"))
    {
      $nibble = True;
    }
    if (@token[0].exists_key("nibble_end"))
    {
      $nibble = False;
    }
#say "nibble:$nibble\<\<{$token}\>";
    if (!$nibble)
    {
      if ($token ~~ /\n/)
      {
  
        " "~~ /s/; # because perl6 buggy. this restores the start of regex search pos to 0.
        while ($token ~~ m:c/$<a>=(.*?\n)\s*$<b>=(\S\N*)||$<c>=(.*?\n)\s*$||$<d>=(.+)/)
        {
  #say $/.perl;
          if ($/<a>)
          {
  #say "0000";
            push @token_out, $/<a>;
            push @token_out, $/<b>;
            @token_out[*-1] =  " " x ( $indentsize * $level ) ~ @token_out[*-1];
          }
          elsif ($/<c>)
          {
  #say "c";
            push @token_out, $/<c>;
            $newline = 1;
          }
          else
          {
  #say "d";
            push @token_out, $/<d>;
          }
  
        }
      }
      else
      {
        push @token_out, $token;
      }
  #say "after";
  #say ">>>>{$/[0]}|||{$/[1]}<<<<";
  
    }
    else
    {
      push @token_out, $token;
    }

  }

#for @token_out
#{
# print $_;
#}

  return join "",@token_out;



}
