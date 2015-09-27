#use Grammar::Tracer;
grammar JSON::Faster::Grammar {
  rule TOP {
    ^
      [
      | <array>
      | <json>
      ]
    $
  }

  token array {
    '['
      [
      | <array>
      | <json>
      | <string>
      | <int>
      | <rat>
      ]* % ','
    ']'
  }

  token json {
    '{'
    <kvp>* % ','
    '}'
  }

  regex kvp {
    '"' 
    <key>+? 
    <!after '\\'> '"'
    \s* 
    ':' 
    \s* 
    <value>
  }

  token key {
    <!after '\\'> <-["]>
  }

  token value {
    [
    | <string>
    | <int>
    | <rat>
    | <array>
    | <json>
    ] ** 1
  }

  token string {
    '"' .*? '"'
  }

  token int {
    \d+
  }

  token rat {
    \d* '.' \d*
  }
}
