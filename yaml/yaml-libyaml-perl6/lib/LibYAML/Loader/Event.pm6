use v6;

class LibYAML::Loader::Event {
    has @.events;

    method stream-start-event(Hash $event, $parser) {
        $event<name> = "stream-start-event";
        @.events.push: $event;
    }

    method stream-end-event(Hash $event, $parser) {
        $event<name> = "stream-end-event";
        @.events.push: $event;
    }

    method document-start-event(Hash $event, $parser) {
        $event<name> = "document-start-event";
        @.events.push: $event;
    }

    method document-end-event(Hash $event, $parser) {
        $event<name> = "document-end-event";
        @.events.push: $event;
    }

    method mapping-start-event(Hash $event, $parser) {
        $event<name> = "mapping-start-event";
        @.events.push: $event;
    }

    method mapping-end-event(Hash $event, $parser) {
        $event<name> = "mapping-end-event";
        @.events.push: $event;
    }

    method sequence-start-event(Hash $event, $parser) {
        $event<name> = "sequence-start-event";
        @.events.push: $event;
    }

    method sequence-end-event(Hash $event, $parser) {
        $event<name> = "sequence-end-event";
        @.events.push: $event;
    }

    method scalar-event(Hash $event, $parser) {
        $event<name> = "scalar-event";
        @.events.push: $event;
    }

    method alias-event(Hash $event, $parser) {
        $event<name> = "alias-event";
        @.events.push: $event;
    }

}
