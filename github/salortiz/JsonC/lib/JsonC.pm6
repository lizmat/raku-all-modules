use v6;

unit module JsonC:ver<0.0.3>:auth<salortiz>;
use NativeLibs;
use nqp;

my $Lib;

enum json_type <
  type-null type-boolean type-double type-int
  type-object type-array type-string
>;

constant type-map = Map.new(
    0 => Nil, 1 => Bool, 2 => Num, 3 => Int,
    4 => Hash, 5 => Array, 6 => Str
);

enum json_tokener_error <
  json_tokener_success json_tokener_continue json_tokener_error_depth
  json_tokener_error_parse_eof json_tokener_error_parse_unexpected
  json_tokener_error_parse_null json_tokener_error_parse_boolean
  json_tokener_error_parse_number json_tokener_error_parse_array
  json_tokener_error_parse_object_key_name json_tokener_error_parse_object_key_sep
  json_tokener_error_parse_object_value_sep json_tokener_error_parse_string
  json_tokener_error_parse_comment json_tokener_error_size
>;

enum json_tokener_state <
  json_tokener_state_eatws json_tokener_state_start json_tokener_state_finish
  json_tokener_state_null json_tokener_state_comment_start json_tokener_state_comment
  json_tokener_state_comment_eol json_tokener_state_comment_end
  json_tokener_state_string json_tokener_state_string_escape
  json_tokener_state_escape_unicode json_tokener_state_boolean
  json_tokener_state_number json_tokener_state_array json_tokener_state_array_add
  json_tokener_state_array_sep json_tokener_state_object_field_start
  json_tokener_state_object_field json_tokener_state_object_field_end
  json_tokener_state_object_value json_tokener_state_object_value_add
  json_tokener_state_object_sep json_tokener_state_array_after_sep
  json_tokener_state_object_field_start_after_sep json_tokener_state_inf
>;

constant JSON_OBJECT_DEF_HASH_ENTRIES = 16;
constant JSON_C_TO_STRING_PLAIN  =       0;
constant JSON_C_TO_STRING_SPACED =  1 +< 0;
constant JSON_C_TO_STRING_PRETTY =  1 +< 1;
constant JSON_C_TO_STRING_NOZERO = (1 +< 2);

sub err-desc(uint32 -->Str) is symbol('json_tokener_error_desc') is native { * }

our class JSON-P is export is repr('CPointer') { ... }
our class JSON-A is export is repr('CPointer') { ... }

our class JSON is export is repr('CPointer') {

    my class Tokener is repr('CPointer') {

        my class i-tokener is repr('CStruct') {
            has Str $.str;
            has int64 $.pb;
            has int32 $.max_depth;
            has int32 $.depth;
            has int32 $.is_double;
            has int32 $.st_pos;
            has int32 $.char_offset;
        }

        sub json_tokener_new(-->Tokener) is native { * }
        sub json_tokener_set_flags(Tokener,int32) is native { * }
        method new(:$strict) {
            with json_tokener_new() {
                json_tokener_set_flags($_, 0x01) if $strict;
                $_;
            } else { Nil }
        }
        method free() is symbol('json_tokener_free') is native { * }
        method get-err(-->uint32) is symbol('json_tokener_get_error') is native { * }
        method internal() {
            nativecast(i-tokener, self);
        }
    }

    my class lh_entry is repr('CStruct') {
        has Str $.k;
        has JSON $.v;
        has lh_entry $.next;
        has lh_entry $.prev;
    }

    my class lh_table is repr('CStruct') {
        has int32 $.size;
        has int32 $.count;
        has int32 $.collisions;
        has int32 $.resizes;
        has int32 $.lookups;
        has int32 $.inserts;
        has int32 $.deletes;
        has Str   $.name;
        has lh_entry $.head;
        has lh_entry $.tail;
    }

    method json_object_get_object(-->lh_table) is native { * };
    sub json_object_get_string(JSON --> Str) is native { * }
    sub json_object_get_boolean(JSON --> uint32) is native { * }
    sub json_object_get_int64(JSON --> uint64) is native { * }
    sub json_object_get_double(JSON --> num64) is native { * }
    sub json_object_array_length(JSON -->uint32) is native { * };
    sub json_object_array_get_idx(JSON, uint32 -->JSON) is native { * };
    method unmarshal($level = 0; :$perl) {
        # We don't use the json_type enum for speed.
        given self.get_type {
            when 0 { Nil }
            when 1 { Bool(json_object_get_boolean(self)) }
            when 2 { json_object_get_double(self) }
            when 3 { json_object_get_int64(self) }
            when 4 { # Associative
                if $perl {
                    my %a;
                    my $head = self.json_object_get_object.head;
                    while $head.defined {
                        my $v = $head.v;
                        %a{$head.k} = $v.defined ?? $v.unmarshal($level+1, :perl) !! Any;
                        $head = $head.next;
                    }
                    %a;
                } else {
                    nativecast(JSON-A, self)
                }
            }
            when 5 { #Positional
                if $perl {
                    my $itr = ^json_object_array_length(self);
                    $itr .= hyper(:degree(3),:batch(10)) unless $level;
                    $itr.map({
                        with json_object_array_get_idx(self, $_) {
                            .unmarshal($level+1, :perl);
                        } else { Any }
                    }).Array;
                } else {
                    nativecast(JSON-P, self)
                }
            }
            when 6 { json_object_get_string(self) }
        }
    }

    sub json_object_new_object(-->JSON) is native { * }
    sub json_object_new_string(Str --> JSON) is native { * }
    sub json_object_new_int64(int64 --> JSON) is native { * }
    sub json_object_new_boolean(int32 --> JSON) is native { * }
    sub json_object_new_double(num64 --> JSON) is native { * }
    sub json_object_new_array(--> JSON) is native { * }
    sub json_object_array_add(JSON, JSON --> int32) is native { * }
    sub json_object_object_add(JSON, Str, JSON) is native { * }
    method marshal(Any \v) {
        given v {
            when JSON   { self }
            when Str:D  { json_object_new_string($_) }
            when Bool:D { json_object_new_boolean(+$_) }
            when Int:D  { json_object_new_int64($_) }
            when Num:D  { json_object_new_double($_) }
            when Rat:D  { json_object_new_double(.Num) }
            when Associative {
                my \obj = json_object_new_object();
                succeed obj unless .DEFINITE;
                for %($_) -> (:key($k), :value($v)) {
                    json_object_object_add(obj, $k,
                        ($v.defined ?? JSON.marshal($v) !! JSON)
                    );
                }
                obj;
            }
            when Positional {
                my \arr = json_object_new_array();
                succeed arr unless .DEFINITE;
                when Iterable {
                    for @($_) {
                        json_object_array_add(arr,
                            $_.defined ?? JSON.marshal($_) !! JSON
                        );
                    }
                    arr;
                }
                default {
                    for ^($_.elems) {
                        with v[$_] {
                            json_object_array_add(arr, JSON.marshal($_));
                        } else {
                            json_object_array_add(arr, JSON);
                        }
                    }
                    arr;
                }
            }
            default { JSON }
        }
    }

    multi method new(JSON: :$array) {
        $array ?? nativecast(JSON-P, json_object_new_array)
               !! nativecast(JSON-A, json_object_new_object);
    }

    sub json_object_put(JSON) is native { * }
    method dispose(JSON:D $self:) {
        json_object_put($self);
    }

    sub json_object_get(JSON -->JSON) is native { * }
    method externate(JSON:D) {
        json_object_get(JSON);
    }

    sub json_object_from_file(Str -->JSON) is native { * }
    multi method new-from-file(Str() $path) {
        with json_object_from_file($path)  {
            .unmarshal;
        } else {
            # TODO Make typed exception
            fail 'JSON: Error';
        }
    }

    sub json_tokener_parse_ex(Tokener, utf8, int32 -->JSON) is native { * }
    multi method new(utf8 $buf, :$strict) {
        my $tok = Tokener.new(:$strict);
        LEAVE { .free with $tok }
        with json_tokener_parse_ex($tok, $buf, $buf.bytes) {
            if $strict {
                my $i = $tok.internal;
            }
            .unmarshal;
        } else {
            # TODO Make typed exception
            my $err = $tok.get-err;
            fail 'JSON: ' ~ err-desc($err);
        }
    }

    multi method new(Str $str, :$strict = True) {
        #fail "Ilegal char" if $strict && $str ~~ / \t /;
        self.new($str.encode, :$strict)
    }

    sub json_object_to_file_ex(Str, JSON, uint32 -->uint32) is native { * }
    method to-file(Str() $path) {
        json_object_to_file_ex($path, self, 0);
    }

    sub json_object_to_json_string_ext(JSON, uint32 -->Str) is native { * }
    multi method Str(JSON:D: :$pretty) {
        my $flags = JSON_C_TO_STRING_SPACED;
        $flags = $pretty ?? JSON_C_TO_STRING_PRETTY !! JSON_C_TO_STRING_PLAIN
            if $pretty.defined;
        json_object_to_json_string_ext(self, $flags);
    }

    method get_type(--> int32) is symbol('json_object_get_type') is native { * }
    method get-type(JSON:D:) {
        type-map{self.get_type};
    }

    multi method ACCEPTS(JSON:D: Mu \t) {
        self.get-type ~~ t;
    }

    multi method Numeric(JSON:D:) {
        self.elems;
    }

    multi method perl(JSON:D:) {
        self.^name ~ ".new('" ~ self.Str ~ "')";
    }
    multi method gist(JSON:D:) {
        'JSON<' ~ json_type(self.get_type) ~ '>' ~ self.Str.substr(0,70) ~ '…';
    }
    method Perl(JSON:D:) {
        self.unmarshal(:perl);
    }
}

class JSON-P is JSON does Positional does Iterable {

    method new() {
        nextwith :array;
    }
    sub json_object_array_length(JSON --> uint32) is native { * };
    multi method elems() {
        json_object_array_length(self);
    }

    sub json_object_array_get_idx(JSON, uint32 -->JSON) is native { * };
    method AT-POS(::?CLASS:D: $idx, :$perl) {
        with json_object_array_get_idx(self, $idx) {
            .unmarshal(:$perl);
        } else { Nil }
    }

    sub json_object_array_put_idx(JSON, uint32, JSON --> int32) is native { * }
    multi method ASSIGN-POS(::?CLASS:D: $idx, JSON $new) {
        json_object_array_put_idx(self, $idx, $new);
        $new;
    }
    multi method ASSIGN-POS(::?CLASS:D: $idx, Any \v) {
        json_object_array_put_idx(self,$idx, my $new = JSON.marshal(v));
        $new;
    }

    method iterator(:$perl) {
        my int $elems = self.elems;
        my int $i = 0;
        (gather {
            while $i < $elems {
                take self.AT-POS($i, :$perl);
                ++$i;
            }
        }).iterator;
    }

    multi method Array(JSON:D:) {
        Array.from-iterator(self.iterator(:perl));
    }

    sub json_object_array_add(JSON, JSON --> int32) is native { * }
    multi method push(JSON:D: JSON:D \new) {
        json_object_array_add(self, new);
        self;
    }
    multi method push(JSON:D: Slip \val) {
        self.push: $_ for @(val);
    }
    multi method push(JSON:D: \v) {
        json_object_array_add(self, JSON.marshal(v));
        self;
    }
    multi method push(JSON:D: **@values) {
        self.push: $_ for @values;
        self;
    }
}

class JSON-A is JSON does Associative does Iterable {
    sub json_object_object_get_ex(JSON, Str, JSON is rw -->uint32) is native { * };
    multi method AT-KEY(Str $key) {
        my JSON $new = JSON.bless;
        if json_object_object_get_ex(self, $key, $new) {
            $new.unmarshal;
        }
        else { Nil }
    }

    method EXISTS-KEY(Str $key) {
        Bool(json_object_object_get_ex(self, $key, JSON));
    }

    sub json_object_object_length(JSON --> int32) is native { * };
    method elems() {
        json_object_object_length(self);
    }

    sub json_object_object_del(JSON, Str) is native { * }
    method DELETE-KEY(Str $key) {
        if json_object_object_get_ex(self, $key, my JSON $new = JSON.bless) {
            if (my $res = $new.unmarshal) ~~ JSON:D {
                # Inc refcount to compensate delete,
                $res.externate;
            }
            json_object_object_del(self, $key);
            $res;
        } else {
            Nil;
        }
    }

    sub json_object_object_add(JSON, Str, JSON) is native { * }
    multi method ASSIGN-KEY(Str $key, JSON $new) {
        json_object_object_add(self, $key, $new);
    }

    multi method ASSIGN-KEY(Str $key, Any \v) {
        json_object_object_add(self, $key, JSON.marshal(v));
    }

    method pairs() {
        my $lht = self.json_object_get_object;
        my $head = $lht.head;
        gather { while $head.defined {
            my $v = $head.v;
            my $next = $head.next; # Allow to delete current.
            take ($head.k => ($v.defined ?? $v.unmarshal !! Any));
            $head = $next;
        } }
    }
    method iterator() { self.pairs.iterator }
    method keys()     { self.pairs.map: { .key } }
    method values()   { self.pairs.map: { .value } }
    method kv()       { self.pairs.map: { |(.key, .value) } }
}

sub from-json(Str $json) is export {
    with JSON.new($json) {
        LEAVE { .dispose }
        .unmarshal(:perl);
    } else { .fail }
}

sub to-json(Any \v, :$pretty) is export {
    with JSON.marshal(v) {
        LEAVE { .dispose }
        .Str(:$pretty);
    }
}

INIT {
    without $Lib = NativeLibs::Loader.load('libjson-c.so.2') {
        .fail;
    }
}

# vim: ft=perl6 et
