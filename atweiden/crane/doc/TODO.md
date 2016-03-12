# TODO

## warn about Range type handling

- `$container.deepmap(*.clone)` transforms nested Range types into
  List equivalent.
  - `my $root = $container.deepmap(*.clone)` is needed to prevent mutating
    original container, so I don't see how this can be avoided
    - on the plus side, Ranges are converted into List equivalent when
      serializing to JSON
