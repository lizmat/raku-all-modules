unit class Symbol;
use UUID;

has Str $.name;
has UUID $!uuid handles <WHICH>;
submethod BUILD(:$name) { $!uuid .= new; $!name  = $name; }

method CALL-ME(Str $name) { self.new: :$name }

sub prefix:<s>(Pair $p where $p.value === True --> Symbol) is export {
    ::?CLASS.new: :name($p.key)
}
