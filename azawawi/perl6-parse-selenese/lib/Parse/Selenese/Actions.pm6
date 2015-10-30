use v6;

class Parse::Selenese::Actions {

  use Parse::Selenese::Command;
  use Parse::Selenese::TestCase;
  use Parse::Selenese::TestSuite;
  use Parse::Selenese::TestCaseDef;

  my @commands;
  my @test_case_defs;

  method TOP($/) {
    make $<test_case>.defined ?? $<test_case>.ast !! $<test_suite>.ast;
  }

  method test_case($/) {
    my $t       = Parse::Selenese::TestCase.new;
    $t.name     = ~$<title><value>;
    $t.base_url = ~$<base_url><value>;
    $t.commands = @commands;
    make $t;
  }

  method test_suite($/) {
    my $t             = Parse::Selenese::TestSuite.new;
    $t.name           = ~$<title><value>;
    $t.test_case_defs = @test_case_defs;
    make $t;
  }

  method command($/) {
    my $cmd = Parse::Selenese::Command.new;
    $cmd.name = ~$<name>;
    $cmd.arg1 = ~$<target> if $<target>.defined;
    $cmd.arg2 = ~$<value>  if $<value>.defined;
    push @commands, $cmd;
    make $cmd;
  }

  method test_case_def($/) {
    my $def = Parse::Selenese::TestCaseDef.new;
    $def.name = ~$<name>;
    $def.url  = ~$<url>;
    push @test_case_defs, $def;
  }
}
