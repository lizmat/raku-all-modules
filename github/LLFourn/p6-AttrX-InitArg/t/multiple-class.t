use Test;
use AttrX::InitArg;

plan 8;

{
    my class Foo {
        has $!foo is init-arg;
        method foo { $!foo }
    }

    my class Bar is Foo {
        has $!bar is init-arg;
        method bar { $!bar }
    }

    $_ = Bar.new(:bar,:foo);

    ok .foo, 'parent';
    ok .bar, 'child';
}


{
    my role Foo {
        has $!foo is init-arg;
        method foo { $!foo }
    }

    my role Bar does Foo {
        has $!bar is init-arg;
        method bar { $!bar }
    }

    my class Baz does Bar {
        has $!baz is init-arg;
        method baz { $!baz };
    }


     $_ = Baz.new(:foo,:bar,:baz);
     ok .foo,'top-role';
     ok .bar,'middle-role';
     ok .baz,'child';
}

{
    my role Foo {
        has $!foo is init-arg;
        method foo { $!foo }
    }

    my role Bar {
        has $!bar is init-arg;
        method bar { $!bar }
    }

    my class Baz does Bar does Foo {
        has $!baz is init-arg;
        method baz { $!baz };
    }

    ok .foo,'top-role';
    ok .bar,'middle-role';
    ok .baz,'child';
}
