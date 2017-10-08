use Hinges::StreamEventKind;

sub escape($text, :$quotes = True) {
    $text; # TODO
}

class Hinges::XMLSerializer {
    has @!filters;

    method serialize($stream) {
        return join '', [~] gather for $stream.llist {
            my ($kind, $data, $pos) = @($_);
            if ($kind ~~ Hinges::StreamEventKind::start
                       | Hinges::StreamEventKind::empty) {
                my ($tag, $attribs) = @($data);
                take '<';
                take $tag;
                for @($attribs) -> $attrib {
                    my ($attr, $value) = @($attrib);
                    take for ' ', $attr, q[="], escape($value), q["];
                }
                take $kind ~~ Hinges::StreamEventKind::empty ?? '/>' !! '>';
            }
            elsif ($kind ~~ Hinges::StreamEventKind::end) {
                take sprintf '</%s>', $data;
            }
            else { # TODO More types
                take escape($data, :!quotes);
            }
        }
    }
}

class Hinges::XHTMLSerializer is Hinges::XMLSerializer {
}

class Hinges::HTMLSerializer {
}

class Hinges::TextSerializer {
}

sub get_serializer($method, *%_) {
    my $class = ( :xml(   Hinges::XMLSerializer),
                  :xhtml( Hinges::XHTMLSerializer),
                  :html(  Hinges::HTMLSerializer),
                  :text(  Hinges::TextSerializer) ){$method.lc};
    return $class.new(|%_);
}

