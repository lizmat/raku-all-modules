use v6;

use Email::Notmuch;
use File::Temp;

use Test;

plan 19;

my %mails =
    'first_mail' => "From: bob\@example.com\n
To: jim\@example.com\n
Date: Sun, 25 Oct 2015 17:39:52 -0400\n
Message-ID: <1445809192.4116.1.camel\@example.com>\n
Subject: first_mail\n
\n
\n
bob",
    'second_mail' => "From: jim\@example.com\n
To: bob\@example\n
Date: Sun, 26 Oct 2015 16:19:00 -0100\n
Message-ID: <21343r43tr\@example.com>\n
In-Reply-To: <1445809192.4116.1.camel\@example.com>\n
References: <1445809192.4116.1.camel\@example.com>\n
Subject: re: first_mail\n
\n
\n
roberto\n
jjim";

my $test_dir = tempdir();
ok mkdir($test_dir);
my $database = Database.create($test_dir);
ok $database.get_version();

for keys %mails -> $name {
    my $fh = open($test_dir ~ '/' ~ $name ~ '.eml', :w);
    $fh.print(%mails{$name});
    $fh.close();
}
isa-ok $database.get_version(), Int;
my $first_message = $database.add_message($test_dir ~ '/first_mail.eml');
isa-ok $first_message, Message;

ok $first_message.get_header('from') eq 'bob@example.com';
ok $first_message.add_tag('new') == NOTMUCH_STATUS_SUCCESS;
ok $first_message.get_tags().all().grep('new');
ok $first_message.remove_tag('new') == NOTMUCH_STATUS_SUCCESS;
nok $first_message.get_tags().all().grep('new');

isa-ok $database.add_message($test_dir ~ '/second_mail.eml'), Message;
isa-ok $database.find_message_by_filename($test_dir ~ '/second_mail.eml'), Message;

my $query = Query.new($database, 'from:example.com');
isa-ok $query, Query;

my $messages = $query.search_messages();
isa-ok $messages, Messages;
ok $messages.all() == 2;

my $message = $database.find_message_by_filename($test_dir ~ '/first_mail.eml');
isa-ok $message.get_message_id(), Str;
isa-ok $message.get_thread_id(), Str;


$query = Query.new($database, 'thread:' ~ $message.get_thread_id());
my $threads = $query.search_threads();
my $thread_from_query = $threads.get();
ok $thread_from_query.get_thread_id() eq $message.get_thread_id();


$query = Query.new($database, 'thread:this_thread_doesnt_exist');
$threads = $query.search_threads();
ok $threads.all() == 0, 'search_threads return 0 thread';



ok $database.close() == NOTMUCH_STATUS_SUCCESS;
