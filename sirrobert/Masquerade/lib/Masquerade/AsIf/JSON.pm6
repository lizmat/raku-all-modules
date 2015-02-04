# JSON::Tiny is used to render basic stuff like hashes.
use JSON::Tiny;

role AsIf::JSON;

# For reasons I don't quite understand, this has to be separated out into
# it's own sub right now.  I'd probably really just fold it into Str.
sub handled-elsewhere ($obj) {
  try {
    to-json($obj);
    return True;
  }

  CATCH {
    return False;
  }
}


##
# This helper sub renders class-based objects as JSON.  Objects are treated
# as hashes, public properties are rendered; private properties are omitted.
# This could probably be improved to do things like let objects that inherit
# from Arrays render as JavaScript arrays (or something).  But it works fine
# for my purposes for now.
sub asif-json ($obj) {
  # This hash will be rendered to JSON by JSON::Tiny.  It's just simple
  # storage.
  my %json;

  # Loop through the object's attributes.  If the attribute is public,
  # include it in the JSON.  If it's private, ignore it.
  for $obj.^attributes -> $attr {
    if $attr.has-accessor {
      %json{$attr.name.substr(2)} = $attr.get_value($obj);
    }
  }

  return to-json(%json);
}

# Render as string.
method Str () {

  if (handled-elsewhere(self)) {
    return to-json(self);
  } else {
    return asif-json(self);
  }
}

# Outsource gist to Str.
method gist () {
  return self.Str();
}


