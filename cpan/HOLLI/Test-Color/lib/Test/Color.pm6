use v6;

use Test;
use Terminal::ANSIColor;

our %COLORS =
  ok       => 'green on_default',
  nok      => 'red on_default',
  plan     => 'yellow on_blue',
  comment  => 'black on_white',
  bail-out => 'red on_yellow',
  default  => 'white on_default'
;

class Test::Color
{
  has $.handle;

  method close { $.handle.close; }

  method say ( *@_ ) {
      $.handle.say( |@_.map({ colorize($_.gist) }) );
  }

  method put ( *@_) {
      $.handle.put( |@_.map({ colorize($_.Str) }) );
  }

  sub colorize ( Str $tap ) {
    return color( color-of( $tap ) ) ~ $tap ~ color("default on_default");
  }

  sub color-of( Str $tap ) {
    return %COLORS{ color-key-of( $tap ) };
  }

  sub color-key-of( Str $tap )
  {
    return
      $tap ~~ /^ \s* ok /            ?? 'ok'       !!
      $tap ~~ /^ \s* not \s ok/      ?? 'nok'      !!
      $tap ~~ /^ \s* \d+\.\.\d+\s*$/ ?? 'plan'     !!
      $tap ~~ /^ \s* "#"/            ?? 'comment'  !!
      $tap ~~ /^ Bail \s out \!/     ?? 'bail-out' !!
                                        'default';
  }
}


sub EXPORT( $colors? )
{
  if $colors {
    for &($colors)() {
      %COLORS{ .key } = .value;
    }
  }

  Test::output()         = Test::Color.new( :handle($PROCESS::OUT) );
  Test::failure_output() = Test::Color.new( :handle($PROCESS::ERR) );
  Test::todo_output()    = Test::Color.new( :handle($PROCESS::OUT) );

  return {};
}

=begin pod

=head1 NAME

Test::Color - Colored Test - output

=head1 SYNOPSIS

  use Test;
  use Test::Color;
  use Test::Color sub { :ok("blue on_green"), :nok("255,0,0 on_255,255,255") };

=head1 DESCRIPTION

Test::Color uses L<Terminal::ANSIColor|https://github.com/tadzik/Terminal-ANSIColor> to color your test output.
Simply add the C<use Color> statement to your test script.

=head2 Setup

If you don't like the default colors, you can configure them by passing
an anonymous sub to the use statement.

The sub must return a hash; keys representing the output category
(one of <ok nok comment bail-out plan default>), and the values being
color commands as in L<Terminal::ANSIColor|https://github.com/tadzik/Terminal-ANSIColor>.

You can tweak the behaviour even further by setting output handles
of the C<Test> module directly.

    Test::output()         = Test::Color.new( :handle($SOME-HANDLE) );
    Test::failure_output() = Test::Color.new( :handle($SOME-HANDLE) );
    Test::todo_output()    = Test::Color.new( :handle($SOME-HANDLE) );

=head2 Caveat

This module works using escape sequences. This means that test suite
runners will most likely trip over it. The module is mainly meant for
the development phase, by helping to spot problematic tests in longish
test outputs.

=head1 AUTHOR

    Markus 'Holli' Holzer


=head1 COPYRIGHT AND LICENSE

Copyright ©  holli.holzer@gmail.com

License GPLv3: The GNU General Public License, Version 3, 29 June 2007
<https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


=end pod
