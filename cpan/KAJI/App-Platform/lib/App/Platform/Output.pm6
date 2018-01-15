use v6;
use Text::Wrap;

class App::Platform::Output {

    my Str $.prefix = '🚜';
    my Str $.after-prefix = ' │ ';
    my Str $.box:<│> = '│';
    my Str $.box:<├> = '├'; 
    my Str $.box:<└> = '└';
    my Str $.box:<└─> = '└─';
    my Str $.box:<─> = '─';
    my Int $.width;

    method x-prefix {
        self.prefix ~ self.after-prefix;
    }

    method text(*@args, *%args) {
        unless $.width {
            my $proc = run <tput cols>, :out;
            $.width = $proc.out.slurp-rest.trim.Int - 5;
            $.width ||= 80;
        }
        wrap-text(|@args, |%args, :$.width);
    }
}
