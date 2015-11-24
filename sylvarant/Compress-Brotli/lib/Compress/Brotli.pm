use v6;
use NativeCall;
use LibraryMake;

module Compress::Brotli:ver<0.1.0> {

  #======================================
  # Brotli Config class
  #======================================

  class Config is repr('CStruct') is export {
    has int8 $.mode;
    has int8 $.quality;
    has int8 $.lgwin;
    has int8 $.lgblock;
  }

  #======================================
  # Native functions
  #======================================

  # adapted from Crypt::Bycrypt
  sub library(--> Str) {
	  state Str $path;
	  unless $path {
      my $so = get-vars('')<SO>;
		  my $libname = 'libperl6brotli'~$so;
		  for @*INC {
			  my $inc-path = $_.IO.path.subst(/ ['file#' || 'inst#'] /, '');
			  my $check = $*SPEC.catfile($inc-path, $libname);
			  if $check.IO ~~ :f {
				  $path = $check;
				  last;
			  }
		  }
			die ("Unable to locate library: $libname") unless $path;
	  }
	  return $path;
  }

  sub compress_buffer(Int,CArray[uint8], CArray[int], CArray[uint8],Config --> Int) 
    is native(&library) { * }
  sub decompress_buffer(Int,CArray[uint8], CArray[int]--> CArray[uint8]) 
    is native(&library) { * }
  sub clear_internal_buffer() is native(&library) { * }

  #======================================
  # Exceptions
  #======================================

  class X::Compress::Brotli is Exception {
    has $.message;
    method message { "Brotli failed: $!message" }
  }

  #======================================
  # Config for brotli compression
  #======================================
  
  # from Compress::Snappy
	# Simulate an int pointer with a CArray
  sub to_pointer(Int $value = 0) {
	  my $intpointer = CArray[int].new();
	  $intpointer[0] = $value;
	  return $intpointer;
  }

  #======================================
  # The brotli interface
  #======================================

  our proto compress($data, $conf? --> Buf) is export { * } 

  # default brotli parameters
  my $def_conf = Config.new(:mode(0),:quality(11),:lgwin(22),:lgblock(0));
  my $text_conf = Config.new(:mode(1),:quality(11),:lgwin(22),:lgblock(0));

  multi sub compress(Str $data,Config $conf = $text_conf) {
	  return compress($data.encode("UTF-8"),$conf);
  }


  multi sub compress(Blob $data, Config $conf = $def_conf) { 
    my Int $in_size = $data.bytes();
    my $input = CArray[uint8].new();
	  $input[$_] = $data[$_] for ^$data.bytes;
    my $max_out_size = 1.2 * $in_size  + 10240;
    my $out_size = to_pointer($max_out_size.Int);
    my $array = CArray[uint8].new();
    $array[$_] = 0 for ^$max_out_size;
    X::Compress::Brotli.new(:message("Failed to compress!")).throw()
      unless compress_buffer($in_size,$input,$out_size,$array,$conf);
	  return Buf.new: map {$array[$_]}, ^$out_size[0];
  }

  sub decompress(Blob $data --> Buf) is export 
  { 
    my $input= CArray[uint8].new();
	  $input[$_] = $data[$_] for ^$data.bytes;
    my $out_size = to_pointer(0);
    my $array = decompress_buffer($data.bytes(),$input,$out_size);
    X::Compress::Brotli.new(:message("Failed to decompress")).throw() 
      unless (^$out_size[0] >= 0);
	  my $res = Buf.new: map {$array[$_]}, ^$out_size[0];
    clear_internal_buffer(); #once copied we can clear the buffer
    return $res;
  }

  sub decode_str(Buf $data --> Str) is export
  {
    return $data.decode("UTF-8");
  }

}

