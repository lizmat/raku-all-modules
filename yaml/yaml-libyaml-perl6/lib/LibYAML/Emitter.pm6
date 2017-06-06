use v6;
use NativeCall;

class LibYAML::Emitter {...}

role LibYAML::Emitable {
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

class LibYAML::Emitter {
    use LibYAML;
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

    method dump-file(Str $filename, **@objects)
    {
        my $fh = LibYAML::FILEptr.open($filename, "wb");

        LEAVE .close with $fh;

        self.init;
        LEAVE self.delete;

        self.emitter.set-output-file($fh);

        self.emit-stream(@objects);
    }

    method set-output-string {
        self.emitter.set-output(&emit-string, $!emitter-id);
    }

    method stream-start-event {
        $!event.stream-start-event($!encoding);
        self.emit-event;
    }

    method stream-end-event {
        $!event.stream-end-event();
        self.emit-event;
    }

    method document-start-event(Bool $implicit) {
        $!event.document-start-event(
            LibYAML::version-directive,
            LibYAML::tag-directive,
            LibYAML::tag-directive,
            $implicit,
        );
        self.emit-event;
    }

    method document-end-event(Bool $implicit) {
        $!event.document-end-event($implicit);
        #$!event.document-end-event(not $!footer);
        self.emit-event;
    }

    my %styles = %(
        plain => YAML_PLAIN_SCALAR_STYLE,
        single => YAML_SINGLE_QUOTED_SCALAR_STYLE,
        double => YAML_DOUBLE_QUOTED_SCALAR_STYLE,
        literal => YAML_LITERAL_SCALAR_STYLE,
        folded => YAML_FOLDED_SCALAR_STYLE,
        any => YAML_ANY_SCALAR_STYLE,
    );

    method scalar-event(Str $anchor, Str $tag, Str $value, Str $sstyle) {
        my $style = %styles{ $sstyle };
        if (defined $tag) {
            $!event.scalar-event($anchor, $tag, $value, False, False, $style);
        }
        else {
            $!event.scalar-event($anchor, $tag, $value, True, True, $style);
        }
        self.emit-event;
    }

    method alias-event(Str $alias) {
        self.emit-alias($alias);
    }

    method mapping-start-event(Str $anchor, Str $tag) {
        $!event.mapping-start-event($anchor, $tag, False, $!mapping-style);
        self.emit-event;
    }

    method mapping-end-event {
        $!event.mapping-end-event;
        self.emit-event;
    }

    method sequence-start-event(Str $anchor, Str $tag) {
        $!event.sequence-start-event($anchor, $tag, False, $!sequence-style);
        self.emit-event;
    }

    method sequence-end-event {
        $!event.sequence-end-event;
        self.emit-event;
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
            when ''|'null'|'true'|'false'
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


