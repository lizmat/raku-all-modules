use v6;

unit module JS::Minify;

# return true if the character is allowed in identifier.
sub is-alphanum(Str $x) returns Bool {
  ord($x) > 126 || '$\\'.contains($x) || $x ~~ / \w /.Bool;
}

sub is-endspace(Str $x) returns Bool {
  $x ~~ "\n"|"\f"|"\r";
}

sub is-whitespace(Str $x) returns Bool {
  $x ~~ / \h /.Bool || is-endspace $x;
}

# New line characters before or after these characters can be removed.
# Not + - / in this list because they require special care.
sub is-infix(Str $x) returns Bool {
  ",;:=&%*<>?|\n".contains: $x;
}

# New line characters after these characters can be removed.
sub is-prefix(Str $x) returns Bool {
  '{([!'.contains($x) || is-infix $x;
}

# New line characters before these characters can removed.
sub is-postfix(Str $x) returns Bool {
  '})]'.contains: $x;
}

sub get(%s) returns List { 
  given %s<input>.elems {
    when *>0 {
      unless %s<input_pos> <= %s<input>.elems {
        ["", %s<last_read_char>, %s<input_pos>];
      }
      my Str $char = %s<input>[%s<input_pos>];
      my Str $last_read_char = %s<input>[%s<input_pos>++];
      $char ?? $char !! "", $last_read_char, %s<input_pos>;
    }
    default {
      die 'no input';
    }
  }
}

# print a
# move b to a
# move c to b
# move d to c
# new d
#
# i.e. print a and advance
sub step-chr-a(%s) returns Hash {
  %s<lastnws> = %s<a> unless is-whitespace %s<a>;
  %s<last>    = %s<a>;
  send-chr-out %s;
}

# sneeky output %s<a> for comments
sub send-chr-out(%s) returns Hash {
  %s<output>.send: %s<a>;
  delete-chr-a %s;
}

# move b to a
# move c to b
# move d to c
# new d
#
# i.e. delete a
sub delete-chr-a(%s) returns Hash {
  %s<a> = %s<b>;
  delete-chr-b %s;
}

# move c to b
# move d to c
# new d
#
# i.e. delete b
sub delete-chr-b(%s is copy) returns Hash {
  (%s<b>, %s<c>) = (%s<c>, %s<d>);
  (%s<d>, %s<last_read_char>, %s<input_pos>) = get %s;
  return %s;
}

# put string and regexp literals
# when this sub is called, %s<a> is on the opening delimiter character
sub put-literal(%s is copy) returns Hash {
  my Str $delimiter = %s<a>; # ', " or /
  %s = step-chr-a %s;
  repeat {
    while (%s<a> eq '\\') { # escape character only escapes the next one character
      %s = (%s
            ==> step-chr-a()
            ==> step-chr-a());
    }
    %s = step-chr-a %s;
  } until (%s<last> eq $delimiter || !%s<a>);

  given %s<last> {
    when !$delimiter { # ran off end of file before printing the closing delimiter
      die 'unterminated single quoted string literal, stopped' if $delimiter eq '\'';
      die 'unterminated double quoted string literal, stopped' if $delimiter eq '"';
      die 'unterminated regular expression literal, stopped';
    }
    default { %s }
  }

}

# If %s<a> is a whitespace then collapse all following whitespace.
# If any of the whitespace is a new line then ensure %s<a> is a new line
# when this function ends.
sub collapse-whitespace(%s is copy) returns Hash {
  while (is-whitespace(%s<a>) &&
         is-whitespace(%s<b>)) {
    %s<a> = "\n" if (is-endspace(%s<a>) || is-endspace(%s<b>));
    %s = delete-chr-b %s; # delete b
  }
  return %s;
}

# Advance %s<a> to non-whitespace or end of file.
# Doesn't print any of this whitespace.
sub skip-whitespace(%s is copy) returns Hash {
  while (is-whitespace(%s<a>)) {
    %s = delete-chr-a %s;
  }
  return %s;
}

# Advance %s<a> to non-whitespace or end of file
# If any of the whitespace is a new line then print one new line.
sub preserve-endspace(%s is copy) returns Hash {
  %s = collapse-whitespace(%s);
  if is-endspace(%s<a>) && !is-postfix(%s<b>) {
    %s = step-chr-a(%s);
  }
  skip-whitespace(%s);
 }

sub on-whitespace-conditional-comment(Str $a, Str $b, Str $c, Str $d) returns Bool {
  is-whitespace($a) && $b eq '/' && ('/*'.contains($c) &&  $d eq '@').Bool;
}

# Shift char or preserve endspace toggle
sub process-conditional-comment(%s) returns Hash {
  given on-whitespace-conditional-comment(|%s{'a' .. 'd'}) {
    when * eq True { step-chr-a %s }
    default { preserve-endspace %s }
  }
}

# Handle + + and - -
sub process-double-plus-minus(%s) returns Hash {
  given %s<a> {
    when is-whitespace(%s<a>) {
      (%s<b> eq %s<last>) ?? step-chr-a(%s) !! preserve-endspace(%s);
    }
    default { %s }
  }
};

# Handle potential property invocations
sub process-property-invocation(%s) returns Hash {
  (given %s<a> {
     when $_ && is-whitespace($_) {
       # if %s<b> is '.' could be (12 .toString()) which is property invocation. If space removed becomes decimal point and error.
      (%s<b> && (is-alphanum(%s<b>) || %s<b> eq '.')) ?? step-chr-a(%s) !! preserve-endspace(%s);
     }
     default { %s }
   });
}

#
# process-comments
#
multi sub process-comments(%s is copy where {%s<b> eq '/'}) returns Hash { # a division, comment, or regexp literal
  my Bool $cc_flag = %s<c> eq '@'; # tests in IE7 show no space allowed between slashes and at symbol

  repeat {
    %s = $cc_flag ?? send-chr-out %s !! delete-chr-a %s;
  } until (!%s<a> || is-endspace(%s<a>));

  # Return %s
  (given $cc_flag {
     when $_ { # True
       (%s
        ==> step-chr-a() # cannot use preserve-endspace(%s) here because it might not print the new line
        ==> skip-whitespace());
     }
     when %s<last> && !is-endspace(%s<last>) && !is-prefix(%s<last>) {
       return preserve-endspace %s;
     }
     default {
       return skip-whitespace %s;
     }
  });

}

multi sub process-comments(%s is copy where {%s<b> eq '*'}) returns Hash { # slash-star comment
  my Bool $cc_flag = %s<c> eq '@'; # test in IE7 shows no space allowed between star and at symbol

  repeat { 
    %s = $cc_flag ?? send-chr-out %s !! delete-chr-a %s;
  } until (!%s<b> || (%s<a> eq '*' && %s<b> eq '/'));

  die 'unterminated comment, stopped' unless %s<b>; # %s<a> is asterisk and %s<b> is foreslash

  # Return %s
  (given $cc_flag {
     when $_ { # True
       (%s
        ==> send-chr-out() # the *
        ==> send-chr-out() # the /
        # inside the conditional comment there may be a missing terminal semi-colon
        ==> preserve-endspace());
     }
     default { # the comment is being removed

      %s = delete-chr-a %s; # the *
      %s<a> = ' ';  # the /
      %s = collapse-whitespace %s;

      if (%s<last> && %s<b> &&
          ((is-alphanum(%s<last>) && ( is-alphanum(%s<b>) || %s<b> eq '.')) ||
           (%s<last> eq '+' && %s<b> eq '+') ||
           (%s<last> eq '-' && %s<b> eq '-') )) { # for a situation like 5-/**/-2 or a/**/a

        # When entering this block %s<a> is whitespace.
        # The comment represented whitespace that cannot be removed. Therefore replace the now gone comment with a whitespace.

        return step-chr-a %s;

      } elsif (%s<last> && !is-prefix(%s<last>)) {

        return preserve-endspace %s;

      } else {

        return skip-whitespace %s;

      }
    }
  });
}

multi sub process-comments(%s is copy where {%s<lastnws> && 
                           (')].'.contains(%s<lastnws>) ||
                           is-alphanum(%s<lastnws>))}) returns Hash {  # division
  %s
  ==> step-chr-a()
  ==> collapse-whitespace()
  # don't want closing delimiter to
  # become a slash-slash comment with
  # following conditional comment
  ==> process-conditional-comment();
}


multi sub process-comments(%s is copy where {%s<a> eq '/' and %s<b> eq '.' }) returns Hash {
  %s
  ==> collapse-whitespace()
  ==> step-chr-a();
}

multi sub process-comments(%s is copy) returns Hash {

  %s
  ==>put-literal()
  ==> collapse-whitespace()
  # we don't want closing delimiter to
  # become a slash-slash comment with
  # following conditional comment
  ==> process-conditional-comment();
}

#
# process-char
#
multi sub process-char(%s where {%s<a> eq '/'}) returns Hash { # a division, comment, or regexp literal
  process-comments %s;
}

multi sub process-char(%s where { "'\"".contains(%s<a>) }) returns Hash { # string literal
  %s
  ==> put-literal()
  ==> preserve-endspace();

}

multi sub process-char(%s where { '+-'.contains(%s<a>) }) returns Hash { # careful with + + and - -
  %s
  ==> step-chr-a()
  ==> collapse-whitespace()
  ==> process-double-plus-minus();
}

multi sub process-char(%s where { is-alphanum(%s<a>) }) returns Hash { # keyword, identifiers, numbers
  %s
  ==> step-chr-a()
  ==> collapse-whitespace()
  ==> process-property-invocation();
}

multi sub process-char(%s where { ']})'.contains(%s<a>) }) returns Hash {
  %s
  ==> step-chr-a()
  ==> preserve-endspace();
}

multi sub process-char(%s is copy) returns Hash {
  %s
  ==> step-chr-a()
  ==> skip-whitespace();
}

# Decouple the output processing.
# Either send output to a client
# provided Channel, or to a fully
# minified string.
#
# Output to Stream
#
multi sub output-manager(Channel $output, Channel $stream) returns Promise {
  start {
    # Read from client supplied channel
    $output.list.map: -> $c {
      # Exit when 'exit'
      if $c eq 'exit' {
        $stream.close;
        last;
      }
      # Stream to client channel
      $stream.send($c);
    }
    return;
  }
}
#
# Output to String
#
multi sub output-manager(Channel $output) returns Promise {
  start {
    my Str $output_text;
    # Read from client supplied channel
    $output.list.map: -> $c {
      # Exit when 'exit'
      last if $c eq 'exit';
      # Store to output
      $output_text ~= $c;
    }

    # Return fully minified result when
    # not streaming to client
    $output_text;
  }
}

#
# js-minify
#
sub js-minify(:$input!, Str :$copyright = '', :$stream, Int :$strip_debug = 0) is export {

  # Immediately turn hash into a hash reference so that notation is the same in this function
  # as others. Easier refactoring.

  # Capture inpute / readchars from file into string
  my Str $input_new = ($input.WHAT ~~ Str ?? $input !! $input.readchars.chomp);

  # Store all chars in List
  my Str @input_list = (given $strip_debug {
                        when 1  { $input_new.subst( /';;;' <-[\n]>+/, '', :g) }
                        default { $input_new }
                        }).split("", :skip-empty).cache;

  # hash reference for "state"
  my %s = input          => @input_list,
          strip_debug    => $strip_debug,
          last_read_char => 0,
          input_pos      => 0,
          output         => Channel.new,
          last           => Str, # assign for safety
          lastnws        => Str; # assign for safety

  # Capture output either to client supplied stream (Channel)
  # or to $output as string to return upon completion.
  my Promise $output = (given $stream {
                          when Channel { output-manager(%s<output>, $stream) }
                          default      { output-manager(%s<output>) }
                        });

  # Print the copyright notice first
  if ($copyright) {
    %s<output>.send("/* $copyright */");
  }

  # Initialize the buffer (first four characters to analyze)
  repeat {
    (%s<a>, %s<last_read_char>, %s<input_pos>) = get %s; 
  } while (%s<a> && is-whitespace(%s<a>));
  (%s<b>, %s<last_read_char>, %s<input_pos>)   = get %s; 
  (%s<c>, %s<last_read_char>, %s<input_pos>)   = get %s;
  (%s<d>, %s<last_read_char>, %s<input_pos>)   = get %s; 

  # Wrap main character processing in Promise 
  # to decouple it from output process
  start {
    while %s<a> { # on this line %s<a> should always be a
                  # non-whitespace character or '' (i.e. end of file)

      if (is-whitespace(%s<a>)) { # check that this program is running correctly
        die 'minifier bug: minify while loop starting with whitespace, stopped';
      }
        
      # Each branch handles trailing whitespace and ensures
      # %s<a> is on non-whitespace or '' when branch finishes
      %s = process-char %s;
    };


    # Return \n if input included it
    %s<output>.send('\n') if %s<input>.tail eq "\n";

    # Send 'done' to exit react/whenever block
    %s<output>.send: 'exit';

  }

  # return output
  $output.result unless $stream ~~ Channel;

}

