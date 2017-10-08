use v6;
use Compress::Bzip2::Raw;
use NativeCall;

unit module Compress::Bzip2;

our class X::Bzip2 is Exception {
    has $.action;
    has $.code;
    has $.handle; # FILE* pointer.

    multi method new ($action, $code, $handle) { self.bless(:$action,:$code,:$handle); }
    multi method new ($action, $code) { self.bless(:$action,:$code); }

    method message() {
	given $!code {
	    when BZ_CONFIG_ERROR {
		close($!handle);
		"Error during $.action: Bzlib2 library was mis-compiled.";
	    }
	    when BZ_PARAM_ERROR {
		if ($!handle == Pointer[uint32]) {
		    "Error during $!action: Filename is incorrect.";
		} else {
		    close($!handle);
		    "Error during $!action: BlockSize value is incorrect or given file is empty.";
		}
	    }
	    when BZ_IO_ERROR {
		"Error during $!action: IO error with given filename.";
	    }
	    when BZ_MEM_ERROR {
		close($!handle);
		"Error during $!action: Not enough memory for compression.";
	    }
	    when BZ_SEQUENCE_ERROR {
		close($!handle);
		"Error during $!action: Incorrect open function was used."
	    }
	    when BZ_UNEXPECTED_EOF {
		close($!handle);
		"Error during $!action: File is unfinished."
	    }
	    when BZ_DATA_ERROR | BZ_DATA_ERROR_MAGIC {
		close($!handle);
		"Error during $!action: Data integrity error was detected."
	    }
	    when BZ_OUTBUFF_FULL {
		"Output buffer is definetly smaller than source. Check size of your file or report an error."
	    }
	    default {
		close($!handle);
		"Error during $!action: Something really bad happened with file reading.";
	    }
	}
    }
}

# Procedural interface.
our sub compress(Str $filename) is export {
    my int32 $bzerror;
    # FD, Blob, Size.
    my @info = name-to-compress-info($filename);
    my $bz = bzWriteOpen($bzerror, @info[0]);
    die X::Bzip2.new('bzWriteOpen', $bzerror, @info[0]) if $bzerror != BZ_OK;
    # I wonder how can I reduce this repeated 'die' part.
    my $len = @info[2];
    BZ2_bzWrite($bzerror, $bz, @info[1], $len);
    die X::Bzip2.new('bzWrite', $bzerror, @info[0]) if $bzerror != BZ_OK;
    bzWriteClose($bzerror, $bz);
    die X::Bzip2.new('bzWriteClose', $bzerror, @info[0]) if $bzerror != BZ_OK;
    close(@info[0]);
}

our sub decompress(Str $filename) is export {
    my int32 $bzerror = BZ_OK;
    # FD, opened stream.
    if !$filename.ends-with(".bz2") {
	die X::Bzip2.new('bzReadOpen', BZ_DATA_ERROR); # We don't need to write something if file is broken.
    } # Not sure about usefulness of decompression for files without .bz2 extension.
    my @info = name-to-decompress-info($filename);
    my $bz = bzReadOpen($bzerror, @info[0]);
    die X::Bzip2.new('bzReadOpen', $bzerror, @info[0]) if $bzerror != BZ_OK;
    my buf8 $temp .= new;
    $temp[1023] = 0; # We will read in chunks of 1024 bytes.
    loop (;$bzerror != BZ_STREAM_END && $bzerror == BZ_OK;) {
	my $len = BZ2_bzRead($bzerror, $bz, $temp, 1024);
	@info[1].write($temp);
    }
    if $bzerror != BZ_OK|BZ_STREAM_END {
	die X::Bzip2.new('bzRead', $bzerror, @info[0]);
    }
    BZ2_bzReadClose($bzerror, $bz);
    die X::Bzip2.new('bzReadClose', $bzerror, @info[0]) if $bzerror != BZ_OK;
    @info[1].close(); # We close file descriptor of perl.
    close(@info[0]); # And we close FILE* of C.
}

our sub internalBlobToBlob(buf8 $data, $compressing) {
    my buf8 $temp .= new;
    my uint32 $len;
    given $data.elems {
	when 0..50 {
	    $len = 1024; # Numbers need check.
	}
	default {
	    $len = $data.elems*2;
	}
    }
    with $len {
	my Int $temp-len = $len;
	$temp[$temp-len] = 0;
	# We'll crop our buffer later.
	my int32 $ret-code;
	if $compressing {
	    $ret-code = BZ2_bzBuffToBuffCompress($temp, $len, $data, $data.elems, 6, 0, 0);
	} else {
	    $ret-code = BZ2_bzBuffToBuffDecompress($temp, $len, $data, $data.elems, 0, 0);
	}
	if $ret-code == BZ_OK {
	    # Now $len contain length of compressed buffer and we can return subbuf.
	    $temp.subbuf(0, $len);
	} else {
	    if $compressing { die X::Bzip2.new('bzBuffToBuffCompress', $ret-code); }
	    else { die X::Bzip2.new('bzBuffToBuffDecompress', $ret-code); }
	}
    }
}

our sub compressToBlob(buf8 $data) is export {
    internalBlobToBlob($data, True);
}

our sub decompressToBlob(buf8 $data) is export {
    internalBlobToBlob($data, False);
}

# OO-interface.
class Compress::Bzip2::Stream is export {
    has $!stream = False;
    has Bool $!compress-init = False;
    has Bool $!decompress-init = False;
    has Bool $!finished = False;
    has Int  $.bytes-left = 0;
    has int32 $bzret;

    method compress($data) {
	die "Cannot compress and decompress the same object!" if $!decompress-init;
	$!compress-init = True;
	self._internal($data, True);
    }

    method decompress($data) {
	die "Cannot compress and decompress the same object!" if $!compress-init;
	$!decompress-init = True;
	self._internal($data, False);
    }

    method _internal($data, $compression) {
	die "End of stream reached!" if $!finished;
	$!stream = self.return_stream();
	$!stream.set-input($data);
	my buf8 $buffer-to-return .= new;
	my buf8 $out .= new;
	repeat {
	    $out = buf8.new;
	    $out[1023] = 0;
	    $!stream.set-output($out);
	    if $compression {
		$!bzret = BZ2_bzCompress($!stream, ($!stream.avail-in) ?? BZ_RUN !! BZ_FLUSH);
	    } else {
		$!bzret = BZ2_bzDecompress($!stream);
	    }
	    $out = $out.subbuf(0, 1024-($!stream.avail-out));
	    $buffer-to-return ~= $out;
	} while ($!stream.avail-in);
	if $!bzret == BZ_STREAM_END {
	    $!bytes-left = $!stream.avail-in;
	    $!finished = True;
	    $!stream = False;
	    return $buffer-to-return;
	}
	if $!bzret != BZ_RUN|BZ_FLUSH {
	    die "$!bzret";
	}
	$buffer-to-return;
    }

    method finish() {
	my $out = buf8.new;
	$out[1023] = 0;
	my $returned = buf8.new;
	repeat {
	    $!stream.set-output($out);
	    $!bzret = BZ2_bzCompress($!stream, BZ_FINISH);
	    $out = $out.subbuf(0, 1024-$!stream.avail-out);
	    $returned ~= $out;
	} while ($!bzret != BZ_STREAM_END);
	BZ2_bzCompressEnd($!stream);
	$!bytes-left = $!stream.avail-in;
	$!stream = False;
	$!finished = True;
	$returned;
    }

    method return_stream() {
	unless $!stream {
	    $!stream = bz_stream.new;
	    if $!compress-init {
		BZ2_bzCompressInit($!stream, 9, 0, 0);
	    }
	    if $!decompress-init {
		BZ2_bzDecompressInit($!stream, 0, 0);
	    }
	}
	$!stream;
    }
}
