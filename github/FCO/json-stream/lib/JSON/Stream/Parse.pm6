use JSON::Stream::Type;
use JSON::Fast;
unit class Parser;

has         @.subscribed;
has Type    @.types = init;
has Str     @.path = '$';
has Str     %.cache is default("");

method json-path($num = 0) { @!path.head(* - $num).join: "." }

#my $*DEBUG = True;
sub debug(|c) { note |c if $*DEBUG }
constant @stop-words = '{', '}', '[', ']', '"', ':', ',';

method add-to-cache($chunk, $from = 0) {
    for $from .. (@!path - 1) -> $i {
        my @p = |@!path.head(* - $i);
        %!cache{self.json-path: $i} ~= $chunk if @!subscribed.grep: { @p ~~ $_ }
    }
}

method emit-pair($num = 0) {
    my @p = |@!path.head(* - $num);
    debug %!cache{self.json-path: $num};
    emit self.json-path($num) => from-json %!cache{self.json-path: $num}:delete if @!subscribed.grep: { @p ~~ $_ }
}

#init object array string key value
multi method parse(Str $chunk) {
    #say self;
    debug "chunk: $chunk; type: @!types.tail()";
    given @!types.tail {
        #init object array string key value
        when init {
            given $chunk {
                when not @stop-words.grep: $chunk {
                    debug "parse generic";
                    self.add-to-cache: $chunk;
                    self.emit-pair;
                }
                when '"' {
                    debug "parse string start";
                    @!types.push: string;
                    self.add-to-cache: '"';
                }
                when '{' {
                    debug "parse object start";
                    self.add-to-cache: '{';
                    @!types.push: object;
                }
                when '[' {
                    debug "parse array start";
                    self.add-to-cache: '[';
                    @!types.push: array;
                    @!path.push: "0";
                }
            }
        }
        when object {
            given $chunk {
                when '"' {
                    debug "parse object key start";
                    self.add-to-cache: '"';
                    @!types.push: key;
                }
                when ':' {
                    debug "parse object key sep";
                    self.add-to-cache: ':', 1;
                    @!types.push: value;
                }
                when '}' {
                    debug "parse object end";
                    @!path.pop;
                    self.add-to-cache: '}';
                    self.emit-pair;
                    @!types.pop;
                }
            }
        }
        when array {
            given $chunk {
                when '{' {
                    debug "parse object start";
                    self.add-to-cache: '{';
                    @!types.push: object;
                }
                when '"' {
                    debug "parse string start";
                    @!types.push: string;
                    self.add-to-cache: '"';
                }
                when not @stop-words.grep: $chunk {
                    debug "parse generic";
                    self.add-to-cache: $chunk;
                    self.emit-pair;
                }
                when ',' {
                    debug "parse array sep";
                    self.add-to-cache: ',';
                    %!cache{@.json-path}:delete;
                    @!path.tail++;
                }
                when ']' {
                    debug "parse array end";
                    self.add-to-cache: ']', 1;
                    self.emit-pair: 1;
                    @!types.pop;
                    @!path.pop;
                }
                when '[' {
                    debug "parse array start";
                    self.add-to-cache: '[';
                    @!types.push: array;
                    @!path.push: "0";
                }
            }
        }
        when string {
            given $chunk {
                when '"' {
                    debug "parse string end";
                    self.add-to-cache: '"';
                    self.emit-pair;
                    @!types.pop;
                }
                default {
                    debug "parse string body";
                    self.add-to-cache: $chunk;
                }
            }
        }
        when key {
            given $chunk {
                when not @stop-words.grep: $chunk {
                    debug "parse object key body";
                    self.add-to-cache: $chunk;
                    @!path.push: $chunk;
                }
                when '"' {
                    debug "parse object key end";
                    self.add-to-cache: '"', 1;
                    @!types.pop;
                }
            }
        }
        when value {
            given $chunk {
                when '{' {
                    debug "parse object start";
                    self.add-to-cache: '{';
                    @!types.push: object;
                }
                when '"' {
                    debug "parse string start";
                    @!types.push: string;
                    self.add-to-cache: '"';
                }
                when not @stop-words.grep: $chunk {
                    debug "parse generic";
                    self.add-to-cache: $chunk;
                    self.emit-pair;
                }
                when ',' {
                    debug "parse object sep";
                    self.add-to-cache: ',';
                    @!types.pop;
                    @!path.pop;
                }
                when '}' {
                    @!types.pop;
                    self.parse: '}';
                }
                when '[' {
                    debug "parse array start";
                    self.add-to-cache: '[';
                    @!types.push: array;
                    @!path.push: "0";
                }
            }
        }
    }
}
