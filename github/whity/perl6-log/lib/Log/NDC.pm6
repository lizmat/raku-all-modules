unit class Log::NDC;

has @!stack = ();

method new(*@elements) {
    return self.bless(elements => @elements);
}

submethod BUILD(:@elements) {
    @!stack = @elements.clone;
}

method push(Str $value) {
    @!stack.push($value);
    return self;
}

method pop() {
    if (@!stack.elems > 0) {
        @!stack.pop;
    }

    return self;
}

method get() {
    if (@!stack.elems == 0) {
        return 'undef';
    }

    return @!stack.join(q{ });
}

method clear() {
    @!stack = ();
    return self;
}

method Array() {
    return @!stack.clone;
}
