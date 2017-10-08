unit module Mangle;

our $command = 'translate-bin';

constant DEBUG = %*ENV<MANGLE_DEBUG>;

sub check-version {
  my $version = run 'translate-bin', '-v', :out;
  unless $version.out.get ~~ 'translate version 0.99' {
    say "Please install libtranslate";
    say "On Ubuntu: sudo apt-get install libtranslate-bin";
    say "On Fedora: dnf install libtranslate";
    say "Source is available at http://www.nongnu.org/libtranslate/";
    exit 1;
  }
}

multi sub translate($text) {
  state $fwd = False; $fwd = !$fwd;
  state $lang = 'fr'; if $fwd.so { $lang = <fr es de ru>.pick }
  translate($text, $lang, $fwd);
}

multi sub translate($text, $lang, $fwd where *.so) {
  my $p1 = run 'echo', $text, :out;
  my $p2 = run $command,
    '--services=systran',
    '--from=en', "--to=$lang",
    :in($p1.out), :out;
  $p2.out.get; my $result = $p2.out.get;
  say "en->{$lang}:{$result}" if DEBUG;
  return $result;
}

multi sub translate($text, $lang, $fwd where *.not) {
  my $p1 = run 'echo', $text, :out;
  my $p2 = run $command,
    '--services=systran',
    "--from=$lang", '--to=en',
    :in($p1.out), :out;
  $p2.out.get; my $result = $p2.out.get;
  say "{$lang}->en:$result" if DEBUG;
  return $result;
}

sub mangle($text) is export {
  check-version();
  say (translate($text) xx 10)[* - 1];
}
