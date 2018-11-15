unit module AI::Agent;

class DB
{
	has %.db;

	method BUILD(%db = {}) {
		%!db = %db;
	}

	method search($key) {
		return .db{$key};
	}

	method add($key, $value) {
		.db{$key} = $value;
	}

	### NOTE : keys are somewhat strings
	method list_keys() {
		my $string = "";

		for .db.kv -> $key,$value {
			$string ~= " $key";
		}

		return $string;
	}

}
