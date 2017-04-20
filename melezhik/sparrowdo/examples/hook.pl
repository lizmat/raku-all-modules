use List::Util 'shuffle';

my $case = config()->{case};

if ( ref $case eq 'ARRAY'){
  for my $c (shuffle(@$case)){
    run_story('case' , { case => $c });
  }
}else{
  run_story('case' , { case => $case });
}

