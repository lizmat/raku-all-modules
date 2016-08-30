use v6;
use Test;
use lib 'lib';
use Net::OSC::Message;

plan 18;

#diag Net::OSC::Message.^methods.map({ $_.perl }).join: "\n";

my Net::OSC::Message $message;
lives-ok {
  $message .= new(
    :args<Hey 123 45.67>
  );
}, "Instantiate message";

diag "OSC type map:\n" ~ $message.type-map.map({ $_.join(' => ') ~ "\n"});

is $message.args, <Hey 123 45.67>, "get args";

is $message.type-string, 'sid', "build type-string";

ok $message.args('xyz', -987, -65.43), "Add args to message";

is $message.args, <Hey 123 45.67 xyz -987 -65.43>, "get args post addition";

is $message.type-string, 'sidsid', "build type-string post addition";


diag "package tests:";

my Buf $packed-message;
lives-ok  { $packed-message = $message.package; },                          "package message";

my Net::OSC::Message $post-pack-message;
lives-ok  { $post-pack-message .= unpackage($packed-message); },           "unpackage message";

is        $post-pack-message.path,         $message.path,         "post pack path";

for $post-pack-message.args.kv -> $k, $v {
  given $v -> $value {
    when $value ~~ Rat {
      ok        ($value > $message.args[$k]-0.1 and $value < $message.args[$k]+0.1),     "post pack Rat arg\[$k], $value ~=~ { $message.args[$k] }";
    }
    default {
      is        $value,                    $message.args[$k],     "post pack arg\[$k]";
    }
  }
}

is        $post-pack-message.type-string,  $message.type-string,  "post pack type-string";

#test 32bit mode
my Net::OSC::Message $message32;
lives-ok {
  $message32 .= new(
    :args<Hey 123 45.67>
    :is64bit(False)
  );
}, "Instantiate 32bit message";

is $message32.type-string, 'sif', "Rat is type f in 32bit message";
