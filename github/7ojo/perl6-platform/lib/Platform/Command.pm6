use v6;
use Platform::Output;
use Terminal::ANSIColor;

class Platform::Command is Proc::Async is Platform::Output {

    my Str $.prefix = "🐚"; 

    has Str $.out is rw = '';
    has Str $.err is rw = '';

    submethod TWEAK {
        my $prefix = " {self.after-prefix}";
        self.stdout.tap( -> $str {
            self.out ~= $str;
            for $str.lines {
                if $_ ~~ / Successfully / {
                    put $prefix ~ color('green') ~ $_ ~ color('reset');
                } else {
                    put $prefix ~ $_ ~ color('reset') if $_.chars > 0; 
                }
            }
        });
        self.stderr.tap( -> $str {
            self.err ~= $str;
        });
    }

    method run(:$cwd = $*CWD) {
        my Str $wrapped-cmd = Platform::Output.text(self.path ~ ' ' ~ self.args);
        put self.x-prefix ~ color('cyan') ~ $wrapped-cmd.lines.join(color('reset') ~ "\n {self.after-prefix}" ~ color('cyan')) ~ color('reset');
        try sink await self.start(:$cwd);
        self;
    }

}
