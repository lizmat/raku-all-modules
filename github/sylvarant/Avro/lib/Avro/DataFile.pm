use v6;

use JSON::Tiny;
use Compress::Zlib;

use Avro::Auxiliary;
use Avro::Encode;
use Avro::Decode;
use Avro::Schema;

package Avro { 

  #======================================
  # Exceptions
  #======================================

  class X::Avro::DataFileWriter is Avro::AvroException {
    has Str $.note;
    method message { "Failed to write to Data File, "~$!note }
  }

  class X::Avro::DataFileReader is Avro::AvroException {
    has Str $.note;
    method message { "Failed to read Data File, "~$!note }
  }

  
  #======================================
  #   Package variables and constants
  #======================================

  my Avro::Record $schema_h = parse(
    {"type"=> "record", "name"=> "org.apache.avro.file.Header",
     "fields" => [
      {"name"=> "magic", "type"=> {"type"=> "fixed", "name"=> "Magic", "size"=> 4}},
      {"name"=> "meta", "type"=> {"type"=> "map", "values"=> "bytes"}},
      {"name"=> "sync", "type"=> {"type"=> "fixed", "name"=> "Sync", "size"=> 16}}]});

  my Avro::Fixed $fixed_s = parse({"type"=> "fixed", "name"=> "Sync", "size"=> 16});

  constant magic = "Obj\x01";
  constant marker_size = 16;


  #== Enum ==============================
  #   * Encoding
  #   -- the output type, used by the 
  #   constructors of reader and writer
  #======================================

  enum Encoding <JSON Binary>;


  #== Enum ==============================
  #   * Codec
  #   -- the codec, used by the writer
  #======================================

  enum Codec <null deflate>;


  #== Class =============================
  #   * DataFileWriter
  #======================================

  class DataFileWriter {

    constant DefaultBlocksize = 10240; 

    has IO::Handle $!handle;
    has Avro::Encoder $!encoder;
    has Avro::Schema $!schema;
    has Codec $!codec;
    has Blob $!syncmark;
    has BlobStream $!buffer;
    has $!compressor;
    has Int $!blocksize;
    has Int $!buffersize;
    has Int $!count;

    submethod refresh_compressor(Codec $codec) {
      given $codec {
        when Codec::null { Any }
        when Codec::deflate { Compress::Zlib::Stream.new() }
      }
    }

    multi method new(IO::Handle :$handle!, Avro::Schema :$schema!, Encoding :$encoding? = Encoding::Binary, 
      Associative :$metadata? = {}, Codec :$codec? = Codec::null, Int :$blocksize? = DefaultBlocksize) {

      my Avro::Encoder $encoder;
      given $encoding {
        when Encoding::JSON   { $encoder = Avro::JSONEncoder.new() }
        when Encoding::Binary { $encoder = Avro::BinaryEncoder.new() }
      }
      
      self.bless(handle => $handle, schema => $schema, encoder => $encoder,
        metadata => $metadata, codec => $codec, blocksize => $blocksize );
    }

    submethod BUILD(IO::Handle :$handle!, Avro::Schema :$schema!, Avro::Encoder :$encoder!,
      Associative :$metadata, Codec :$codec, Int :$blocksize) {

      my @rands = (0..255).map: { $_.chr }; # byte range
      my @range = (1..16);
      my $sync = (@range.map:{ @rands.pick(1) }).join("");
      $!syncmark = $encoder.encode($fixed_s,$sync);
      $!buffer = BlobStream.new();
      $!buffersize = 0;
      $!count = 0;
      $!handle = $handle;
      $!schema = $schema;
      $!blocksize = $blocksize;
      $!codec = $codec;
      $!compressor = self.refresh_compressor($!codec);
      $!encoder = $encoder;
      my %metahash = 'avro.schema' => $schema.to_json(), 'avro.codec' => ~$codec;
      %metahash.push( $metadata.kv ) if $metadata.kv.elems() != 0;
      my %header =  magic => magic, sync => $sync, meta => %metahash;
      $!handle.write($!encoder.encode($schema_h,%header)); #todo switch based on encoding ?
    }

    method append(Mu $data){
      my Blob $blob = $!encoder.encode($!schema,$data);
      $blob = $!compressor.deflate($blob) if $!codec ~~ Codec::deflate;
      my $size = $blob.elems(); 
      self!write_block if ($!buffersize + $size) > $!blocksize; 
      $!count++;
      $!buffersize += $size;
      $!buffer.append($blob);
    }

    method !write_block {
      return unless $!buffersize > 0;

      # increase buffer size with Z_FINISH when deflating
      if ($!codec ~~ Codec::deflate) {
        my $z_finish = $!compressor.finish();
        $!buffer.append($z_finish);
        $!buffersize += $z_finish.elems(); 
      }

      # write the block 
      $!handle.write($!encoder.encode(Avro::Long.new(),$!count)); 
      $!handle.write($!encoder.encode(Avro::Long.new(),$!buffersize));
      $!handle.write($!buffer.blob);
      $!handle.write($!syncmark);
      
      # reset buffer
      $!buffersize = 0;
      $!count = 0;
      $!buffer = BlobStream.new();
      $!compressor = self.refresh_compressor($!codec);
    }

    method close {
      self!write_block;
      $!handle.close
    }

  }


  #== Class =============================
  #   * DataFileReader
  #======================================

  class DataFileReader {

    has IO::Handle $!handle;
    has Avro::Decoder $!decoder;
    has Avro::Schema $.schema;
    has Codec $.codec;
    has Str $.syncmark;
    has Associative $.meta;
    has BlobStream $!buffer;

    multi method new(IO::Handle :$handle!, Encoding :$encoding? = Encoding::Binary) {
      my Avro::Decoder $decoder; 
      given $encoding {
        when Encoding::JSON   { $decoder = Avro::JSONDecoder.new() }
        when Encoding::Binary { $decoder = Avro::BinaryDecoder.new() }
      }
      self.bless(handle => $handle, decoder => $decoder);
    }

    submethod BUILD(IO::Handle :$handle, Avro::Decoder :$decoder!){
      $!handle = $handle;
      $!decoder = $decoder;
      $!buffer = BlobStream.new();
      my %header = $decoder.decode($handle,$schema_h);
      X::Avro::DataFileReader.new(:note("Incorrect magic bytes")).throw() 
        unless %header{'magic'} ~~ magic;
      $!syncmark = %header{'sync'};
      my %meta = %header{'meta'}.kv;
      $!schema =  parse(from-json(%meta{'avro.schema'})); #TODO fix json lib string problem?
      %meta<avro.schema>:delete;
      given %meta{'avro.codec'} {
        when 'null' { $!codec = Codec::null }
        when 'deflate' { $!codec = Codec::deflate }
        default {  X::Avro::DataFileReader.new(:note("Unsupported codec: $_")).throw() }
      }
      %meta<avro.codec>:delete;
      $!meta = %meta;
    }

    method !read_block() {
      X::Avro::DataFileReader(:note("eof")).throw() if $!handle.eof();
      my Int $count = $!decoder.decode($!handle,Avro::Long.new());
      my Int $size  = $!decoder.decode($!handle,Avro::Long.new());
      my Blob $blob = $!handle.read($size);
      if $!codec ~~ Codec::deflate {
        my $decompressor = Compress::Zlib::Stream.new;
        $blob = $decompressor.inflate($blob);
        #X::Avro::DataFileReader.new(:note("Not correctly deflated")).throw() unless $decompressor.finished;
      }
      my Str $marker = $!decoder.decode($!handle.read(marker_size),$fixed_s);
      X::Avro::DataFileReader.new(:note("Incorrect sync marker: $marker")).throw() unless $marker ~~ $!syncmark;
      $!buffer = BlobStream.new(:blob($blob)); 
    }

    method read() { 
      self!read_block if $!buffer.eof();
      return $!decoder.decode($!buffer,$!schema,); 
    }

    method eof() {
      $!handle.eof and $!buffer.eof()
    }

    method slurp() { 
      my @arr;  
      repeat {
        my Mu $l = self.read; 
        push @arr, $l;
      } until self.eof;
      @arr
    }

    method close() {
      # close buffer ?
      $!handle.close();
    }

  }

}
