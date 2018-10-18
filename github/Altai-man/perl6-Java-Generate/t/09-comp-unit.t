use Java::Generate::Class;
use Java::Generate::CompUnit;
use Test;

plan 1;

my $class-a = Class.new(
    :access<public>,
    :name<A>,
    modifiers => <static final>
);

my $unit = CompUnit.new(
    package => 'test.package',
    imports => ("test.Import", "test.Import2"),
    type => $class-a
);

my $code = q:to/END/;
package test.package;
import test.Import;
import test.Import2;

public static final class A {

}
END

is $unit.generate, $code, 'Unit is generated';
