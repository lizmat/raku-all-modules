use v6;
use v6.c;

=begin pod

=head1 NAME

Binary::Structured - read and write binary formats defined by classes

=head1 SYNOPSIS

=begin code

use Binary::Structured;

# Binary format definition
class PascalString is Binary::Structured {
	has uint8 $!length is written(method {$!string.bytes});
	has Buf $.string is read(method {self.pull($!length)}) is rw;
}

# Reading
my $parser = PascalString.new;
$parser.parse(Buf.new("\x05hello world".ords));
say $parser.string.decode("ascii"); # "hello"

# Writing
$parser.string = "some new data".ords;
say $parser.build; # Buf.new<0d 6f 6d 65 20 6e 65 77 20 64 61 74 61>

=end code

=head1 DESCRIPTION

Binary::Structured provides a way to define classes which know how to parse and
emit binary data based on the class attributes. The goal of this module is to
provide building blocks to describe an entire file (or well-defined section of
a file), which can easily be parsed, edited, and rebuilt.

This module was inspired by the Python library C<construct>, with the
class-based representation inspired by Perl 6's C<NativeCall>.

Types of the attributes are used whenever possible to drive behavior, with
custom traits provided to add more smarts when needed to parse more formats.

These attributes are parsed in order of declaration, regardless of if they are
public or private, but only attributes declared in that class directly. The
readonly or rw traits are ignored for attributes. Methods are also ignored.

=head1 TYPES

Perl 6 provides a wealth of native sized types. The following native types may
be used on attributes for parsing and building without the help of any traits:

=item int8
=item int16
=item int32
=item uint8
=item uint16
=item uint32

These types consume 1, 2, or 4 bytes as appropriate for the type.

=item Buf

Buf is another type that lends itself to representing this data. It has no
obvious length and requires the C<read> trait to consume it (see the traits
section below).

=item StaticData

A variant of Buf, C<StaticData>, is provided to represent bytes that are known
in advance. It requires a default value of a Buf, which is used to determine
the number of bytes to consume, and these bytes are checked with the default
value. An exception is raised if these bytes do not match. An appropriate use
of this would be the magic bytes at the beginning of many file formats, or the
null terminator at the end of a CString, for example:

=begin code

# Magic for PNG files
class PNGFile is Binary::Structured {
	has StaticData $.magic = Buf.new(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);
}

=end code

=item Binary::Structured subclass

These structures may be nested. Provide an attribute that subclasses
C<Binary::Structured> to include another structure at this position. This inner
structure takes over control until it is done parsing or building, and then the
outer structure resumes parsing or building.

=begin code

class Inner is Binary::Structured {
	has int8 $.value;
}
class Outer is Binary::Structured {
	has int8 $.before;
	has Inner $.inner;
	has int8 $.after;
}
# This would be able to parse Buf.new(1, 2, 3)
# $outer.before would be 1, $outer.inner.value would be 2,
# and $outer.after would be 3.

=end code

=item Array[Binary::Structured]

Multiple structures can be handled by using an C<Array> of subclasses. Use the
C<read> trait to control when it stops trying to adding values into the array.
See the traits section below for examples on controlling iteration.

=head1 METHODS

=end pod

use experimental :pack;

my role ConstructedAttributeHelper {
	has Routine $.reader is rw;
	has Routine $.writer is rw;
	has Routine $.indirect-type is rw;
}

multi sub trait_mod:<is>(Attribute:D $a, :$read!) is export {
	$a does ConstructedAttributeHelper;
	$a.reader = $read;
}

multi sub trait_mod:<is>(Attribute:D $a, :$written!) is export {
	$a does ConstructedAttributeHelper;
	$a.writer = $written;
}

multi sub trait_mod:<is>(Attribute:D $a, :$indirect-type!) is export {
	$a does ConstructedAttributeHelper;
	$a.indirect-type = $indirect-type;
}

# XXX: maybe these should be subclasses
subset StaticData of Blob;
subset AutoData of Any;

my class ElementCount is Int {}

#| Exception raised when data in a C<StaticData> does not match the bytes
#| consumed.
class X::Binary::Structured::StaticMismatch is Exception {
	has $.got;
	has $.expected;

	method message {
		"Static data mismatch:\n\tGot: $.got.gist()\n\tExpected: $.expected.gist()";
	}
}

#| Superclass of formats. Some methods are meant for implementing various trait
#| helpers (see below).
class Binary::Structured {
	#| Current position of parsing of the Buf.
	has Int $.pos is readonly = 0;
	#| Data being parsed.
	has Blob $.data is readonly;
	has Binary::Structured $!parent;

	#| Returns a Buf of the next C<$count> bytes but without advancing the
	#| position, used for lookahead in the C<is read> trait.
	method peek(Int $count) {
		my $subbuf = $!data.subbuf($!pos, $count);
		return $subbuf;
	}

	#| Returns the next byte as an Int without advancing the position. More
	#| efficient than regular C<peek>, used for lookahead in the C<is read>
	#| trait.
	method peek-one {
		return $!data[$!pos];
	}

	#| Method used to consume C<$count> bytes from the data, returning it as a
	#| Buf. Advances the position by the specified count.
	method pull(Int $count) {
		my $subbuf = $!data.subbuf($!pos, $count);
		$!pos += $count;
		return $subbuf;
	}

	#| Helper method for reader methods to indicate a certain number of
	#| elements/iterations rather than a certain number of bytes.
	method pull-elements(Int $count) returns ElementCount {
		return ElementCount.new($count);
	}

	method !inline-parse($attr, $inner-type is copy) {
#		if %indirect-type{$attr}:exists {
#			$inner-type = %indirect-type{$attr}(self);
#		}
		my $inner = $inner-type.new;
		$inner.parse($!data, :$!pos, :parent(self));
		CATCH {
			when X::Assignment {
				note "LAST1";
				return;
			}
			when X::Binary::Structured::StaticMismatch {
				note "LAST2";
				return;
			}
		}
		$!pos = $inner.pos;
		return $inner;
	}

	# Reasonably fast and detailed (but verbose) debug output.
	method gist {
		my $s = '{ ';
		my @attrs = self.^attributes(:local);
		for @attrs -> $attr {
			$s ~= "$attr.name() => $attr.get_value(self).gist() ";
		}
		return $s ~ '}';
	}

	# Since Attribute.set_value apparently binds, we need to give it a
	# container. Handle that icky step here.
	method !set-attr-value-rw($attr, $value) {
		$attr.set_value(self, (my $ = $value));
	}

	#| Takes a Buf of data to parse, with an optional position to start parsing
	#| at, and a parent C<Binary::Structured> object (purely for subsequent
	#| parsing methods for traits). Typically only with C<$data> and maybe
	#| C<$pos>.
	method parse(Blob $data, Int :$pos=0, Binary::Structured :$parent) {
		$!data = $data;
		$!pos = $pos;
		$!parent = $parent;

		my @attrs = self.^attributes(:local);
		die "{self} has no attributes!" unless @attrs;
		for @attrs -> $attr {
			given $attr.type {
				when Binary::Structured {
					my $inner-type = $attr.type;
					my $inner = self!inline-parse($attr, $inner-type);
					die "Mismatch!" unless $inner;

					$attr.set_value(self, $inner);
				}

				when Array {
					unless $attr.type.of ~~ Binary::Structured {
						die "whoa, can't handle a $attr.type.gist() yet :(";
					}
					die "no reader for $attr.gist()" unless $attr.reader;
					my $limit = $attr.reader.(self);
					my $limit-type = 'bytes';
					if $limit ~~ Buf {
						die "XXX: Bufs for readers for arrays NYI";
					}

					my @array = $attr.type.new;

					# This attr must know when to stop somehow...
					my $inner-type = $attr.type.of;

					if $limit ~~ ElementCount {
						for ^$limit {
							# prevent out of bounds...
							die "$attr.gist(): read past end of buffer!" if $!pos >= $!data.bytes;
							my $inner = self!inline-parse($attr, $inner-type);
							@array.push($inner);
						}
					} else {
						my $initial-pos = $!pos;
						while $!pos - $initial-pos < $limit {
							die "$attr.gist(): read past end of buffer!" if $!pos >= $!data.bytes;
							my $inner = self!inline-parse($attr, $inner-type);
							@array.push($inner);
						}

						# XXX: maybe this should be a warning
						die "$attr.gist(): read too many bytes!" if $limit < $!pos - $initial-pos;
					}

					$attr.set_value(self, @array);
				}

				when uint | int {
					die "Unsupported type: $attr.gist(): cannot use native types without length";
				}
				when uint8 {
					# manual cast to uint8 is needed to handle bounds
					self!set-attr-value-rw($attr, (my uint8 $ = self.pull(1)[0]));
				}
				when uint16 {
					# manual cast to uint16 is needed to handle bounds
					self!set-attr-value-rw($attr, (my uint16 $ = self.pull(2).unpack('v')));
				}
				when uint32 {
					# manual cast to uint32 is needed to handle bounds
					self!set-attr-value-rw($attr, (my uint32 $ = self.pull(4).unpack('V')));
				}
				when int8 {
					self!set-attr-value-rw($attr, self.pull(1)[0]);
				}
				when int16 {
					self!set-attr-value-rw($attr, self.pull(2).unpack('v'));
				}
				when int32 {
					self!set-attr-value-rw($attr, self.pull(4).unpack('V'));
				}
				when Int {
					die "Unsupported type: $attr.gist(): cannot use object Int types without length";
				}

				when Buf {
					die "no reader for $attr.gist()" unless $attr.reader;
					my $data = $attr.reader.(self);
					self!set-attr-value-rw($attr, $data);
				}

				when StaticData {
					my $e = $attr.get_value(self);
					my $g = self.pull($e.bytes);

					if $g ne $e {
						die X::Binary::Structured::StaticMismatch.new(got => $g, expected => $e);
					}
				}

				when AutoData {
					# XXX: factor into Buf above?
					die "no reader for $attr.gist()" unless $attr.reader;
					my $data = $attr.reader.(self);
					self!set-attr-value-rw($attr, $data);
				}

				default {
					die "Cannot read an attribute of type $_.gist() yet!";
				}
			}
		}
	}

	method !get-attr-value($attr) {
		if $attr ~~ ConstructedAttributeHelper && $attr.writer {
			return $attr.writer.(self);
		}
		return $attr.get_value(self);
	}

	#| Construct a C<Buf> from the current state of this object.
	method build() returns Blob {
		my Buf $buf .= new;

		my @attrs = self.^attributes(:local);
		die "{self} has no attributes!" unless @attrs;
		for @attrs -> $attr {
			given $attr.type {
				when uint8 {
					$buf.push: self!get-attr-value($attr);
				}
				when uint16 {
					$buf.push: pack('v', self!get-attr-value($attr));
				}
				when uint32 {
					$buf.push: pack('V', self!get-attr-value($attr));
				}
				when int8 {
					$buf.push: self!get-attr-value($attr);
				}
				when int16 {
					$buf.push: pack('v', self!get-attr-value($attr));
				}
				when int32 {
					$buf.push: pack('V', self!get-attr-value($attr));
				}
				when Buf | StaticData {
					$buf.push: |self!get-attr-value($attr);
				}
				when Array | Binary::Structured {
					my $inner = self!get-attr-value($attr);
					$buf.push: .build for $inner.list;
				}
				default {
					die "Cannot write an attribute of type $_.gist() yet!";
				}
			}
		}

		return $buf;
	}
}

=begin pod

=head1 TRAITS

Traits are provided to add additional parsing control. Most of them take
methods as arguments, which operate in the context of the parsed (or partially
parsed) object, so you can refer to previous attributes.

### C<is read>

The C<is read> trait controls reading of C<Buf>s and C<Array>s. For C<Buf>,
return a C<Buf> built using C<self.pull($count)> (to ensure the position is
advanced properly). C<$count> here could be a reference to a previously parsed
value, could be a constant value, or you can use a loop along with
C<peek-one>/C<peek> to concatenate to a Buf.

For C<Array>, return a count of bytes as an C<Int>, or return a number of
elements to read using C<self.pull-elements($count)>. Note that
C<pull-elements> does not advance the position immediately so C<peek> is less
useful here.

### C<is written>

The C<is written> trait controls how a given attribute is constructed when
C<build> is called. It provides a way to update values based on other
attributes. It's best used on things that would be private attributes, like
lengths and some checksums. Since C<build> is only called when all attributes
are filled, you can refer to attributes that have not been written (unlike C<is
read>).

=head1 REQUIREMENTS

=item Rakudo Perl v6.c or above (tested on 2016.08.1)

=head1 TODO

See L<TODO>.

=end pod
