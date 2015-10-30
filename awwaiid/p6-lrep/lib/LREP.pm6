
class LREP::Message {
  has $.context is rw;
  has $.input is rw = "";
  has $.output is rw = "";
  method append($text) {
    $.output = $text;
  }
}

class LREP {

  use Linenoise;

  has $.context is rw;
  has $.composed is rw;

  # Ignore &handler
  sub echo_middleware(&handler) {
    -> $message {
      $message.append($message.input);
      $message;
    }
  }

  sub eval_middleware(&handler) {
    -> $message {
      if $message {
        my $eval_result = EVAL $message.input, context => $message.context;
        # TODO: Does the result here overwrite input? output? new thing?
        $message.input = $eval_result;
        &handler($message);
        $message;
        CATCH {
          default {
            # say "Message: [ $message ]";
            $message.output = "REPL Exception: $_";
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
        $message.input = $eval_result;
        $message
      } else {
        &handler($message);
      }
    }

  }

  sub print_middleware(&handler) {
    -> $message {
      my $result = &handler($message);
      # say "result: [ $result ]";
      say $result.output;
      $result;
    }
  }

  # Lets you do "look" to see what's around, short-cuts further plugins
  sub look_middleware(&handler) {
    -> $message {
      if $message.input ~~ /^look$/ {
        my @vars = $message.context.keys;
        $message.output = "VARS: {@vars}";
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
    # self.add_middleware(&shell_middleware);
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

