use v6.c;

use XML::Class;

class Country does XML::Class[xml-element => 'country', xml-namespace => "http://www.example.com/country"] {
    class Name does XML::Class[xml-element => 'name'] {
        has Str $.lang;
        has Str $.name is xml-simple-content;
    }
    class Population does XML::Class[xml-element => 'population'] {
        has Str $.date;
        has Int $.figure;
    }
    class Currency does XML::Class[xml-element => 'currency'] {
        has Str $.code;
        has Str $.name;

    }
    class City does XML::Class[xml-element => 'city'] {
        has Str $.code;
        has Str $.name is xml-element;
    }
    has Str        $.code;
    has Name       $.name;
    has Population $.population;
    has Currency   $.currency;
    has City       @.cities;
}
