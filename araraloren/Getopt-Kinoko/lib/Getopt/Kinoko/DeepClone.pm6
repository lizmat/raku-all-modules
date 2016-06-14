
use v6;

role DeepClone {

	multi sub clone-helper(\c) { c }

	multi sub clone-helper(DeepClone \c) { c.deep-clone }

	multi method deep-clone(Array:D:) {
		self>>.&clone-helper;
	}

	multi method deep-clone(Hash:D:) {
		self>>.&clone-helper;
	}

	multi method deep-clone(Str:D:) {
		clone-helper(self);
	}

	multi method deep-clone(@array) {
		@array>>.&clone-helper;
	}

	multi method deep-clone(%hash) {
		%hash>>.&clone-helper;
	}

	multi method deep-clone(Str $str) {
		clone-helper($str);
	}

	multi method deep-clone(DeepClone $other) {
		$other.deep-clone;
	}

	multi method deep-clone($other) {
		clone-helper($other);
	}

	multi method deep-clone() {
		clone-helper(self);
	}
}
