unit module Cow;

class basic {
  has Str $.initial-text is rw;
  has Str $.thoughts is rw = "\\";
  has Str $.eyes is rw = "oo";
  has Str $.tongue is rw = "  ";
  method set-face($face) {
    given $face {
      when "borg" {$!eyes = "=="}
      when "dead" {$!eyes = "xx"; $!tongue = "U "}
      when "greedy" {$!eyes = "\$\$"}
      when "paranoid" { $!eyes = "@@"}
      when "stoned" { $!eyes = "**"; $!tongue = "U "}
      when "tired" { $!eyes = "--"}
      when "wired" { $!eyes = "OO"}
      when "young" { $!eyes = ".."}
    }
    self;
  }
  method print-box {
    my $max-len = 0;
    my @text = $.initial-text.comb(36).List;
    for @text {
      if $_.chars > $max-len { $max-len = $_.chars };
    }
    say "-" x $max-len+2;
    for @text {
      print "|";
      print $_;
      if $_.chars < $max-len {print " " x $max-len - $_.chars}
      print "|" ~ "\n";
    }
    say "-" x $max-len+2;
  }
}

class cow is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
            $.thoughts   ^__^
             $.thoughts  ($.eyes)\\_______
                (__)\\       )\\/\\
                 $.tongue ||----w |
                    ||     ||
    EOC
  }
}

class tux is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
       $.thoughts
        $.thoughts
            .--.
           |o_o |
           |:_/ |
          //   \\ \\
         (|     | )
        /'\\_   _/`\\
        \\___)=(___/

    EOC
  }
}

class www is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
            $.thoughts   ^__^
             $.thoughts  ($.eyes)\\_______
                (__)\\       )\\/\\
                 $.tongue ||--WWW |
                    ||     ||
    EOC
  }
}

class bong is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
             $.thoughts
              $.thoughts
                ^__^
        _______/($.eyes)
    /\\/(       /(__)
       | W----|| |~|
       ||     || |~|  ~~
                 |~|  ~
                 |_| o
                 |#|/
                _+#+_
    EOC
  }
}

class bud-frogs is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
         $.thoughts
          $.thoughts
              oO)-.                       .-(Oo
             /__  _\\                     /_  __\\
             \\  \\(  |     ()~()         |  )/  /
              \\__|\\ |    (-___-)        | /|__/
              '  '--'    ==`-'==        '--'  '
    EOC
  }
}

class head-in is basic {
  method display {
    self.print-box;
    say qq:to/EOC/;
        $.thoughts
         $.thoughts
        ^__^         /
        ($.eyes)\\_______/  _________
        (__)\\       )=(  ____|_ \\_____
         $.tongue ||----w |  \\ \\     \\_____ |
            ||     ||   ||           ||
    EOC
  }
}

class camelia is basic {
  method display {
    self.print-box;
    #http://www.nntp.perl.org/group/perl.perl6.language/2010/09/msg34171.html
    say q:to/EOC/;
    \
     \
     ____                     ____
  _-'    '-_               _-'    '-_
-'   ****   '.           .'    ****  '-
/   **.-. ** '.\         /   ***    **  \
| ** ( * ) **  *\ /\ /\ /  ******  -. * |
| **  '-' **   *)  | |  ( ** .-. **  *  |
\   **  ** ..-' /  | |  \ * ( * ) ** ** /
\    ***     .--.-^^^-.--.* '-' ** .* /
 '._    ****( @@ )   ( @@ )*****   _.'
    ''..     '--'     '--'     ..''
     /       |           |       \
    /  *****  \  \___|  /  *****  \
   /  ***:::** '-------' **:::***  \
   |  **:::***  / | | \  ***:::**  |
    \  ******  /  \ \  \  ******  /
     '.______.'         '.______.'
EOC

  }
}
