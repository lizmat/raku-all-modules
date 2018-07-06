use HTTP::Response;

unit class Hematite::Response is HTTP::Response;

has %.cookies = ();

multi method charset() returns Str {
    my Str $content_type = self.header.hash{'Content-Type'}[0];
    my Match $charset    = ($content_type ~~ /\s*charset\=(<[\w-]>*)/);
    if ($charset) {
        return ~($charset.list[0]);
    }

    return '';
}

multi method charset(Str $value) returns ::?CLASS {
    my Str $content_type = self.content-type ~ ', charset=' ~ $value;
    self.field(Content-Type => $content_type);

    return self;
}

multi method content-type() returns Str {
    my Str $content_type = self.header.hash{'Content-Type'}[0];
    my Match $type       = ($content_type ~~ /(\w+\/\w+)/);

    return ~($type.list[0]);
}

multi method content-type(Str $value) returns ::?CLASS {
    my Str $charset = self.charset;
    my Str $content_type = "{ $value }, charset={ $charset }";
    self.field(Content-Type => $content_type);

    return self;
}
