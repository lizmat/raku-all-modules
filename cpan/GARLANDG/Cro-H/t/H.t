use v6;
use Test;
use Cro;
use Cro::H;

plan *;

=begin pod

The goal is to build this in the test file
=begin code

 ---------      _________________      -----------      ---------
| Source1 | -> |______     ______| -> | IntFilter | -> | IntSink |
 ---------            |   |            -----------      ---------
                      | H |
 ---------      ______|   |______      -----------      ---------
| Source2 | -> |_________________| -> | StrFilter | -> | StrSink |
 ---------                             -----------      ---------
=end code
=end pod

class Message does Cro::Message {
  has $.item;
}

class IntMessage is Message {
  has Int $.item;
}

class StrMessage is Message {
  has Str $.item;
}

class TestSource1 does Cro::Source {
  method produces() { Message }
  method consumes() { Message }
  method incoming() returns Supply {
    supply {
      emit 'hello' ;
      emit 35;
      emit 'falcon';
    }
  }
}

class TestSource2 does Cro::Source {
  method produces() { Message }
  method consumes() { Message }
  method incoming() returns Supply {
    supply {
      emit 72 ;
      emit 460;
      emit 'fox';
    }
  }
}

class H-Pipe does Cro::H {
  method produces() { Message }
  method consumes() { Message }
}

class IntSink does Cro::Sink {
  has Int $.sum;
  method consumes() { IntMessage }
  method sinker(Supply:D $pipeline) returns Supply {
    supply {
      whenever $pipeline {
        $!sum += $_.item;
      }
    }
  }
}

class StrSink does Cro::Sink {
  has Str @.strings;
  method consumes() { StrMessage }
  method sinker(Supply:D $pipeline) returns Supply {
    supply {
      whenever $pipeline {
        @!strings.append($_.item);
      }
    }
  }
}
class IntFilter does Cro::Transform {
  method consumes() { Message }
  method produces() { IntMessage }
  method transformer(Supply:D $pipeline) returns Supply {
    supply {
      whenever $pipeline {
        emit $_ if $_.item ~~ Int;
      }
    }
  }
}

class StrFilter does Cro::Transform {
  method consumes() { Message }
  method produces() { StrMessage }
  method transformer(Supply:D $pipeline) returns Supply {
    supply {
      whenever $pipeline {
        emit $_ if $_.item ~~ Str;
      }
    }
  }
}

my $int-sink = IntSink.new;
my $str-sink = StrSink.new;
my $h = H-Pipe.new;
my $pipe1 = Cro.compose(TestSource1, $h, IntFilter, $int-sink);
my $pipe2 = Cro.compose(TestSource2, $h, StrFilter, $str-sink);

ok $pipe1 ~~ Cro::Service, 'Successfully compose Service';
ok $pipe2 ~~ Cro::Service, 'Successfully compose Service';

$pipe1.start;
$pipe2.start;

ok $str-sink.strings.sort ~~ <falcon fox hello>, "StrSink gets all the values";
ok $int-sink.sum == 35 + 72 + 460, "IntSink gets all the values";

my $badpipe = Cro.compose(TestSource1, $h, IntFilter, $int-sink);
dies-ok { $badpipe.start }, 'Cannot place in more than 2 pipelines';

done-testing;
#vi:syntax = perl6
