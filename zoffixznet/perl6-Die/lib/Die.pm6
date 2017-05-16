unit module Die;

multi sub die (Cool:D $msg where .ends-with: "\n") is export {
    note $msg.chop;
    exit 1;
}
