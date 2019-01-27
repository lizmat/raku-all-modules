use RPG::Base::Named;


#| A single adventure (which could be played over multiple sessions)
class RPG::Base::Adventure does RPG::Base::Named {
    has Str $.intro = '';
}
