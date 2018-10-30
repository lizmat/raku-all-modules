class Person {
    has $.first-name;
    has $.last-name;

    method full-name() {
        return $.first-name ~ ' ' ~ $.last-name;
    }
}
