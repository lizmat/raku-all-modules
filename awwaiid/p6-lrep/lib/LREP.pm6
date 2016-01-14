
class LREP::Message {
  use IO::String;
  has $.context is rw;
  has $.input is rw = "";
  has IO::String $.output is rw = IO::String.new;
}

class LREP {

  use MONKEY-SEE-NO-EVAL;
  use Linenoise;

  has $.context is rw;
  has $.composed is rw;

  # Do nothing, end the chain
  sub null_middleware(&handler) {
    -> $message {
      $message;
    }
  }

  # Echo input -> output
  sub echo_middleware(&handler) {
    -> $message {
      $message.output.print($message.input);
      &handler($message);
    }
  }

  # Insane self-replacing func that keeps nesting the scope with each eval,
  # thereby allowing you to create lexical vars
  our &f;
  sub context-eval($code, $context) {
    my $result;
    &LREP::f ||= -> $c { EVAL($c, context => $context) };
    &LREP::f('&LREP::f = -> $c { use MONKEY-SEE-NO-EVAL; EVAL($c) }; ' ~ $code);
  }

  # Filter input from a code-string to the EVAL result
  sub eval_middleware(&handler) {
    -> $message {
      if $message {
        my $eval_result = context-eval($message.input, $message.context);
        $message.input = $eval_result.gist;
        &handler($message);
        CATCH {
          default {
            $message.output.print("REPL Exception: $_");
            $message;
          }
        }
      }
      $message;
    }
  }

  # Lets you do ">ls", short-cuts further plugins
  sub shell_middleware(&handler) {
    -> $message {
      if $message.input ~~ /^\>/ {
        my $input = $message.input;
        $input ~~ s/^\>//;
        my $eval_result = shell $input;
        $message.output.print($eval_result);
        $message
      } else {
        &handler($message);
      }
    }

  }

  # Take the current output and write it to STDOUT
  # You'll only want this on the CLIENT side of the middleware chain
  sub print_middleware(&handler) {
    -> $message {
      my $result = &handler($message);
      say ~$result.output;
      $result;
    }
  }

  # Lets you do "look" to see what's around, short-cuts further plugins
  sub look_middleware(&handler) {
    -> $message {
      if $message.input ~~ /^look$/ {
        my @vars = $message.context.keys;
        $message.output.print("VARS: {@vars}");
      } else {
        &handler($message);
      }
      $message;
    }
  }

  # Ignores input and instead gets data from the user
  sub read_middleware(&handler) {
    -> $message {
      my $cmd = linenoise '> ';
      last if !$cmd.defined;
      $message.input = $cmd;
      linenoiseHistoryAdd($cmd);
      my $result = &handler($message);
      # say "ReadHandleResult: [ $result ]";
      $result;
    }
  }

  method add_middleware(*@middleware) {
    $.composed ||= -> $message { $message };
    for @middleware -> $mid {
      $.composed = $mid($.composed);
    }
  }

  method start {
    self.add_middleware(&echo_middleware);
    self.add_middleware(&eval_middleware);
    self.add_middleware(&shell_middleware);
    self.add_middleware(&look_middleware);
    self.add_middleware(&read_middleware);
    self.add_middleware(&print_middleware);
    loop {
      my $blank_message = LREP::Message.new(context => $.context);
      &($.composed)($blank_message);
    }
  }

  our sub here {
    my $context = CALLER::;
    my $repl = LREP.new(context => $context);
    $repl.start;
  }

}

