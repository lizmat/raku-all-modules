use v6;
unit module TestCrane;

our %data =
    :legumes([
        {
            :instock(4),
            :name("pinto beans"),
            :unit("lbs")
        },
        {
            :instock(21),
            :name("lima beans"),
            :unit("lbs")
        },
        {
            :instock(13),
            :name("black eyed peas"),
            :unit("lbs")
        },
        {
            :instock(8),
            :name("split peas"),
            :unit("lbs")
        }
    ]);

# vim: ft=perl6
