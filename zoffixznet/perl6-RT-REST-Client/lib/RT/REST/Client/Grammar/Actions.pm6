unit package RT::REST::Client::Grammar::Actions;

my class RT::REST::Client::Ticket {
    has $.id;
    has $.tags;
    has $.subject;
    has $.url;
}

class Tickets {
    has $.ticket-url;

    method TOP ($/) {
        if $<no-results> {
            make [];
            return;
        }
        my @tickets;
        for $<ticket> -> $ticket {
            @tickets.push: RT::REST::Client::Ticket.new:
                id       => +.<id>,
                tags     => .<tag>.list.map({.<tag-name>.uc}),
                subject  => ~.<subject>,
                url      => $!ticket-url ~ +.<id> ~ '#ticket-history',
            given $ticket;
        }
        make @tickets;
    }
}
