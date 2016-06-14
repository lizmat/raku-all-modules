use v6;
use App::AizuOnlineJudge::Submittable;

unit class App::AizuOnlineJudge::IntroductionCourse;
also does App::AizuOnlineJudge::Submittable;

use URI;
use XML;
use HTTP::UserAgent;

has $!ua;
has URI $.send-uri;
has URI $.activity-uri;
has $.code;
has $.problem-number;
has $.user;
has $.lesson-id;
has $.language;
has %!form;

submethod BUILD(:$!code, :$!problem-number, :$!user, :$!lesson-id, :$!language) {
    self.validate-code($!code);
    self.validate-language($!language);
    self.validate-problem-number($!problem-number);
    $!ua = HTTP::UserAgent.new;
    $!send-uri = URI.new('http://judge.u-aizu.ac.jp/onlinejudge/webservice/submit');
    $!activity-uri = URI.new("http://judge.u-aizu.ac.jp/onlinejudge/webservice/lesson_submission_log?user_id=$!user&lesson_id=$!lesson-id");
    %!form := {
	userID => $!user,
	password => self.get-password,
	problemNO => $!problem-number,
	lessonID => $!lesson-id,
	language => $!language,
	sourceCode => $!code.IO.slurp
    };
}

method run() {
    self.ask-result($!user, $!lesson-id, self.send-code(%!form)).say;
}

method send-code(%form) returns DateTime {
    my DateTime $send-time .= new(now);
    my $response = $!ua.post($!send-uri, %form);
    self.validate-response($response);
    return $send-time;
}

method ask-result($user, $lesson-id, $send-time) returns Str {
    my Bool $success = False;
    loop (my $try-count = 1; $try-count <= 5; $try-count++){
	self.wait($try-count);
	my $status-response = $!ua.get($!activity-uri);
	next if not $status-response.is-success;
	
	my %latest = self.get-latest-activity($status-response.content);
	if %latest<submission-date> >= $send-time {
	    return sprintf("%s %.2f sec", [%latest<status>, %latest<cputime> / 100]);
	}
    }
    
    if not $success {
	die "ERROR: Timeout";
    }
}

method get-latest-activity(Str $xml-text is copy) returns Hash {
    $xml-text .= subst(/\n/, :g, "");
    my $xml = from-xml($xml-text);
    my @status-list = <CompileError WrongAnswer TimeLimitExceeded MemoryLimitExceeded Accepted OutputLimitExceeded RuntimeError PresentationError>;
    my DateTime $submission-date .= new($xml[0].elements(:TAG('submission_date'), :SINGLE).contents.shift.text.Int / 1000);
    my Str $status = @status-list[$xml[0].elements(:TAG('status_code'), :SINGLE).contents.shift.text.Int];
    my Int $cputime = $xml[0].elements(:TAG('cputime'), :SINGLE).contents.shift.text.Int;
    my %latest;
    %latest<submission-date> = $submission-date;
    %latest<status> = $status;
    %latest<cputime> = $cputime;
    return %latest;
}

method validate-problem-number($problem-number) returns Bool {
    if $problem-number.chars != 1 {
	die "ERROR: Invalid problem-number was specified";
    }
    if not $problem-number ~~ m/<[A .. Z]> ** 1/ {
	die "ERROR: Invalid problem-number was specified";
    }
    return True;
}
