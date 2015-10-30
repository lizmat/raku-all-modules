use v6;
use Test;

use lib 'lib';

use Email::Simple;

plan 37;

my %headers = (
    badly-folded    => {
        X-Original-To   => 'adam@mail1.internal.foo.com',
        From            => 'x <x@foo.com>',
        User-Agent      => 'Mozilla Thunderbird 1.0.6 (Windows/20050716)',
        Subject         => 'My subject',
    },
    josey-nobody    => {
        Received        => '(qmail 1679 invoked by uid 503); 13 Nov 2002 10:10:49 -0000',
        To              => 'austin-group-l@opengroup.org',
        Content-Type    => 'text/plain; charset=us-ascii',
    },
    junk-in-header  => {
        Header-One      => 'steve biko',
        Header-Two      => 'stir it up',
    },
    long-msgid      => {
        Content-Type    => qq[text/plain; charset="iso-8859-1"],
        Message-Id      => '<LYRIS-7842440-223299-2004.05.28-16.02.21--jwb#paravolve.net@ls.encompassus.org>',
        List-Unsubscribe    => '<mailto:leave-encompass_points-7842440G@ls.encompassus.org>',
        Received            => q[from ls2.sba.com ([206.69.91.6]:22703 helo=ls.sba.com) by]
                             ~ q[ smtp.paravolve.net with smtp (Exim 4.34) id 1BTp3v-0007sJ-Pj]
                             ~ q[ for jwb@paravolve.net; Fri, 28 May 2004 21:38:49 +0000],
    },
    many-repeats    => {
        Baz             => '0 0',
        Foo             => '1 3 5 7 9 B D F H J L N P R T V X Y',
        Bar             => '2 4 6 8 A C E G I K M O Q S U W Z',
    },
);

for %headers.keys.sort -> $file {
    my $m;
   lives-ok {$m = Email::Simple.new(slurp "t/test-mails/$file") }, "Could parse $file";;
   my %h := %headers{$file};
   my $header-str = $m.header-obj.Str;
   for %h.sort -> $p {
       is ~$m.header($p.key, :multi).list, $p.value, "Header $p.key() in mail $file";
       ok defined($header-str.index($p.key)), "Header text for $file contains $p.key()"
           or diag("Header-string: $header-str.perl()");
   }
}
