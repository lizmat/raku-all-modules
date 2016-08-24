use lib <lib>;
use RT::REST::Client;

my RT::REST::Client $rt .= new: :user(%*ENV<RT_USER>), :pass(%*ENV<RT_PASS>);

printf "#%s %s %s\n\t%s\n\n",
        .id, .tags.join(' '), .subject, .url
    for $rt.search: after => Date.today.earlier: :week;
