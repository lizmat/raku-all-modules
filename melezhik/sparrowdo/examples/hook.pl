use List::Util 'shuffle';

my $case = config()->{case};

if ( ref $case eq 'ARRAY'){
  for my $c (shuffle(@$case)){
    run_story('case' , { case => $c });
  }
}else{
  run_story('case' , { case => $case });
}

my @s;

select(STDERR);

for my $s (Outthentic::Story::Stat->failures){
  @s = ( $s->{path}, ( join ' ', map { "$_:$s->{vars}->{$_}" } keys %{$s->{vars}} ) );
  write;
}

format STDERR_TOP =

//////////////////////////////////
/// Custom Report ( Failures ) ///
//////////////////////////////////

.

format STDERR =
@* @*
$s[0], $s[1]
.

