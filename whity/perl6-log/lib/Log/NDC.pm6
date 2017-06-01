unit class Log::NDC;

has @!stack = ();

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

    return @!stack.join(' ');
}

method clear() {
    @!stack = ();
    return self;
}
