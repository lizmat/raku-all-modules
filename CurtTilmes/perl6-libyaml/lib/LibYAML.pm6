use v6;

use NativeCall;

constant LIB = 'yaml';

# yaml_encoding_t
enum LibYAML::encoding <
    YAML_ANY_ENCODING
    YAML_UTF8_ENCODING
    YAML_UTF16LE_ENCODING
    YAML_UTF16BE_ENCODING
>;

# yaml_break_t
enum LibYAML::break <
    YAML_ANY_BREAK
    YAML_CR_BREAK
    YAML_LN_BREAK
    YAML_CRLN_BREAK
>;

# yaml_error_type_t
enum LibYAML::error-type <
    YAML_NO_ERROR
    YAML_MEMORY_ERROR
    YAML_READER_ERROR
    YAML_SCANNER_ERROR
    YAML_PARSER_ERROR
    YAML_COMPOSER_ERROR
    YAML_WRITER_ERROR
    YAML_EMITTER_ERROR
>;

# yaml_mark_t
class LibYAML::mark is repr('CStruct')
{
    has size_t $.index;
    has size_t $.line;
    has size_t $.column;

    method Str { "$!index,$!line,$!column" }
}

# yaml_scalar_style_t
enum LibYAML::scalar-style <
    YAML_ANY_SCALAR_STYLE
    YAML_PLAIN_SCALAR_STYLE
    YAML_SINGLE_QUOTED_SCALAR_STYLE
    YAML_DOUBLE_QUOTED_SCALAR_STYLE
    YAML_LITERAL_SCALAR_STYLE
    YAML_FOLDED_SCALAR_STYLE
>;

# yaml_sequence_style_t
enum LibYAML::sequence-style <
    YAML_ANY_SEQUENCE_STYLE
    YAML_BLOCK_SEQUENCE_STYLE
    YAML_FLOW_SEQUENCE_STYLE
>;

# yaml_mapping_style_t
enum LibYAML::mapping-style <
    YAML_ANY_MAPPING_STYLE
    YAML_BLOCK_MAPPING_STYLE
    YAML_FLOW_MAPPING_STYLE
>;

# yaml_version_directive_t
class LibYAML::version-directive is repr('CStruct')
{
    has int32 $.major;
    has int32 $.minor;
}

# yaml_tag_directive_t
class LibYAML::tag-directive is repr('CStruct')
{
    has Str $.handle;
    has Str $.prefix;
}

# yaml_event_type_t
enum LibYAML::event-type <
    YAML_NO_EVENT
    YAML_STREAM_START_EVENT
    YAML_STREAM_END_EVENT
    YAML_DOCUMENT_START_EVENT
    YAML_DOCUMENT_END_EVENT
    YAML_ALIAS_EVENT
    YAML_SCALAR_EVENT
    YAML_SEQUENCE_START_EVENT
    YAML_SEQUENCE_END_EVENT
    YAML_MAPPING_START_EVENT
    YAML_MAPPING_END_EVENT
>;

class LibYAML::stream-start is repr('CStruct')
{
    has int32 $.encoding;

    method encoding { LibYAML::encoding($!encoding) }
}

class LibYAML::document-start is repr('CStruct')
{
    has LibYAML::version-directive $.version_directive;
    has LibYAML::tag-directive $.start;
    has LibYAML::tag-directive $.end;
    has int32 $.implicit;
}

class LibYAML::document-end is repr('CStruct')
{
    has int32 $.implicit;

    method implicit() { Bool($!implicit) }
}

class LibYAML::alias is repr('CStruct')
{
    has Str $.anchor;
}

class LibYAML::alias-data is repr('CStruct')
{
    has int32 $.type;
    has Str $.anchor;
}

class LibYAML::scalar-event is repr('CStruct')
{
    has Str $.anchor;
    has Str $.tag;
    has CArray[uint8] $.value;
    has size_t $.length;
    has int32 $.plain_implicit;
    has int32 $.quoted_implicit;
    has int32 $.style;
}

class LibYAML::scalar-event-data is repr('CStruct')
{
    has int32 $.type;
    has Str $.anchor;
    has Str $.tag;
    has CArray[uint8] $.value;
    has size_t $.length;
    has int32 $.plain_implicit;
    has int32 $.quoted_implicit;
    has int32 $.style;

    method style { LibYAML::scalar-style($!style) }
}

class LibYAML::sequence-start is repr('CStruct')
{
    has Str $.anchor;
    has Str $.tag;
    has int32 $.implicit;
    has int32 $.style;
}

class LibYAML::sequence-start-data is repr('CStruct')
{
    has int32 $.type;
    has Str $.anchor;
    has Str $.tag;
    has int32 $.implicit;
    has int32 $.style;

    method style { LibYAML::sequence-style($!style) }
}

class LibYAML::mapping-start is repr('CStruct')
{
    has Str $.anchor;
    has Str $.tag;
    has int32 $.implicit;
    has int32 $.style;
}

class LibYAML::mapping-start-data is repr('CStruct')
{
    has int32 $.type;
    has Str $.anchor;
    has Str $.tag;
    has int32 $.implicit;
    has int32 $.style;

    method style { LibYAML::mapping-style($!style) }
}

class LibYAML::event-data is repr('CUnion')  # Size = 48
{
    HAS LibYAML::stream-start $.stream-start;
    HAS LibYAML::document-start $.document-start;
    HAS LibYAML::document-end $.document-end;
    HAS LibYAML::alias $.alias;
    HAS LibYAML::scalar-event $.scalar;
    HAS LibYAML::sequence-start $.sequence_start;
    HAS LibYAML::mapping-start $.mapping_start;
}

# yaml_event_t
class LibYAML::event is repr('CStruct')
{
    has int32 $.type;
    HAS LibYAML::event-data $.data;
    HAS LibYAML::mark $.start_mark;
    HAS LibYAML::mark $.end_mark;

    sub yaml_event_delete(LibYAML::event) is native(LIB) {*}

    sub yaml_stream_start_event_initialize(LibYAML::event, int32)
        returns int32 is native(LIB) {*}

    sub yaml_stream_end_event_initialize(LibYAML::event)
        returns int32 is native(LIB) {*}

    sub yaml_document_start_event_initialize(LibYAML::event,
        LibYAML::version-directive, LibYAML::tag-directive,
        LibYAML::tag-directive, int32)
        returns int32 is native(LIB) {*}

    sub yaml_document_end_event_initialize(LibYAML::event, int32)
        returns int32 is native(LIB) {*}

    sub yaml_alias_event_initialize(LibYAML::event, Str)
        returns int32 is native(LIB) {*}

    sub yaml_scalar_event_initialize(LibYAML::event, Str, Str, Blob,
                                     int32, int32, int32, int32)
        returns int32 is native(LIB) {*}

    sub yaml_sequence_start_event_initialize(LibYAML::event, Str, Str,
                                             int32, int32)
        returns int32 is native(LIB) {*}

    sub yaml_sequence_end_event_initialize(LibYAML::event)
        returns int32 is native(LIB) {*}

    sub yaml_mapping_start_event_initialize(LibYAML::event, Str, Str,
                                            int32, int32)
        returns int32 is native(LIB) {*}

    sub yaml_mapping_end_event_initialize(LibYAML::event)
        returns int32 is native(LIB) {*}

    method type() { LibYAML::event-type($!type) }

    method delete() { yaml_event_delete(self) }

    method stream-start-event(LibYAML::encoding $encoding)
    {
        yaml_stream_start_event_initialize(self, $encoding.Int)
            or die "Stream Start";
    }

    method stream-end-event()
    {
        yaml_stream_end_event_initialize(self)
            or die "Stream End";
    }

    method document-start-event(LibYAML::version-directive $v,
                                LibYAML::tag-directive $start-directives,
                                LibYAML::tag-directive $end-directives,
                                Bool $implicit)
    {
        yaml_document_start_event_initialize(self, $v, $start-directives,
            $end-directives, $implicit ?? 1 !! 0)
            or die "Document Start";
    }

    method document-end-event(Bool $implicit)
    {
        yaml_document_end_event_initialize(self, $implicit ?? 1 !! 0)
            or die "Document End";
    }

    method alias-event(Str $anchor)
    {
        yaml_alias_event_initialize(self, $anchor)
            or die "Alias";
    }

    method scalar-event(Str $anchor, Str $tag, Str $value, Bool $plain_implicit,
                        Bool $quoted_implicit, LibYAML::scalar-style $style)
    {
        my $buf = $value.encode;
        yaml_scalar_event_initialize(self, $anchor, $tag, $buf, $buf.bytes,
                                     $plain_implicit ?? 1 !! 0,
                                     $quoted_implicit ?? 1 !! 0,
                                     $style)
            or die "Scalar";
    }

    method sequence-start-event(Str $anchor, Str $tag, Bool $implicit,
                                LibYAML::sequence-style $style)
    {
        yaml_sequence_start_event_initialize(self, $anchor, $tag,
                                             $implicit ?? 1 !! 0, $style)
            or die "Sequence start";
    }

    method sequence-end-event()
    {
        yaml_sequence_end_event_initialize(self)
            or die "Sequence end";
    }

    method mapping-start-event(Str $anchor, Str $tag, Bool $implicit,
                               LibYAML::mapping-style $style)
    {
        yaml_mapping_start_event_initialize(self, $anchor, $tag,
                                            $implicit ?? 1 !! 0, $style)
            or die "Mapping start";
    }

    method mapping-end-event()
    {
        yaml_mapping_end_event_initialize(self)
            or die "Mapping end";
    }
}

class LibYAML::FILEptr is repr('CPointer')
{
    sub fopen(Str, Str) returns LibYAML::FILEptr is native {*}
    sub fclose(LibYAML::FILEptr) is native {*}

    method open(Str:D $filename, Str:D $filemode)
    {
        fopen($filename, $filemode) or die "Error opening $filename";
    }

    method close() { fclose(self) }
}

class LibYAML::parser-error is repr('CStruct')
{
    has int32 $.error;
    has Str $.problem;
    has size_t $.problem_offset;
    has int32 $.problem_value;
    HAS LibYAML::mark $.mark;
    has Str $.context;
    HAS LibYAML::mark $.context_mark;

    method error { LibYAML::error-type($!error) }
}

class X::LibYAML::Parser-Error is Exception
{
    has LibYAML::error-type $.error;
    has $.problem;
    has $.problem_offset;
    has $.problem_value;
    has $.index = 0;
    has $.line = 0;
    has $.column = 0;
    has $.context;
    has $.ctx_index = 0;
    has $.ctx_line = 0;
    has $.ctx_column = 0;

    submethod BUILD(LibYAML::parser-error :$e)
    {
        $!error = $e.error;
        $!problem = $e.problem // '';
        $!problem_offset = $e.problem_offset;
        $!problem_value = $e.problem_value;
        with $e.mark
        {
            $!index = .index;
            $!line = .line;
            $!column = .column;
        }
        $!context = $e.context // '';
        with $e.context_mark
        {
            $!ctx_index = .index;
            $!ctx_line = .line;
            $!ctx_column = .column;
        }
    }

    method message()
    {
        "$!error : $!problem (offset=$!problem_offset, value=$!problem_value) "
            ~ "at index($!index), line($!line), column($!column), "
            ~ "$!context "
            ~ "at index($!ctx_index), line($!ctx_line), column($!ctx_column)"
    }
}

constant yaml_parser_t_size = 480;

class LibYAML::parser-struct is repr('CPointer')
{
    sub yaml_parser_initialize(LibYAML::parser-struct) returns int32
        is native(LIB) {*}

    sub yaml_parser_set_input_string(LibYAML::parser-struct, Blob, size_t)
        is native(LIB) {*}

    sub yaml_parser_set_input_file(LibYAML::parser-struct, LibYAML::FILEptr)
        is native(LIB) {*}

    sub yaml_parser_parse(LibYAML::parser-struct, LibYAML::event) returns int32
        is native(LIB) {*}

    sub yaml_parser_delete(LibYAML::parser-struct)
        is native(LIB) {*}

    method init()
    {
        yaml_parser_initialize(self)
            or die X::LibYAML::Parser-Error.new(
                e => nativecast(LibYAML::parser-error, self))
    }

    method delete() { yaml_parser_delete(self) }

    method set-input-string(Blob $buf)
    {
        yaml_parser_set_input_string(self, $buf, $buf.bytes);
    }

    method set-input-file(LibYAML::FILEptr $fp)
    {
        yaml_parser_set_input_file(self, $fp);
    }

    method parse(LibYAML::event $event)
    {
        yaml_parser_parse(self, $event)
            or die X::LibYAML::Parser-Error.new(
                e => nativecast(LibYAML::parser-error, self));
    }
}

class LibYAML::Parser
{
    has $.parser-raw;  # Just a place to hold the parser struct
    has LibYAML::event $.event = LibYAML::event.new;
    has $.encoding;
    has %.anchors;

    method init()
    {
        $!parser-raw = buf8.allocate(yaml_parser_t_size);
        self.parser.init;
    }

    method delete()
    {
        self.parser.delete;
        $!parser-raw = Any;
    }

    method parser() { nativecast(LibYAML::parser-struct, $!parser-raw) }

    method parse-event() { self.parser.parse($!event) }

    method parse-string(Str $str, Str $encoding = 'utf-8')
    {
        my $buf = $str.encode($encoding);

        self.init;
        LEAVE self.delete;

        self.parser.set-input-string($buf);

        self.parse-stream;
    }

    method parse-file(Str $filename)
    {
        my $fh = LibYAML::FILEptr.open($filename, "rb");

        LEAVE .close with $fh;

        self.init;
        LEAVE self.delete;

        self.parser.set-input-file($fh);

        self.parse-stream;
    }

    method parse-stream()
    {
        self.parse-event;
        die unless $!event.type ~~ YAML_STREAM_START_EVENT;
        $!encoding = $!event.data.stream-start.encoding;
        $!event.delete;

        my @docs;
        loop
        {
            self.parse-event;
            given $!event.type
            {
                when YAML_DOCUMENT_START_EVENT
                {
                    @docs.push: self.parse-document
                }
                when YAML_STREAM_END_EVENT
                {
                    $!event.delete;
                    return @docs.elems == 1 ?? @docs[0] !! @docs;
                }
                default
                {
                    die;
                }
            }
        }
    }

    method parse-document()
    {
        $!event.delete;
        my $doc;
        loop {
            self.parse-event;
            given $!event.type
            {
                when YAML_DOCUMENT_END_EVENT
                {
                    $!event.delete;
                    %!anchors = ();
                    return $doc;
                }
                default
                {
                    $doc = self.parse-node;
                }
            }
        }
    }

    method parse-node()
    {
        given $!event.type
        {
            when YAML_ALIAS_EVENT          { self.parse-alias    }
            when YAML_SCALAR_EVENT         { self.parse-scalar   }
            when YAML_SEQUENCE_START_EVENT { self.parse-sequence }
            when YAML_MAPPING_START_EVENT  { self.parse-map      }
            default { die }
        }
    }

    method parse-alias()
    {
        LEAVE $!event.delete;
        return %!anchors{nativecast(LibYAML::alias-data, $!event).anchor};
    }

    method parse-scalar()
    {
        my $d = nativecast(LibYAML::scalar-event-data, $!event);

        my $style = $d.style;

        my $scalar = buf8.new($d.value[0..^$d.length]).decode;

        $!event.delete;

        return $style != YAML_PLAIN_SCALAR_STYLE
            ?? $scalar
            !! do given $scalar
            {
                when '~'|''|'null'|'Null'|'NULL'      { Any }

                when 'true'|'True'|'TRUE'             { True }

                when 'false'|'False'|'FALSE'          { False }

                when '.inf'|'.Inf'|'.INF'|
                     '+.inf'|'+.Inf'|'+.INF'          { ∞ }

                when '-.inf'|'-.Inf'|'-.INF'          { -∞ }

                when '.nan'|'.NaN'|'.NAN'             { NaN }

                when /^[<[-+]>? <[0..9]>+         |
                       0o <[0..7]>+               |
                       0x <[0..9a..fA..F]>+ ]$/       { .Int }

                when /^<[-+]>? [ 0 | <[0..9]>*]
                       '.' <[0..9]>+ $/               { .Rat }

                when /^<[-+]>?
                     ['.' <[0..9]>+ |
                          <[0..9]>+ ['.' <[0..9]>+]? ]
                     [<[eE]> <[-+]>? <[0..9]>+]? $/   { .Num }

                default                               { $_ }
            }
    }

    method parse-sequence()
    {
        my $anchor = nativecast(LibYAML::sequence-start-data, $!event).anchor;
        $!event.delete;

        my @seq;

        loop
        {
            self.parse-event;
            if $!event.type ~~ YAML_SEQUENCE_END_EVENT
            {
                $!event.delete;
                %!anchors{$anchor} = @seq if $anchor;
                return @seq;
            }
            @seq.push: self.parse-node;
        }
    }

    method parse-map()
    {
        my $anchor = nativecast(LibYAML::mapping-start-data, $!event).anchor;
        $!event.delete;

        my %map;

        loop
        {
            self.parse-event;
            if $!event.type ~~ YAML_MAPPING_END_EVENT
            {
                $!event.delete;
                %!anchors{$anchor} = %map if $anchor;
                return %map;
            }
            my $key = self.parse-node;
            self.parse-event;
            my $value = self.parse-node;
            %map{$key} = $value;
        }
    }
}

class LibYAML::emitter-error is repr('CStruct')
{
    has int32 $.error;
    has Str $.problem;

    method error { LibYAML::error-type($!error) }
}

class X::LibYAML::Emitter-Error is Exception
{
    has LibYAML::error-type $.error;
    has $.problem;

    submethod BUILD(LibYAML::emitter-error :$e)
    {
        $!error = $e.error;
        $!problem = $e.problem // '';
    }

    method message() { "$!error : $!problem" }
}

constant yaml_emitter_t_size = 432;

class LibYAML::emitter-struct is repr('CPointer')
{
    sub yaml_emitter_initialize(LibYAML::emitter-struct) returns int32
        is native(LIB) {*}

    sub yaml_emitter_delete(LibYAML::emitter-struct)
        is native(LIB) {*}

    sub yaml_emitter_set_output_file(LibYAML::emitter-struct, LibYAML::FILEptr)
        is native(LIB) {*}

    sub yaml_emitter_set_output(LibYAML::emitter-struct,
                                &callback (uint64, Pointer, size_t --> int32),
                                uint64)
        is native(LIB) {*}

    sub yaml_emitter_set_encoding(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_set_canonical(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_set_indent(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_set_width(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_set_unicode(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_set_break(LibYAML::emitter-struct, int32)
        is native(LIB) {*}

    sub yaml_emitter_emit(LibYAML::emitter-struct, LibYAML::event) returns int32
        is native(LIB) {*}

    method init()
    {
        yaml_emitter_initialize(self)
            or die X::LibYAML::Emitter-Error.new(
                e => nativecast(LibYAML::emitter-error, self))
    }

    method set-output-file(LibYAML::FILEptr $fp)
    {
        yaml_emitter_set_output_file(self, $fp)
    }

    method set-output(&handler, Int $id)
    {
        yaml_emitter_set_output(self, &handler, $id)
    }

    method set-encoding(LibYAML::encoding $encoding)
    {
        yaml_emitter_set_encoding(self, $encoding)
    }

    method set-canonical(Bool $canonical)
    {
        yaml_emitter_set_canonical(self, $canonical ?? 1 !! 0)
    }

    method set-indent(Int $indent)
    {
        yaml_emitter_set_indent(self, $indent);
    }

    method set-width(Int $width)
    {
        yaml_emitter_set_width(self, $width)
    }

    method set-unicode(Bool $unicode)
    {
        yaml_emitter_set_unicode(self, $unicode ?? 1 !! 0);
    }

    method set-break(LibYAML::break $break)
    {
        yaml_emitter_set_break(self, $break);
    }

    method emit(LibYAML::event $event)
    {
        yaml_emitter_emit(self, $event)
            or die X::LibYAML::Emitter-Error.new(
                e => nativecast(LibYAML::emitter-error, self))
    }

    method delete() { yaml_emitter_delete(self) }
}

class LibYAML::Emitter {...}

role LibYAML::Emitable
{
    method yaml-emit(LibYAML::Emitter) { ... }
}

my $lock = Lock.new;
my %all-emitters;
my $emitter-id = 0;

sub emit-string(uint64 $id, Pointer $buffer, size_t $size) returns int32
{
    my $emitter = %all-emitters{$id};

    $emitter.buf ~= Blob.new(nativecast(CArray[uint8], $buffer)[0 ..^ $size])
                    .decode;

    return 1;
}

class LibYAML::Emitter
{
    has $.emitter-id;
    has $.emitter-raw; # Just a place to hold the emitter struct
    has LibYAML::event $.event = LibYAML::event.new;
    has %.objects;
    has %.aliases;
    has $.alias-id;
    has Str $.buf is rw;
    has LibYAML::encoding $.encoding = YAML_UTF8_ENCODING;
    has LibYAML::sequence-style $.sequence-style = YAML_BLOCK_SEQUENCE_STYLE;
    has LibYAML::mapping-style $.mapping-style = YAML_BLOCK_MAPPING_STYLE;
    has Bool $.header = False;
    has Bool $.footer = False;
    has Bool $.canonical = False;
    has Int $.indent = 2;
    has Int $.width = -1;
    has Bool $.unicode = True;
    has LibYAML::break $.break = YAML_LN_BREAK;

    method init()
    {
        $lock.protect({
            $!emitter-id = $emitter-id++;
            %all-emitters{$!emitter-id} = self;
        });

        $!emitter-raw = buf8.allocate(yaml_emitter_t_size);
        with self.emitter
        {
            .init;
            .set-encoding($!encoding);
            .set-canonical($!canonical);
            .set-indent($!indent);
            .set-width($!width);
            .set-unicode($!unicode);
            .set-break($!break);
        }
    }

    method delete()
    {
        self.emitter.delete;
        $!emitter-raw = Any;
        $lock.protect({ %all-emitters{$!emitter-id}:delete });
    }

    method emitter() { nativecast(LibYAML::emitter-struct, $!emitter-raw) }

    method emit-event() { self.emitter.emit($!event) }

    method dump-file(Str $filename, *@objects)
    {
        my $fh = LibYAML::FILEptr.open($filename, "wb");

        LEAVE .close with $fh;

        self.init;
        LEAVE self.delete;

        self.emitter.set-output-file($fh);

        self.emit-stream(@objects);
    }

    method dump-string(*@objects)
    {
        $!buf = '';

        self.init;
        LEAVE self.delete;

        self.emitter.set-output(&emit-string, $!emitter-id);

        self.emit-stream(@objects);

        return $!buf;
    }

    method emit-stream(@objects)
    {
        $!event.stream-start-event($!encoding);
        self.emit-event;

        my $implicit = not $!header;
        $implicit = False if @objects.elems != 1; # Force header

        for @objects -> $object
        {
            self.emit-document($object, :$implicit);
        }

        $!event.stream-end-event();
        self.emit-event;
    }

    method anchors($object)
    {
        return unless $object ~~ Positional|Associative;

        %!objects{$object.WHICH}++;

        return if %!objects{$object.WHICH} > 1;

        self.anchors($_) for $object.values;
    }

    method emit-document($object, Bool :$implicit)
    {
        $!event.document-start-event(LibYAML::version-directive,
                                     LibYAML::tag-directive,
                                     LibYAML::tag-directive, $implicit);
        self.emit-event;

        %!objects = ();
        %!aliases = ();
        $!alias-id = '1';
        self.anchors($object);
        self.emit-object($object);

        $!event.document-end-event(not $!footer);
        self.emit-event;
    }

    multi method emit-object(Mu:U, Str :$tag)
    {
        self.emit-plain: '~', :$tag;
    }

    multi method emit-object(Bool:D $obj, Str :$tag)
    {
        self.emit-plain: :$tag, $obj ?? 'true' !! 'false';
    }

    multi method emit-object(Cool:D $obj, Str :$tag)
    {
        self.emit-plain: ~$obj, :$tag;
    }

    method emit-plain(Str:D $obj, Str :$tag)
    {
        $!event.scalar-event(Str, $tag, $obj, True, True,
                             YAML_PLAIN_SCALAR_STYLE);
        self.emit-event;
    }

    multi method emit-object(Str:D $obj, Str :$tag)
    {
        my $style = YAML_PLAIN_SCALAR_STYLE;

        given $obj
        {
            when '~'|''|'null'|'Null'|'NULL'|
                 'true'|'True'|'TRUE'|
                 'false'|'False'|'FALSE'|
                 '.inf'|'.Inf'|'.INF'|
                 '+.inf'|'+.Inf'|'+.INF'|
                 '-.inf'|'-.Inf'|'-.INF'|
                 '.nan'|'.NaN'|'.NAN'
             {
                 $style = YAML_SINGLE_QUOTED_SCALAR_STYLE;
             }
            when /\n/
            {
                $style = .chars > 30 ?? YAML_LITERAL_SCALAR_STYLE
                                     !! YAML_DOUBLE_QUOTED_SCALAR_STYLE;
            }
        }

        $!event.scalar-event(Str, $tag, $obj, True, True, $style);
        self.emit-event;
    }

    multi method emit-alias(Str:D $alias)
    {
        $!event.alias-event($alias);
        self.emit-event;
    }

    multi method emit-object(Positional:D $list, Str :$tag)
    {
        return self.emit-alias($_) with %!aliases{$list.WHICH};

        my $anchor = Str;

        if %!objects{$list.WHICH} > 1
        {
            $anchor = %!aliases{$list.WHICH} = $!alias-id++;
        }

        $!event.sequence-start-event($anchor, $tag, False, $!sequence-style);
        self.emit-event;

        self.emit-object($_) for $list.list;

        $!event.sequence-end-event;
        self.emit-event;
    }

    multi method emit-object(Associative:D $map, Str :$tag)
    {
        return self.emit-alias($_) with %!aliases{$map.WHICH};

        my $anchor = Str;

        if %!objects{$map.WHICH} > 1
        {
            $anchor = %!aliases{$map.WHICH} = $!alias-id++;
        }

        $!event.mapping-start-event($anchor, $tag, False, $!mapping-style);
        self.emit-event;

        self.emit-object($_) for $map.kv;

        $!event.mapping-end-event;
        self.emit-event;
    }

    multi method emit-object(LibYAML::Emitable $obj)
    {
        $obj.yaml-emit(self);
    }
}

sub load-yaml(Str $input) is export {
    LibYAML::Parser.new.parse-string($input)
}

sub load-yaml-file(Str $filename) is export {
    LibYAML::Parser.new.parse-file($filename)
}

sub dump-yaml(*@objects, *%opts) is export {
    LibYAML::Emitter.new(|%opts).dump-string(|@objects)
}

sub dump-yaml-file(Str $filename, *@objects, *%opts) is export {
    LibYAML::Emitter.new(|%opts).dump-file($filename, |@objects)
}
