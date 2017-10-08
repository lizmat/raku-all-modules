use XML;

role HTML::Parser {
  has XML::Document $.xmldoc;
  method parse(Str $html) returns XML::Document {*}
}
