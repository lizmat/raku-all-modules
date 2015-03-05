use v6;
use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::LacunaBuilding;

class Archaeology is LacunaBuilding;
constant $URL = '/archaeology';
method assemble_glyphs(@glyphs, Int $quantity --> Str){
    my Array $array;
    $array.push($_) for (@glyphs);

    rpc($URL).assemble_glyphs(session_id,self.id, $array, $quantity)<item_name>;
  
}

 
