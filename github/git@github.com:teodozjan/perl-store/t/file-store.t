use Test;
use PerlStore::FileStore;

plan 4;

class Bar {
has $.a;
has $.b;
}

class Foo does FileStore {
has %.x;
has $.u;
has Bar $.bar;
}

# quietly {} NIY
nok from_file('nox.pl'), 'Reading non existent Any';
nok Foo.from_file('sernox'), 'Reading non existent object';

{
    my %hash = "Foo" => "Bar", "Bar" => "Foo";
    to_file('tt.pl',%hash);
    my %hash2 = from_file('tt.pl');
    unlink('tt.pl');
    my $eq = True;
    is-deeply %hash2, %hash, 'Store and restore hashes'  
}


{
    my Bar $bar .= new(a=> 128); 
    my Foo $foo .= new(u=> 'Gore', bar => $bar);
    
    $foo.to_file('tt1.pl');
    my $tested = Foo.from_file('tt1.pl');
    unlink('tt1.pl');
  
    is $foo.perl, $tested.perl, 'Equal objects';
}
