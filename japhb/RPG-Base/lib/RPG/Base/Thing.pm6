use RPG::Base::Named;


#| A generic thing that can have a name and be placed in a container
class RPG::Base::Thing does RPG::Base::Named {
    has $.container is rw;

    method gist() {
        my $cont = $.container ?? "in $.container.^name() '$.container'"
                               !! "without a container";
        "$.name ({ self.^name } $cont)"
    }
}
