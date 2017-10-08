use Test;
use RPG::Base::Named;


plan 6;


class NamedObject does RPG::Base::Named { }

{
    # Anonymous object
    my $o = NamedObject.new;
    does-ok $o, RPG::Base::Named;

    is $o.name,  'unnamed', "anon object got default name";
       $o.name = 'basket';
    is $o.name,  'basket',  "anon object can be named";
}

{
    # Named object
    my $o = NamedObject.new(:name('αἰγίς'));
    does-ok $o, RPG::Base::Named;

    is $o.name,  'αἰγίς',       "named object knows its name";
       $o.name = 'Gorgon skin';
    is $o.name,  'Gorgon skin', "named object can be renamed";
}


done-testing;
