#| A named object that by default stringifies to its name
role RPG::Base::Named {
    has $.name is rw = 'unnamed';

    method Str() { $.name }
}
