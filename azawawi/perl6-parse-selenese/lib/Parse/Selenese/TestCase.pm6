
use v6;

class Parse::Selenese::TestCase {
  use Parse::Selenese::Command;

  has Str $.name is rw;
  has Str $.base_url is rw;
  has Parse::Selenese::Command @.commands is rw;
}
