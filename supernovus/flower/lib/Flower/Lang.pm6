role Flower::Lang;

## Common methods for Flower Languages.

has $.flower;
has $.custom-tag is rw;
has %.options;

method tag {
  if $.custom-tag.defined {
    return $.custom-tag;
  }
  return $.default-tag;
}

