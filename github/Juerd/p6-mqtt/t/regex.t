use v6;
use Test;
use MQTT::Client;

my &far := &MQTT::Client::filter-as-regex;

# Boring spec tests, the "non normative comments" from the MQTT 3.1.1 draft

SECTION_4_7_1_2: {
    my ($regex, $filter, $topic);

    $regex = far($filter = "sport/tennis/player1/#");

    $topic = "sport/tennis/player1";
    like($topic, $regex, "4.7.1.2, '$topic' should match '$filter'");

    $topic = "sport/tennis/player1/ranking";
    like($topic, $regex, "4.7.1.2, '$topic' should match '$filter'");

    $topic = "sport/tennis/player1/wimbledon";
    like($topic, $regex, "4.7.1.2, '$topic' should match '$filter'");

    $regex = far($filter = "sport/#");

    $topic = "sport";
    like($topic, $regex, "4.7.1.2, '$topic' should match '$filter'");
}

SECTION_4_7_1_3: {
    my ($regex, $filter, $topic);

    $regex = far($filter = "sport/tennis/+");

    $topic = "sport/tennis/player1";
    like($topic, $regex, "4.7.1.3, '$topic' should match '$filter'");

    $topic = "sport/tennis/player2";
    like($topic, $regex, "4.7.1.3, '$topic' should match '$filter'");

    $topic = "sport/tennis/player1/ranking";
    unlike($topic, $regex, "4.7.1.3, '$topic' should not match '$filter'");

    $regex = far($filter = "sport/+");

    $topic = "sport";
    unlike($topic, $regex, "4.7.1.3, '$topic' should not match '$filter'");

    $topic = "sport/";
    like($topic, $regex, "4.7.1.3, '$topic' should match '$filter'");
}

SECTION_4_7_2_1: {
    my ($regex, $filter, $topic);

    $regex = far($filter = "#");
    $topic = "\$SYS/something";
    unlike($topic, $regex, "4.7.2.1, '$topic' should not match '$filter'");

    $regex = far($filter = "+/monitor/Clients");
    $topic = "\$SYS/monitor/Clients";
    unlike($topic, $regex, "4.7.2.1, '$topic' should not match '$filter'");

    $regex = far($filter = "\$SYS/#");
    $topic = "\$SYS/something";
    like($topic, $regex, "4.7.2.1, '$topic' should match '$filter'");

    $regex = far($filter = "\$SYS/monitor/+");
    $topic = "\$SYS/monitor/Clients";
    like($topic, $regex, "4.7.2.1, '$topic' should match '$filter'");
}

# Now, let's try a more systematic approach

my @match = (
    # Topic             Should match all of these, but none of the
    #                   other ones that are listed for other topics.
    "/"             => <# /# +/+ />,
    "foo"           => <# +   foo/# foo>,
    "foo/bar"       => <# +/+ foo/# foo/bar/# foo/+ +/bar foo/+/#>,
    "foo//bar"      => <# +/+/+ foo/# foo//bar foo/+/bar foo/+/# foo//+>,
    "/foo"          => <# /# +/+ /foo /foo/#>,
    "/\$foo"        => <# /# +/+ /$foo /$foo/#>,  # Not special
    "/foo/bar"      => <# /# +/+/+ /foo/#>,
    "///"           => <# /# +/+/+/+>,
    "foo/bar/baz"   => <# +/+/+ foo/# foo/bar/# foo/+/#
                        +/bar/baz foo/+/baz foo/bar/+ +/+/baz>,
    "\$foo"         => <$foo $foo/#>,  # Special because it begins with $
    "\$SYS/foo"     => <$SYS/# $SYS/+ $SYS/foo>,
    "\$SYS/foo/bar" => <$SYS/# $SYS/+/+ $SYS/foo/bar $SYS/+/bar $SYS/foo/+>,
    "fo2/bar/baz"   => <# fo2/bar/baz +/+/+ +/+/baz +/bar/baz>,
    "foo///baz"     => <# foo/# foo/+/# foo/+/+/baz +/+/+/+>,
    "foo/bar/"      => <# foo/# foo/+/# foo/bar/+ foo/bar/# +/+/+>,
);

my @all_filters;
@all_filters = @match.map(|*.value).unique.sort;

for @match {
    my $topic = .key;
    my @should_match = @( .value );
    my @should_not_match = @all_filters.grep: { $_ ne any @should_match };

    for @should_match -> $filter {
        my $regex = far( $filter );
        like($topic, $regex, "'$topic' should match '$filter'");
    }

    for @should_not_match -> $filter {
        my $regex = far( $filter );
        unlike($topic, $regex, "'$topic' should not match '$filter'");
    }
}

# These are from mosquitto's 03-pattern-matching.py
my @mosquitto_tests = split "\n", q[
pattern_test("#", "test/topic")
pattern_test("#", "/test/topic")
pattern_test("foo/#", "foo/bar/baz")
pattern_test("foo/+/baz", "foo/bar/baz")
pattern_test("foo/+/baz/#", "foo/bar/baz")
pattern_test("foo/+/baz/#", "foo/bar/baz/bar")
pattern_test("foo/foo/baz/#", "foo/foo/baz/bar")
pattern_test("foo/#", "foo")
pattern_test("/#", "/foo")
pattern_test("test/topic/", "test/topic/")
pattern_test("test/topic/+", "test/topic/")
pattern_test("+/+/+/+/+/+/+/+/+/+/test", "one/two/three/four/five/six/seven/eight/nine/ten/test")

pattern_test("#", "test////a//topic")
pattern_test("#", "/test////a//topic")
pattern_test("foo/#", "foo//bar///baz")
pattern_test("foo/+/baz", "foo//baz")
pattern_test("foo/+/baz//", "foo//baz//")
pattern_test("foo/+/baz/#", "foo//baz")
pattern_test("foo/+/baz/#", "foo//baz/bar")
pattern_test("foo//baz/#", "foo//baz/bar")
pattern_test("foo/foo/baz/#", "foo/foo/baz/bar")
pattern_test("/#", "////foo///bar")
];

sub pattern_test {
    my ($pattern, $match) = @_;
    my $regex = far($pattern);
    like($match, $regex, "mosquitto: '$match' should match '$pattern'");
}

EVAL $_ for @mosquitto_tests;


done-testing;
