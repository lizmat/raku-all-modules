use List::Util 'shuffle';

my $flavor = $ENV{flavor} || 'default';

my $case = config()->{case};

my $sparrowdo_options = config()->{sparrowdo}->{options}->{$flavor};

if ( ref $case eq 'HASH'){
  my @case = @{$case->{$flavor}};
  for my $c (shuffle(@case)){
    run_story('case' , { case => $c , sparrowdo_options => $sparrowdo_options });
  }
}else{
  run_story('case' , { case => $case , sparrowdo_options => $sparrowdo_options });
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

