unit package RT::REST::Client::Grammar;

grammar Tickets {
    rule TOP { <header>
        [
            $<no-results>='No matching results.'
            | [<ticket> ]+
        ]
    }
    token header { 'RT/' [\d+]**3 % '.' \s+ '200 Ok' }
    token ticket { $<id>=\d+ ':' <.ws> [<tag> <.ws>?]* <.ws>? $<subject>=\N+ }
    token tag { '[' ~ ']' $<tag-name>=.+? }
}
