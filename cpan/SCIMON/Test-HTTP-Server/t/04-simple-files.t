use v6.c;
use Test;
use File::Temp;
use Test::HTTP::Server;
use HTTP::UserAgent;

my $server = init_env();

my $ua = HTTP::UserAgent.new();

for { "file.txt" => {
            "func" => &text-content,
            "type" => "text/plain"
        },
      "file.html" => {
            "func" => &html-content,
            "type" => "text/html"
        },
    }.kv -> $file, %details {
    subtest "$file reading", {
        my $response = $ua.get( "http://localhost:{$server.port}/{$file}" );
        is $response.code, 200, "File exists. So it's a 200";
        is $response.content, %details<func>(), "File content matches";
        is $response.field('Content-Type').values, [ %details<type> ], "Content type is correct";

        my @events = $server.events;
        is @events[0].path, "/{$file}", "Expected path called";
        is @events[0].method, 'GET', "Expected method used";
        is @events[0].code, 200, "Expected response code";
        is $server.clear-events, 1, "One event cleared from the list";
    }
}
        
done-testing;


sub init_env() {
    my $folder = tempdir();
    
    for { "file.txt" => &text-content, "file.html" => &html-content }.kv -> $name, &func {
        my $fh = "$folder/{$name}".IO.open :w;
        $fh.print( &func() );
        $fh.close;
    }
    
    Test::HTTP::Server.new( :dir($folder) );

}

sub text-content() {
    q:to/EOF/;
    Text file
    EOF
}

sub html-content() {
    q:to/EOF/;
    <html>
    <head>
        <title>Test HTML</title>
    </head>
    <body>
        <h1>Test</h1>
    </body>
    </html>
    EOF
}
