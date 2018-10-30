use v6;
use Test;
use AttrX::PrivateAccessor;

plan 6;

class Teenager {
    has $!diary is private-accessible;
    has $!girl-friend is private-accessible('sweety') = "none";
    method init( $value ) {
        $!diary = $value;
    }
    method dates( $girl ) {
        $!girl-friend = $girl;
    }

    method inspect(Teenager:D: Teenager $other) {
        return $other!diary;
    }

    method spy( $other ) {
        "is dating "~$other!sweety;
    }
}

my $bob = Teenager.new();
$bob.init( "bob's diary" );
my $steve = Teenager.new();
$steve.init( "steve's diary" );

dies-ok { $bob.diary }, "No public method";
is $steve.inspect( $bob ), "bob's diary", "Can access other instance's private attributes";

$bob.dates( 'Mandy' );
is $steve.spy( $bob ), 'is dating Mandy', "Accessor renamming is working";

throws-like { EVAL q[
    use AttrX::PrivateAccessor;
    class Duplicate {
        has $!private is private-accessible;

        method !private() {
            "Just need a private method";
        }
    }
]; }, Exception, "Collide as a private method with the same name already exists", message => q[A private method 'private' already exists, can't create private accessor for accessot '$!private'];

eval-lives-ok q[
    use AttrX::PrivateAccessor;
    class NoCollision {
        has $!private is private-accessible;

        method private() {
            "Just need a public method";
        }
    }
], "Does not collide with public method";

throws-like { EVAL q[
    use AttrX::PrivateAccessor;
    role Collide {
        method !private() { }
    }
    class Foo does Collide {
        has $!private is private-accessible;
    }
]; }, Exception,
    "Collide as a private method with the same name already exists",
    message => q[A private method 'private' is provided by role 'Collide', can't create private accessor for accessot '$!private'];
