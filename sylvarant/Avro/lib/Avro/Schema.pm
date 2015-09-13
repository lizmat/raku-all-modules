use v6;
use JSON::Tiny;
use Avro::Auxiliary;

package Avro {


  #======================================
  # Exceptions
  #======================================

  class X::Avro::Type is Avro::AvroException {
    has $.type;
    method message { "Input $!type is not a valid Avro type" }
  }

  class X::Avro::Order is Avro::AvroException {
    has $.type;
    method message { "Input $!type is not a valid Order type" }
  }

  class X::Avro::Primitive is Avro::AvroException {
    has Str $.source;
    method message { "Input $!source is not a valid Primitive type" }
  }

  class X::Avro::MissingName is Avro::AvroException {
    method message { "This Avro Schema requires a name" }
  }

  class X::Avro::FaultyName is Avro::AvroException {
    has Str $.source;
    method message { "Not a valid Avro Name $!source" }
  }

  class X::Avro::Record is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Record Schema, $!note" }
  }

  class X::Avro::Union is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Union Schema, $!note" }
  }

  class X::Avro::Map is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Map Schema, $!note" }
  }

  class X::Avro::Array is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Array Schema, $!note" }
  }

  class X::Avro::Enum is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Enum Schema, $!note" }
  }

  class X::Avro::Fixed is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Fixed Schema, $!note" }
  }

  class X::Avro::Field is Avro::AvroException {
    has Str $.note;
    method message { "Not a valid Field Schema, $!note" }
  }


  #== Role ==============================
  #   * Avro Schema
  #======================================

  role Schema {
    has Iterable $!native;
    method native(--> Iterable) { return $!native; } 
    method to_json(--> Str) { to-json(self.native()); }
    method is_valid_default(Mu --> Bool) { False }
    method type(--> Str) { "(Schema)" }
  }

  # parse produces Schema
  proto parse(Mu  --> Avro::Schema) is export {*}


  #== Role ==============================
  #   * Documented
  #   -- used by Enum and Record
  #======================================

  role Documented {
    has Str $.documentation = "";
  }


  #== Role ==============================
  #   * Aliased
  #   -- used by NamedComplex & Field
  #======================================

  role Aliased {
    has Positional $.aliases = ();
  }


  #== Enum ==============================
  #   * Order
  #   -- used by Field 
  #======================================

  enum Order <ascending descending ignore>;

  sub parse_order(Str $text){
    given $text {

      when "ascending" { Order::ascending }

      when "descending" { Order::descending }

      when "ignore" { Order::ignore }

      default { X::Avro::Order.new(:type($text)).throw() }
    }
  }

  sub order_str (Order $o){
    given $o {

      when Order::ascending { "ascending" }

      when Order::descending { "descending" }

      when Order::ignore { "ignore" }
    }
  }


  #== Class =============================
  #   * NamedComplex 
  #   -- used by Enum,Record,Fixed 
  #======================================

  class NamedComplex does Aliased {
    
    has Str $.name;
    has Str $.namespace;
    has Str $.fullname;

    method valid_name (Str $str --> Bool) { 
      Bool($str ~~ /<[A..Za..z_]><[A..Za..z0..9_]>*/) 
    }

    submethod BUILD(Associative :$hash){
      X::Avro::MissingName.new().throw() unless $hash{'name'}:exists;
      $!namespace = ""; 
      $!name = $hash{'name'};
      $!fullname = $!name;

      my List $ls = $!name.split('.').values;
      for $ls.values -> $n {
        X::Avro::FaultyName.new(:source($n)).throw() unless self.valid_name($n);
      }
      if $ls.elems() > 1 {
        $!name = $ls[$ls.end()];
        $!namespace = ($ls[0..($ls.end()-1)]).join(".");
      }
      elsif $hash{'namespace'}:exists {
        $!namespace = $hash{'namespace'}; 
        $!fullname = $!namespace ~ "." ~ $!fullname;
      }

      # aliases
      if $hash{'aliases'}:exists {
        # TODO
      }
    }
  }


  #== Class =============================
  #   * Field 
  #   -- A member of Records
  #======================================

  class Field does Aliased {

    also does Documented;
     
    has EnumMap $.native;
    has Str $.name;
    has Avro::Schema $.type;
    has $.default;
    has Order $.order;

    submethod BUILD(Associative :$hash){
      
      # input check
      X::Avro::Field.new(:note("Missing type and/or name")).throw() 
        unless $hash{'name'} and $hash{'type'}; 
      X::Avro::FaultyName.new(:source($hash{'name'})).throw() 
        unless NamedComplex.valid_name($hash{'name'});

      # attributes
      $!name = $hash{'name'};
      $!type = parse($hash{'type'});
      $!order = Order::ascending;
      $!order = parse_order($hash{'order'}) if $hash{'order'}:exists; 
      if $hash{'doc'}:exists {
        $!documentation = $hash{'doc'}; 
        $!native{'doc'} = $!documentation;
      }
      if $hash{'default'}:exists {
          $!default = $hash{'default'};
          my Bool $valid_def = $!type.is_valid_default($!default);
          CATCH { default { X::Avro::Field.new(:note("Invalid default value: "~ ($hash{'default'}))).throw() }}
          X::Avro::Field.new(:note("Invalid default value: "~ ($hash{'default'}))).throw()  unless $valid_def;
          $!native{'default'} = $!default;
      }

      # build native representation
      $!native = { 'name' => $!name, 'type' => $!type.native()};  
      $!native{'order'} = order_str($!order)  unless $!order == Order::ascending; 
      $!native{'aliases'} = self.aliases() if self.aliases.defined;
    }
  }


  #== Class =============================
  #   * Primitive Type
  #======================================

  class Primitive does Schema {

    has Str $.type;

    method native(--> EnumMap){
      return EnumMap.new("type",self.type()); 
    }

    method is_valid_default(Cool:D $default){ ... }

  }

  class String is Primitive { 
    has Str $.type = "string";
    method is_valid_default (Str:D $str) { True }
  }

  class Boolean is Primitive {
    has Str $.type = "boolean";
    method is_valid_default (Bool:D $b) { True }
  }

  class Null is Primitive {
    has Str $.type = "null";
    method is_valid_default (Any:U $b) { True }
  }

  class Bytes is Primitive {
    has Str $.type = "bytes";
    method is_valid_default (Str:D $str) { True }
  }

  class Integer is Primitive {
    has Str $.type = "int";
    method is_valid_default (int:D $i) { True }
  }

  class Long is Primitive {
    has Str $.type = "long";
    method is_valid_default (int:D $l) { True }
  }

  class Float is Primitive {
    has Str $.type = "float";
    method is_valid_default (Rat:D $fl) { True }
  }

  class Double is Primitive {
    has Str $.type = "double";
    method is_valid_default (Rat:D $fl) { True }
  }


  #== Class =============================
  #   * Array Type
  #======================================

  class Array does Schema {
    
    constant type = 'array';

    has Avro::Schema $.items;
    
    submethod BUILD(:$hash){
      X::Avro::Array.new(:note("Requires values")).throw() unless $hash{'items'}:exists;
      $!items = parse($hash{'items'});
      my Iterable $other = $!items.native();
      $!native = EnumMap.new("type",type,"items",$other);
    }
    
    method native(--> EnumMap){
      return $!native;
    }

    method is_valid_default(Positional:D $array){ 
      for $array.values -> $item {
        return False unless $!items.is_valid_default($item);
      }
    }

    method type (--> Str) { type }

  }


  #== Class =============================
  #   * Map Type
  #======================================

  class Map does Schema {

    constant type = 'map';

    has Avro::Schema $.values;

    submethod BUILD(Associative :$hash){
      X::Avro::Schema.new(:note("Requires values")).throw() unless $hash{'values'}:exists;
      $!values = parse($hash{'values'});
      my Iterable $other = $!values.native();
      $!native = EnumMap.new("type",type,"values",$other);
    }

    method native(--> EnumMap){
      return $!native;
    }

    method is_valid_default(Associative:D $hash) { 
      for $hash.values -> $item {
        return False unless $!values.is_valid_default($item);
      }
    }

    method type (--> Str) { type }

  }


  #== Class =============================
  #   * Union Type
  #======================================

  class Union does Schema {

    constant type = "union";

    has List $.types;

    submethod BUILD(Positional :$types){
      $!types = ($types.map({ parse($_) })).values;
      my %encountered;
      for $!types.values -> $schema {
        X::Avro::Union.new("Union not permitted") if $schema ~~ Avro::Union;
        if $schema ~~ Avro::NamedComplex {
          my Str $resolved = $schema.WHAT.gist ~ $schema.fullname(); #TODO resolve aliases
          X::Avro::Union.new(:note("Duplicate Complex type of name: "~$schema.name())).throw()
            if %encountered{$resolved}:exists;
          %encountered{$resolved} = 1;
        } else {
          my Str $key = $schema.WHAT.gist ~ ($schema.?type().gist);
          X::Avro::Union.new(:note("Duplicate Primitive type: "~$key)).throw()  
            if %encountered{$key}:exists;
          %encountered{$key} = 1;
        }
      }
      $!native = ($!types.map:{ $_.native() }).values;
    }

    method native(--> List){
      return $!native;
    }

    method find_type (Mu $data --> Avro::Schema){
      #what about overlapping data types?
      for $!types.values -> $type {
          my Bool $valid_def = False;
          try {
            $valid_def = $type.is_valid_default($data);
          }
          return $type if $valid_def;
      }
      X::Avro::Union.new(:note("Type not found for "~$data)).throw();
    }

    method is_valid_default(Mu:D $value){
      $!types[0].is_valid_default($value);
    }

    method type (--> Str) { type }

  }


  my $break_lazy = 0;

  #== Class =============================
  #   * Record Type
  #======================================

  class Record is NamedComplex does Schema  {
    
    also does Documented;

    constant type = "record";

    has List $.fields;

    submethod create_field(Associative:D $hash --> Avro::Field) { Avro::Field.new(:hash($hash)) }

    submethod BUILD(Associative:D :$hash){
      X::Avro::Record.new(:note("Missing Fields!")).throw() 
        unless $hash{'fields'}:exists;
      my List $ls = $hash{'fields'};
      $!fields = ($ls.map({ self.create_field($_) })).values; 
      $break_lazy = $!fields.elems(); # TODO -- no longer needed
      my $nativesf = $!fields.map({ $_.native() });
      $!native = { 'type' => type, 'name' => self.name(), 'fields' => $nativesf.values };
      $!native{'aliases'} = self.aliases() unless self.aliases() ~~ ();
      $!native{'namespace'} = self.namespace() unless self.namespace() eq "";
      if $hash{'doc'}:exists {
        $!documentation = $hash{'doc'}; 
        $!native{'doc'} = $!documentation;
      }
    }

    # determined by subset of names
    method is_valid_default(Associative:D $hash){
      ($!fields.map: { $_.name }) ⊆ $hash.keys();
    }

    method type (--> Str) { type }
     
  }


  #== Class =============================
  #   * Enum Type
  #======================================

  class Enum is NamedComplex does Schema {

    also does Documented;

    constant type = "enum";

    has List $.sym;
    
    submethod BUILD(Associative :$hash) {
      X::Avro::Enum.new(:note("Requires symbols")).throw() unless $hash{'symbols'}:exists;
      $!sym = $hash{'symbols'};
      $!native = Hash.new();
      if $hash{'doc'}:exists {
        $!documentation = $hash{'doc'};
        $!native{'doc'} = $!documentation;
      }
      $!native{ 'type' } = type; 
      $!native{'name'} = self.name(); 
      $!native{'aliases'} = self.aliases() unless self.aliases() ~~ ();
      $!native{'namespace'} = self.namespace() unless self.namespace() eq "";
      $!native{'symbols'} = $!sym;
    }

    method is_valid_default(Str $str){
      my $result = $!sym.first-index: { ($^a eq $str) }; 
      return $result.defined; 
    }

    method type (--> Str) { type }

  }


  #== Class =============================
  #   * Fixed Type
  #======================================

  class Fixed is NamedComplex does Schema {

    constant type = "fixed";

    has Int $.size;

    submethod BUILD(Associative :$hash){
      X::Avro::Fixed.new(:note("Requires size")).throw() unless $hash{'size'}:exists;
      $!size = $hash{'size'};
      $!native = { 'type' => type, 'name' => self.name(), 'size' => $!size};
      $!native{'aliases'} = self.aliases() unless self.aliases() ~~ ();
      $!native{'namespace'} = self.namespace() unless self.namespace() eq "";
    }

    method is_valid_default(Str:D $str){
      $str.codes() == $!size
    }

    method type (--> Str) { return type }
  }


  #======================================
  # Schema parser 
  # -- Produces Schema Objects
  #======================================

  multi sub parse (Associative $hash --> Avro::Schema) is export {

    my Str $ty = $hash{'type'};
    return parse($ty) if $hash.pairs == 1;

    given $ty {
    
      when 'record' { return Avro::Record.new(:hash($hash)); }

      when 'enum' { return Avro::Enum.new(:hash($hash)); }

      when 'fixed' { return Avro::Fixed.new(:hash($hash)); }

      when 'map' { return Avro::Map.new(:hash($hash)); }

      when 'array' { return Avro::Array.new(:hash($hash)); }

      default { X::Avro::Type.new(:source($ty)).throw(); }
    }
  }
  
  multi sub parse(Positional $arr --> Avro::Schema) is export {
    return Avro::Union.new(:types($arr)); 
  }

  multi sub parse(Str $str --> Avro::Schema) is export {

    given $str {

      when "null"     { Avro::Null.new() }

      when "boolean"  { Avro::Boolean.new() }

      when "int"      { Avro::Integer.new() }

      when "long"     { Avro::Long.new() }

      when "float"    { Avro::Float.new() }

      when "double"   { Avro::Double.new() }

      when "bytes"    { Avro::Bytes.new() }

      when "string"   { Avro::String.new() }
    
      default { X::Avro::Primitive.new(:source($str)).throw() }

    }
  }

}

