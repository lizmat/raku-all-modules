use v6;

unit module Minify::JS;

# return true if the character is allowed in identifier.
sub is-alphanum($x) {
  return '$\\'.contains($x) || ord($x) > 126 || $x ~~ / \w / ;
}

sub is-endspace($x) {
  return "\n\r\f".contains($x);
}

sub is-whitespace($x) {
  return " \t".contains($x) || is-endspace($x);
}

# New line characters before or after these characters can be removed.
# Not + - / in this list because they require special care.
sub is-infix($x) {
  return ",;:=&%*<>?|\n".contains($x);
}

# New line characters after these characters can be removed.
sub is-prefix($x) {
  return '{([!'.contains($x) || is-infix($x);
}

# New line characters before these characters can removed.

sub is-postfix($x) {
  return '})]'.contains($x) || is-infix($x);
}

sub get(%s is copy) { 

  if (%s<input>.elems > 0) {

    if (%s<input_pos> <= %s<input>.elems) {

      my $char = %s<input>[%s<input_pos>];
      my $last_read_char = %s<input>[%s<input_pos>++];
      return $char ?? $char !! "", $last_read_char, %s<input_pos>;

    } else { # Simulate getc() when off the end of the input string.

      return "", %s<last_read_char>, %s<input_pos>;

    }

  } else {

   die "no input";

  }

}

# print a
# move b to a
# move c to b
# move d to c
# new d
#
# i.e. print a and advance
sub action1(%s) {
  if (!is-whitespace(%s<a>)) {
    %s<lastnws> = %s<a>;    
  }
  %s<last> = %s<a>;
  return action2(%s);
}

# sneeky output %s<a> for comments
sub action2(%s) {
  %s<output>.send(%s<a>);
  return action3(%s);
}

# move b to a
# move c to b
# move d to c
# new d
#
# i.e. delete a
sub action3(%s) {
  %s<a> = %s<b>;
  return action4(%s);
}

# move c to b
# move d to c
# new d
#
# i.e. delete b
sub action4(%s is copy) {
  %s<b> = %s<c>;
  %s<c> = %s<d>;
  (%s<d>, %s<last_read_char>, %s<input_pos>) = get(%s); 
  return %s;
}

# put string and regexp literals
# when this sub is called, %s<a> is on the opening delimiter character
sub put-literal(%s is copy) {
  my $delimiter = %s<a>; # ', " or /
  %s = action1(%s);
  repeat {
    while (%s<a> && %s<a> eq '\\') { # escape character only escapes only the next one character
      %s = action1(%s);
      %s = action1(%s);
    }
    %s = action1(%s);
  } until (%s<last> eq $delimiter || !%s<a>);
  if (%s<last> ne $delimiter) { # ran off end of file before printing the closing delimiter
    die 'unterminated single quoted string literal, stopped' if $delimiter eq '\'';
    die 'unterminated double quoted string literal, stopped' if $delimiter eq '"';
    die 'unterminated regular expression literal, stopped';
  }
  return %s;
}

# If %s<a> is a whitespace then collapse all following whitespace.
# If any of the whitespace is a new line then ensure %s<a> is a new line
# when this function ends.
sub collapse-whitespace(%s is copy) {
  while (%s<a> && is-whitespace(%s<a>) &&
         %s<b> && is-whitespace(%s<b>)) {
    if (is-endspace(%s<a>) || is-endspace(%s<b>)) {
      %s<a> = "\n";
    }
    %s = action4(%s); # delete b
  }
  return %s;
}

# Advance %s<a> to non-whitespace or end of file.
# Doesn't print any of this whitespace.
sub skip-whitespace(%s is copy) {
  while (%s<a> && is-whitespace(%s<a>)) {
    %s = action3(%s);
  }
  return %s;
}

# Advance %s<a> to non-whitespace or end of file
# If any of the whitespace is a new line then print one new line.
sub preserve-endspace(%s is copy) {
  %s = collapse-whitespace(%s);
  if (%s<a> && is-endspace(%s<a>) && %s<b> && !is-postfix(%s<b>) ) {
    %s = action1(%s);
  }
  %s = skip-whitespace(%s);
  return %s;
}

sub on-whitespace-conditional-comment($a, $b, $c, $d) {
  return ($a && is-whitespace($a) &&
          $b && $b eq '/' &&
          $c && '/*'.contains($c) &&
          $d && $d eq '@');
}

# Shift char or preserve endspace toggle
sub process-conditional-comment(%s) {
  return on-whitespace-conditional-comment(%s<a>, %s<b>, %s<c>, %s<d>) ?? action1(%s) !! preserve-endspace(%s);
}

# Handle + + and - -
sub process-double-plus-minus(%s) {
  if (%s<a> && is-whitespace(%s<a>)) {
    %s = (%s<b> && %s<b> eq %s<last>) ?? action1(%s) !! preserve-endspace(%s);
  }
  return %s;
};

# Handle potential property invocations
sub process-property-invocation(%s) {
  if (%s<a> && is-whitespace(%s<a>)) {
    # if %s<b> is '.' could be (12 .toString()) which is property invocation. If space removed becomes decimal point and error.
    %s = (%s<b> && (is-alphanum(%s<b>) || %s<b> eq '.')) ?? action1(%s) !! preserve-endspace(%s);
  }
  return %s;
}

#
# process-comments
#

multi sub process-comments(%s is copy where {%s<b> && %s<b> eq '/'}) { # a division, comment, or regexp literal
  my $cc_flag = %s<c> && %s<c> eq '@'; # tests in IE7 show no space allowed between slashes and at symbol
  repeat {
    %s = $cc_flag ?? action2(%s) !! action3(%s);
  } until (!%s<a> || is-endspace(%s<a>));
  if %s<a> { # %s<a> is a new line
    if ($cc_flag) {
      %s = (%s
            ==> action1() # cannot use preserve-endspace(%s) here because it might not print the new line
            ==> skip-whitespace());
    } elsif (%s<last> && !is-endspace(%s<last>) && !is-prefix(%s<last>)) {
      %s = preserve-endspace(%s);
    } else {
      %s = skip-whitespace(%s);
    }
  }
  return %s;
}

multi sub process-comments(%s is copy where {%s<b> && %s<b> eq '*'}) { # slash-star comment
  my $cc_flag = %s<c> && %s<c> eq '@'; # test in IE7 shows no space allowed between star and at symbol
  repeat { 
    %s = $cc_flag ?? action2(%s) !! action3(%s);
  } until (!%s<b> || (%s<a> eq '*' && %s<b> eq '/'));
  if (%s<b>) { # %s<a> is asterisk and %s<b> is foreslash
    if ($cc_flag) {
      %s = (%s
             ==> action2() # the *
             ==> action2() # the /
             # inside the conditional comment there may be a missing terminal semi-colon
             ==> preserve-endspace());
    } else { # the comment is being removed
      %s = action3(%s); # the *
      %s<a> = ' ';  # the /
      %s = collapse-whitespace(%s);
      if (%s<last> && %s<b> &&
        ((is-alphanum(%s<last>) && (is-alphanum(%s<b>)||%s<b> eq '.')) ||
        (%s<last> eq '+' && %s<b> eq '+') || (%s<last> eq '-' && %s<b> eq '-'))) { # for a situation like 5-/**/-2 or a/**/a
        # When entering this block %s<a> is whitespace.
        # The comment represented whitespace that cannot be removed. Therefore replace the now gone comment with a whitespace.
        %s = action1(%s);
      } elsif (%s<last> && !is-prefix(%s<last>)) {
        %s = preserve-endspace(%s);
      } else {
        %s = skip-whitespace(%s);
      }
    }
  } else {
    die 'unterminated comment, stopped';
  }
  return %s;
}

multi sub process-comments(%s is copy where {%s<lastnws> && 
                          (')].'.contains(%s<lastnws>) ||
                           is-alphanum(%s<lastnws>))}) {  # division
 (action1(%s)
  ==> collapse-whitespace()
  # don't want closing delimiter to
  # become a slash-slash comment with
  # following conditional comment
  ==> process-conditional-comment());
}


multi sub process-comments(%s is copy where {%s<a> eq '/' and %s<b> eq '.' }) {

  (collapse-whitespace(%s)
   ==> action1());
}

multi sub process-comments(%s is copy) {

  (put-literal(%s)
   ==> collapse-whitespace()
   # don't want closing delimiter to
   # become a slash-slash comment with
   # following conditional comment
   ==> process-conditional-comment());

}

#
# process-char
#

multi sub process-char(%s where {%s<a> eq '/'}) { # a division, comment, or regexp literal

  process-comments(%s);

}

multi sub process-char(%s where {"'\"".contains(%s<a>)}) { # string literal

  (put-literal(%s)
   ==> preserve-endspace());

}

multi sub process-char(%s where {'+-'.contains(%s<a>)}) { # careful with + + and - -

  (action1(%s)
   ==> collapse-whitespace()
   ==> process-double-plus-minus());

}

multi sub process-char(%s where {is-alphanum(%s<a>)}) { # keyword, identifiers, numbers

  (action1(%s)
   ==> collapse-whitespace()
   ==> process-property-invocation());

}

multi sub process-char(%s where {']})'.contains(%s<a>)}) {

  (action1(%s)
   ==> preserve-endspace());

}

multi sub process-char(%s is copy) {

  (action1(%s)
   ==> skip-whitespace());

}

#
# js-minify
#

sub js-minify(:$input!, :$copyright = '', :$strip_debug = 0) is export {

  # Immediately turn hash into a hash reference so that notation is the same in this function
  # as others. Easier refactoring.

  # Capture inpute / readchars from file into string
  my $input_new = ($input.WHAT ~~ Str ?? $input !! $input.readchars.chomp);

  # Store all chars in List
  my $input_list = ($strip_debug == 1 ?? $input_new.subst( /';;;' <-[\n]>+/, '', :g) !! $input_new).split("", :skip-empty).List.cache;

  # hash reference for "state". This module
  my %s = input          => $input_list,
          strip_debug    => $strip_debug,
          last_read_char => 0,
          input_pos      => 0,
          output         => Channel.new,
          last           => '', # assign for safety
          lastnws        => ''; # assign for safety

  # Print the copyright notice first
  if ($copyright) {
    %s<output>.send("/* $copyright */");
  }

  # Initialize the buffer.
  repeat {
    (%s<a>, %s<last_read_char>, %s<input_pos>) = get(%s); 
  } while (%s<a> && is-whitespace(%s<a>));
  (%s<b>, %s<last_read_char>, %s<input_pos>) = get(%s); 
  (%s<c>, %s<last_read_char>, %s<input_pos>) = get(%s);
  (%s<d>, %s<last_read_char>, %s<input_pos>) = get(%s); 

  # Wrap main login in promise and await below
  my $minify_p = start {
    while %s<a> { # on this line %s<a> should always be a non-whitespace character or '' (i.e. end of file)
      
      if (is-whitespace(%s<a>)) { # check that this program is running correctly
        die 'minifier bug: minify while loop starting with whitespace, stopped';
      }
      
      # Each branch handles trailing whitespace and ensures %s<a> is on non-whitespace or '' when branch finishes
      %s = process-char(%s);
    }
    
    if ( %s<input>.tail eq "\n" ) {
      %s<output>.send('\n');
    }

    # Send 'done' to exit react/whenever block
    %s<output>.send('done');
  };

  # Capture output
  my $output;

  # Read from Channel
  for %s<output>.list -> $c {
    # Exit when 'done'
    last if $c eq 'done';
    # Store to output
    $output ~= $c;
  }

  # Wait for main logig promise to keep
  await $minify_p;

  # return output
  return $output;

}
