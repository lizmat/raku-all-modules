module Test::Junkie;

class Tracker {
    has @.directories;
    has $!timestamp;

    multi method new()              { self.bless(*, directories => <lib t>) }
    multi method new(*@directories) { self.bless(*, :@directories) }

    method files() {
        gather find_files @.directories;
    }

    method changed() { 
      $.files.grep({ .changed after $!timestamp }); 
    }

    method update_timer {
        $!timestamp = time; 
    }
    
    method start {
        say "Starting Test::Junkie - don't say we didn't warn you!" ;
        loop {
            $.update_timer;
            run_tests($.changed); 
            sleep .5 until $.changed;
        }
    }

    sub run_tests(@tests) { 
        shell "PERL6LIB=lib prove -v -e perl6 @tests».path.sort()";
    }

    sub find_files(*@dirs) {
        for @dirs -> $directory {
            for dir($directory) -> $file {
                given $file.IO { 
                    when .f { take $_ }
                    when .d { find_files .path }
                }
            }
        }    
    }
}
