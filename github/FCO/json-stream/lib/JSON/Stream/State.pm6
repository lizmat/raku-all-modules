use JSON::Stream::Type;
unit class State;

has         @.subscribed;
has Type    @.types;
has Str     @.path = '$';
has Str     %.cache is default("");

method type 																is pure { @!types.tail }
method path-key(@path = @!path) 											is pure { @path.join: "." }
method add-to-cache($chunk, :%cache = %!cache, :@path = @!path --> Hash()) 	is pure {
    |%cache,
    |do for @path.produce: &[,] -> @p {
        my $path = self.path-key: @p;
        do if @p ~~ @!subscribed.any {
            $path => %cache{$path} ~ $chunk
        }
    }
}
method remove-from-cache($chunk, :%cache = %!cache, :@path = @!path --> Hash()) is pure {
    |self.add-to-cache($chunk, :%cache, :path(self.pop-path: :@path)).grep: { .key !~~ self.path-key: @path }
}
method add-type(Type $type, :@types = @!types           --> List) is pure { |@types, $type }
method change-type(Type $type, :@types = @!types        --> List) is pure { self.add-type: $type, :types(self.pop-type: :@types) }
method pop-type(UInt $num = 1, Type @types = @!types    --> List) is pure { |@types.head: *-$num }
method pop-path(UInt $num = 1, :@path = @!path          --> List) is pure { |@path.head: *-$num }
method add-path(Str $path, :@path = @!path              --> List) is pure { |@path, $path }
method increment-path(Str :@path = @!path               --> List) is pure {
    #say @path;
    my Str $new-index = ~(@path.tail + 1);
    self.add-path: :path(self.pop-path: :@path), $new-index
}
method cond-emit(:%cache = %!cache, :@path = @!path) is pure {
    #say "cond-emit {%cache.perl}, {self.path-key: :@path}";
    my $path = self.path-key: @path;
    emit %cache{$path}:p if @path ~~ @!subscribed.any
}
method cond-emit-concat($chunk = "", :%cache = %!cache, :@path = @!path) is pure {
    #say "cond-emit-concat {$chunk.perl}, {%cache.perl}, {@path.perl}";
    self.cond-emit: :cache(self.add-to-cache: $chunk), :@path
}
method gist {
    qq:to/END/;
        types: { @!types.join: ", " }
        path : { self.path-key }
        cache: { %!cache }
    END
}
