


class String::Stream {
        has $.buffer;


        multi method new()
         {
          self.bless();
        }

        multi method new(Str $s)
        {
          self.bless(buffer => $s);
        }
        method print(*@args) {
            $!buffer ~= @args.join;
        }

        method say(*@args) {
            $!buffer ~= @args.join;
            $!buffer ~= "\n";
        }

        method flush {}

        method get() {
            return $.buffer;
        }
                

    }

 
