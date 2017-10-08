use Dancer2:from<Perl5>;
 
get '/' => {
    exit;
    'Hello World!'
};
 
start;

# vim: ft=perl6
