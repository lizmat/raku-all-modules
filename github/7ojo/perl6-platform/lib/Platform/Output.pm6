use v6;

class Platform::Output {

    my Str $.prefix = '🚜';
    my Str $.after-prefix = ' │ ';
    my Str $.box:<│> = '│';
    my Str $.box:<├> = '├'; 
    my Str $.box:<└> = '└';
    my Str $.box:<└─> = '└─';
    my Str $.box:<─> = '─';

    method x-prefix {
        self.prefix ~ self.after-prefix;
    }

}
