use v6;
use JSON::Tiny;
use Avro::Auxiliary;
use Avro::Schema;

package Avro{

  #======================================
  # Exceptions
  #======================================

  class X::Avro::EncodeFail is Avro::AvroException {
    has Avro::Schema $.schema;
    has Mu $.data;
    method message { "Failed to encode "~$!data~" as "~$!schema.type() }
  }


  #== Role ==============================
  #   * Encoder
  #======================================

  role Encoder {
    method encode(Avro::Schema,Mu:D --> Blob) { * };
  }


  #== Class =============================
  #   * BinaryEncoder
  #======================================

  class BinaryEncoder does Encoder { 

    has Int $!blocksize;

    # constructor
    submethod BUILD( :$blocksize = 250 ) { 
      $!blocksize = $blocksize;
    }

    # int8 template "*" doesn't work as I expect it too
    sub template(int $length) {
      ((1..$length).map:{ "C" }).join(" ");
    }

    # integers and longs are encode as variable sized zigzag numbers
    sub encode_long(int $l){
      my @var_int = to_varint(to_zigzag($l));  
      pack(template(@var_int.elems()),@var_int);
    }

    multi submethod encode_schema(Avro::Record $schema, Associative:D $hash) { 
    #   X::Avro::EncodeFail.new(:schema($schema),:data($hash)).throw() 
    #    unless $schema.is_valid_default($hash);
      my BlobStream $stream = BlobStream.new();
      for $schema.fields.list -> $field {
        my $data = $hash{$field.name};
        $stream.append(self.encode_schema($field.type,$data));
      }
      $stream.blob
    }   

    # encode an array in blocks of max size $!blocksize
    multi submethod encode_schema(Avro::Array $schema, Positional:D $arr) { 
      my BlobStream $stream = BlobStream.new();
      my @copy = $arr.clone();
      my Int $iterations = ($arr.elems() div $!blocksize);
      my Int $leftover = $arr.elems() mod $!blocksize;
      my @blocks = (1..$iterations).map:{ $!blocksize }; 
      push(@blocks, $leftover) if ($leftover > 0);
      for @blocks -> $size {
        $stream.append(encode_long($size));
        for 1..$size {
          $stream.append(self.encode_schema($schema.items,@copy.shift));
        }
      }
      $stream.append(encode_long(0));
      $stream.blob
    }   

    # todo set maps with negative counts ?
    multi submethod encode_schema(Avro::Map $schema, Associative:D $hash) { 
      my BlobStream $stream = BlobStream.new();
      my Avro::Schema $keyschema = Avro::String.new();
      my @kv = $hash.kv;
      my Int $iterations = ($hash.elems() div $!blocksize);
      my Int $leftover = $hash.elems() mod $!blocksize;
      my @blocks = (1..$iterations).map:{ $!blocksize }; 
      push(@blocks, $leftover) if ($leftover > 0);
      for @blocks -> $size {
        $stream.append(encode_long($size));
        for (1..$size) -> $i {
          $stream.append(self.encode_schema($keyschema,@kv.shift));  
          $stream.append(self.encode_schema($schema.values,@kv.shift));
        }
      }
      $stream.append(encode_long(0));
      $stream.blob
    } 

    multi submethod encode_schema(Avro::Enum $schema, Str:D $str) { 
      my Int $result = $schema.sym.first({ ($^a eq $str) }, :k); 
      if $result.defined {
        return encode_long($result);
      } else { 
        X::Avro::EncodeFail.new(:schema($schema),:data($str)).throw() 
      }
    } 

    multi submethod encode_schema(Avro::Union $schema, Mu $data) { 
      my Avro::Schema $type = $schema.find_type($data);
      my Int $index = $schema.types.first({ ($^a ~~ $type) }, :k);
      my BlobStream $stream = BlobStream.new(:blob(encode_long($index)));
      $stream.append(self.encode_schema($type,$data));
      $stream.blob
    }

    multi submethod encode_schema(Avro::Fixed $schema, Str:D $str) { 
      X::Avro::EncodeFail.new(:schema($schema),:data($str)).throw() 
        unless $schema.size == $str.codes(); 
      pack(template($schema.size),$str.ords())
    }

    multi submethod encode_schema(Avro::Null $schema, Any:U $any) { 
       # (pack("C",0));  --> misinterpretation
       BlobStream.new().blob
    }

    multi submethod encode_schema(Avro::String $schema, Str:D $str) { 
      my Blob $encoding = $str.encode();
      my BlobStream $stream = BlobStream.new(:blob(encode_long($encoding.elems())));
      $stream.append($encoding);
      $stream.blob
    }

    multi submethod encode_schema(Avro::Bytes $schema, Str:D $str) { 
      my BlobStream $stream = BlobStream.new(:blob(encode_long($str.codes())));
      $stream.append( pack(template($str.codes()),$str.ords()) );
      $stream.blob
    }

    multi submethod encode_schema(Avro::Boolean $schema, Bool:D $bool) {  
      (pack("C",$bool))
    }   

    multi submethod encode_schema(Avro::Integer $schema, Int:D $int) {
      encode_long($int)
    }

    multi submethod encode_schema(Avro::Long $schema, Int:D $long) {  
      encode_long($long) 
    }

    multi submethod encode_schema(Avro::Float $schema, Rat:D $float) { 
      my @arr = int_to_bytes(to_floatbits($float),4);
      (pack(template(4),@arr))
    }

    multi submethod encode_schema(Avro::Double $schema, Rat:D $double) {  
      my @arr = int_to_bytes(to_doublebits($double),8); 
      (pack(template(8),@arr))
    }

    method encode(Avro::Schema $schema, Mu $data) {  
      try {
      #  say $schema.WHAT.gist();
        return self.encode_schema($schema,$data); 
      }
      CATCH { default { say $_; X::Avro::EncodeFail.new(:schema($schema),:data($data)).throw() }}
    };
    
  
  };


  #== Class =============================
  #   * JSONEncoder
  #======================================

  class JSONEncoder does Encoder {
  
  
  };

}

