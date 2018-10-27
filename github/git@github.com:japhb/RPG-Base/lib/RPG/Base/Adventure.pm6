use RPG::Base::Named;


#| A single adventure (which could be played over multiple sessions)
class RPG::Base::Adventure is RPG::Base::Named {
    has Str $.intro = '';
}
