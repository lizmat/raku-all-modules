use ASN::Serializer;

class ASN::Serializer::Async {
    has Supplier::Preserving $!out = Supplier::Preserving.new;
    has Supply $!bytes = $!out.Supply;
    has ASN::Serializer $!serializer = ASN::Serializer.new;

    method bytes(--> Supply) {
        $!out;
    }

    method process($value) {
        $!out.emit: $!serializer.serialize($value);
    }

    method close() {
        $!out.done;
    }
}