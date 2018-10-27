use RPG::Base::Thing;
use RPG::Base::ThingContainer;


class RPG::Base::Location {...};


# Exceptions specific to this class
class X::RPG::Base::Location::ExitDoesNotExist is Exception {
    has Str                 $.direction;
    has RPG::Base::Location $.location;

    method message() {
        "$.location.^name() '$.location' does not have an exit going '$.direction'"
    }
}

class X::RPG::Base::Location::ExitAlreadyExists is Exception {
    has Str                 $.direction;
    has RPG::Base::Location $.location;

    method message() {
        "$.location.^name() '$.location' already has an exit going '$.direction'"
    }
}


#| An abstract location with exits, possibly containing things
class RPG::Base::Location
 does RPG::Base::Named
 does RPG::Base::ThingContainer {
    has Str                 $.desc is rw;
    has RPG::Base::Location %.exits;

    submethod BUILD(Str :$!name = 'Unknown', Str :$!desc = '', :%exits, :@contents) {
        # Ensure sanity of exits
        self.add-exit($_) for %exits.pairs;

        # Ensure things get their container set when they are added here
        self.add-thing($_) for @contents;
    }

    method gist() { "$.name (exits: %.exits.elems(), things: @.contents.elems())" }


    # Invariant checkers
    method !throw-if-exit-exists($direction) {
        X::RPG::Base::Location::ExitAlreadyExists.new(:$direction, :location(self)).throw
            if %!exits{$direction}:exists;
    }

    method !throw-unless-exit-exists($direction) {
        X::RPG::Base::Location::ExitDoesNotExist.new(:$direction, :location(self)).throw
            unless %!exits{$direction};
    }


    #| Add an exit to another location, shorthand form
    multi method add-exit(Pair $ (Str:D :key($direction), RPG::Base::Location:D :value($location))) {
        self.add-exit(:$direction, :$location);
    }

    #| Add an exit to another location, longhand form
    multi method add-exit(Str:D :$direction, RPG::Base::Location:D :$location) {
        self!throw-if-exit-exists($direction);

        %!exits{$direction} = $location;
    }

    #| Move a thing in this location through an exit, shorthand form
    multi method move-thing(Pair $ (Str:D :key($direction), RPG::Base::Thing:D :value($thing))) {
        self.move-thing(:$direction, :$thing);
    }

    #| Move a thing in this location through an exit, longhand form
    multi method move-thing(Str:D :$direction, RPG::Base::Thing:D :$thing) {
        self!throw-unless-exit-exists($direction);

        self.remove-thing($thing);
        %!exits{$direction}.add-thing($thing);
    }
}
