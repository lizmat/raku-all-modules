use CompUnit::Util :re-export;
need exports-stuff;

my package EXPORTHOW {
    package DECLARE {
        constant digimon = Metamodel::ClassHOW;
    }
}

BEGIN re-exporthow('exports-stuff');
