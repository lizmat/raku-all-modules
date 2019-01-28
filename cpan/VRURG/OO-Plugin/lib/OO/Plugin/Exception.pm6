use v6.d;
use OO::Plugin::Class;

role X::Plugin {
    has Plugin:D $.plugin is required;
}

class CX::Plugin::Last does X::Control does X::Plugin {
    has $.rc;
    has Bool $.rc-set = False;

    multi submethod TWEAK ( :$!rc! ) {
        $!rc-set = True;
    }
    multi submethod TWEAK () { }

    method message { "<last plug control exception>" }
}

class CX::Plugin::Redo does X::Control does X::Plugin {
    method message { "<redo plugin chain control exception>" }
}

class X::OO::Plugin::NotFound is Exception is export {
    has Str:D $.plugin is required;

    method message {
        "No plugin '$!plugin' found"
    }
}
