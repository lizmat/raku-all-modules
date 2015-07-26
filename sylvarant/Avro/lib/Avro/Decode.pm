use v6;
use JSON::Tiny;
use Avro::Auxiliary;
use Avro::Schema;

package Avro{

  #======================================
  # Exceptions
  #======================================

  class X::Avro::DecodeFail is Avro::AvroException {
    has Str $.note;
    method message { "Failed to decode "~$!note }
  }


  #== Role ==============================
  #   * Decoder
  #======================================

  role Decoder {
    method decode(Mu , Avro::Schema --> Mu:D) { ... };
 #   multi method decode(IO::Handle:D $handle, Avro::Schema $schema --> Mu:D) { ... }; see bug ticker #125658
 #   multi method decode(Mu:D, Avro::Schema  --> Mu:D) { ... };
  }


  #== Class =============================
  #   * BinaryDecoder
  #======================================

  class BinaryDecoder does Decoder { 

    # integers and longs are encode as variable sized zigzag numbers
    sub decode_long(Stream $stream){
      my @arr = ();
      my int $byte;
      repeat {
        $byte = $stream.read(1).unpack("C");
        push(@arr,$byte);
      } until (($byte +> 7) == 0); 
      return from_zigzag(from_varint(@arr));
    }

    multi submethod decode_schema(Avro::Record $schema,Stream $stream) { 
      my %hash;
      for $schema.fields.list -> $field {
        %hash{$field.name} = self.decode_schema($field.type,$stream);
      }
      return %hash;
    }   

    multi submethod decode_schema(Avro::Array $schema, Stream $stream) { 
      my Int $size = decode_long($stream);
      my @arr = ();
      while $size {
        for (1..$size) -> $i {
          push(@arr,self.decode_schema($schema.items,$stream));  
        }
        $size = decode_long($stream);
      } 
      return @arr
    }   

    multi submethod decode_schema(Avro::Map $schema, Stream $stream) { 
      my Int $size = decode_long($stream);
      my %hash;
       my Avro::Schema $keyschema = Avro::String.new();
      while $size {
        for (1..$size) -> $i {
          my Str $key = self.decode_schema($keyschema,$stream);
          my $data = self.decode_schema($schema.values,$stream);
          %hash{$key} = $data;
        }
        $size = decode_long($stream);
      }
      return %hash;
    }   

    multi submethod decode_schema(Avro::Enum $schema, Stream $stream) { 
      my int $result = decode_long($stream);
      $schema.sym[$result];
    }   

    multi submethod decode_schema(Avro::Union $schema, Stream $stream) { 
      my Int $num = decode_long($stream);
      my Avro::Schema $type = $schema.types[$num];
      self.decode_schema($type,$stream);
    }   

    multi submethod decode_schema(Avro::Fixed $schema, Stream $stream) { 
      my @arr = ();
      for (1..$schema.size) -> $i {
        push(@arr,$stream.read(1).unpack("C").chr);
      }
      @arr.join("");
    }   

    multi submethod decode_schema(Avro::Null $schema, Stream $stream) { 
      #my $r = $stream.read(1).unpack("C"); 
      #if $r == 0 { Any }
      #else { X::Avro::DecodeFail.new(:schema($schema)).throw()  }
      Any 
    }   

    multi submethod decode_schema(Avro::String $schema, Stream $stream) { 
      my int $size = decode_long($stream); 
      my Blob $r = $stream.read($size);
      $r.decode()
    }   

    multi submethod decode_schema(Avro::Bytes $schema, Stream $stream) { 
      my int $size = decode_long($stream); 
      my @arr = ();
      for 1..$size -> $i {
        push(@arr,$stream.read(1).unpack("C").chr);
      }
      @arr.join("");
    }   

    multi submethod decode_schema(Avro::Boolean $schema, Stream $stream) {  
      my $r = $stream.read(1).unpack("C"); 
      given $r {
        when 0  { False }

        when 1  { True }

        default { X::Avro::DecodeFail.new(:schema($schema)).throw()  }
      }
    }   

    multi submethod decode_schema(Avro::Integer $schema, Stream $stream) { 
      decode_long($stream);   
    }   

    multi submethod decode_schema(Avro::Long $schema, Stream $stream) { 
      decode_long($stream);
    }   

    multi submethod decode_schema(Avro::Float $schema, Stream $stream) { 
      my @arr = ();
      for 1..4 -> $i {
        push(@arr,$stream.read(1).unpack("C"));
      }
      from_floatbits(int_from_bytes(@arr));
    }   

    multi submethod decode_schema(Avro::Double $schema, Stream $stream) { 
      my @arr = ();
      for 1..8 -> $i {
        push(@arr,$stream.read(1).unpack("C"));
      }
      from_doublebits(int_from_bytes(@arr));
    }   

    multi submethod dispatch(Stream $stream, Avro::Schema $schema) {
      #X::Avro::DecodeFail.new(:note("Empty Stream")).throw() if $stream.eof;
      return self.decode_schema($schema,$stream); 
    }

    multi submethod dispatch(IO::Handle:D $handle, Avro::Schema $schema) {
      my HandleStream $stream = HandleStream.new(:handle($handle));
      self.dispatch($stream,$schema);
    }

    multi submethod dispatch(Blob $blob, Avro::Schema $schema) {  
      my BlobStream $stream = BlobStream.new(:blob($blob));
      self.dispatch($stream,$schema);
    }

    method decode(Mu $input, Avro::Schema $schema) { # dispatch within class due to perl6 bug #125658
      return self.dispatch($input,$schema);
      CATCH { default { X::Avro::DecodeFail.new(:note($schema.type)).throw() }}
    }

  };


  #== Class =============================
  #   * JSONDecoder
  #======================================

  class JSONDecoder does Decoder {
  
    method decode(Mu:D , Avro::Schema --> Mu:D) { "TODO" };
  
  };

}

