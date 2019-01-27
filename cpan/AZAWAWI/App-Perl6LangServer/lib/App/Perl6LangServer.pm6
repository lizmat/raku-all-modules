
use v6;

unit class App::Perl6LangServer;

# Necessary evil to evaluate p6ddoc index data (Perl 6 data structure)
use MONKEY-SEE-NO-EVAL;

use File::Temp;
use JSON::Tiny;

# Cache p6doc index.data (Hash of help topics strings)
my %help-index;

# Text documents
my %text-documents;

method run {

  # No standard input/output buffering to prevent unwanted hangs/failures/waits
  $*OUT.out-buffer = False;
  $*ERR.out-buffer = False;

  debug-log("🙂: Starting perl6-langserver... Reading/writing stdin/stdout.");

  my $initialized = False;
  loop {
    my %headers;
    for $*IN.lines -> $line {
      # we're done here
      last if $line eq '';

      # Parse HTTP-style header
      my ($name, $value) = $line.split(': ');
      if $name eq 'Content-Length' {
          $value = +$value;
      }
      %headers{$name} = $value;
    }

    # Read JSON::RPC request
    my $content-length = 0 + %headers<Content-Length>;
    if $content-length > 0 {
        my $json    = $*IN.read($content-length).decode;
        my $request = from-json($json);
        my $id      = $request<id>;
        my $method  = $request<method>;

        #TODO throw an exception if a method is called before $initialized = True
        given $method {
          when 'initialize' {
            my $result = initialize($request<params>);
            send-json-response($id, $result);
          }
          when 'initialized' {
            # Initialization done
            $initialized = True;
          }
          when 'textDocument/didOpen' {
            text-document-did-open($request<params>);
          }
          when 'textDocument/didSave' {
            text-document-did-save($request<params>);
          }
          when 'textDocument/didChange' {
            text-document-did-change($request<params>);
          }
          when 'textDocument/didClose' {
            text-document-did-close($request<params>);
          }
          when 'textDocument/documentSymbol' {
            # When outline tree view is shown, it asks for symbols
            my $result = on-text-document-symbol($request<params>);
            send-json-response($id, $result);
          }
          when 'textDocument/hover' {
            my $result = on-text-document-hover($request<params>);
            send-json-response($id, $result);
          }
          when 'shutdown' {
            # Client requested to shutdown...
            send-json-response($id, Any);
          }
          when 'exit' {
            exit 0;
          }
        }
    }

  }
}

sub debug-log($text) {
  $*ERR.say($text);
}

sub send-json-response($id, $result) {
  my %response = %(
    jsonrpc => "2.0",
    id       => $id,
    result   => $result,
  );
  my $json-response = to-json(%response);
  my $content-length = $json-response.chars;
  my $response = "Content-Length: $content-length\r\n\r\n" ~ $json-response;
  print($response);
}

sub send-json-request($method, %params) {
  my %request = %(
    jsonrpc  => "2.0",
    'method' => $method,
    params   => %params,
  );
  my $json-request = to-json(%request);
  my $content-length = $json-request.chars;
  my $request = "Content-Length: $content-length\r\n\r\n" ~ $json-request;
  print($request);
}

sub initialize(%params) {

  #TODO handle windows
	my $index-file = qx{p6doc path-to-index}.chomp;
	unless $index-file.path ~~ :f {
		# run p6doc-index build to build the index.data file
		debug-log("Building index.data... Please wait");
		my $dummy = qqx{p6doc build};
    debug-log("Built index.data... Thanks for waiting");
	}

	if $index-file.path ~~ :f {
		debug-log("Loading index.data... Please wait");
		%help-index = EVAL $index-file.IO.slurp;
    debug-log("Loaded index.data... Thanks for waiting");
	}
	else {
		debug-log("Cannot find $index-file");
	}

  %(
    capabilities => {
      # TextDocumentSyncKind.Full
      # Documents are synced by always sending the full content of the document.
      textDocumentSync => 1,

      # Provide outline view support
      documentSymbolProvider => True,

      # Provide hover support
      hoverProvider => True
    }
  )
}

sub text-document-did-open(%params) {
  my %text-document = %params<textDocument>;
  %text-documents{%text-document<uri>} = %text-document;

  return;
}

sub publish-diagnostics($uri) {
  # Create a temporary file for Perl 6 source code buffer
	my ($file-name,$file-handle) = tempfile(:!unlink);

  # Remove temporary file when leaving lexical scope
  LEAVE unlink $file-handle;

  # Write source code and flush
  my $source = %text-documents{$uri}<text>;
	$file-handle.print($source);
  $file-handle.flush;

  # Invoke perl -c temp-filder
  #TODO handle windows platform
  my Str $output = qqx{$*EXECUTABLE -c $file-name 2>&1};

  my @problems;
  if $output !~~ /^'Syntax OK'/ &&
    $output   ~~ m/\n(.+?)at\s.+?\:(\d+)/ {

    # A syntax error occurred
    my $message     = ~$/[0];
    my $line-number = +$/[1];
    @problems.push: {
      range => {
        start => {
          line      => $line-number,
          character => 0
        },
        end => {
          line      => $line-number,
          character => 0
        },
      },
      severity => 1,
      source   => 'perl6 -c',
      message  => $message
    }
  }

  my %parameters = %(
    uri         => $uri,
    diagnostics => @problems
  );
  send-json-request('textDocument/publishDiagnostics', %parameters);
}


sub text-document-did-save(%params) {
  my %text-document = %params<textDocument>;

  return;
}

sub text-document-did-change(%params) {
  my %text-document          = %params<textDocument>;
  my $uri                    = %text-document<uri>;
  %text-documents{$uri}<text> = %params<contentChanges>[0]<text>;
  publish-diagnostics($uri);

  return;
}

sub text-document-did-close(%params) {
  my %text-document = %params<textDocument>;
  %text-documents{%text-document<uri>}:delete;

  return;
}

constant symbol-kind-file = 1;
constant symbol-kind-module = 2;
constant symbol-kind-namespace = 3;
constant symbol-kind-package = 4;
constant symbol-kind-class = 5;
constant symbol-kind-method = 6;
constant symbol-kind-property = 7;
constant symbol-kind-field = 8;
constant symbol-kind-constructor = 9;
constant symbol-kind-enum = 10;
constant symbol-kind-interface = 11;
constant symbol-kind-function = 12;
constant symbol-kind-variable = 13;
constant symbol-kind-constant = 14;
constant symbol-kind-string = 15;
constant symbol-kind-number = 16;
constant symbol-kind-boolean = 17;
constant symbol-kind-array = 18;
constant symbol-kind-object = 19;
constant symbol-kind-key = 20;
constant symbol-kind-null = 21;
constant symbol-kind-enummember = 22;
constant symbol-kind-struct = 23;
constant symbol-kind-event = 24;
constant symbol-kind-operator = 25;
constant symbol-kind-typeparameter = 26;

# Called when the client sends a textDocument/documentSymbol request
sub on-text-document-symbol(%params) {
  my %text-document = %params<textDocument>;
  my $uri = %text-document<uri>;

  #TODO handle heredoc comments

  # Remove line comments
  my $source-code = %text-documents{$uri}<text> or return [];
  $source-code    = $source-code.lines.map({
    $_.subst(/ '#' (.+?) $ /, { '#' ~ (" " x $0.chars) })
  }).join("\n");

  my $to = 0;
  my $line-number = 0;
  my @line-ranges;
  for $source-code.lines -> $line { 
    my $length = $line.chars;
    my $from = $to;
    $to += $length;
    @line-ranges.push: {
      line-number => $line-number++,
      from        => $from,
      to          => $to
    };
  }
  
  sub to-line-number(Int $position) returns Int {
    for @line-ranges -> $line-range {
      if $position >= $line-range<from> && $position <= $line-range<to> {
        return $line-range<line-number>;
      }
    }
    return -1;
  }
  
  my %to-symbol-kind = %(
    'class'   => symbol-kind-class,
    'grammar' => symbol-kind-class,
    'module'  => symbol-kind-module,
    'package' => symbol-kind-namespace,
    'class'   => symbol-kind-class,
    'sub'     => symbol-kind-function,
    'method'  => symbol-kind-method,
    'my'      => symbol-kind-variable,
    'state'   => symbol-kind-variable,
  );

  # Symbol information
  my @results;

  sub add-results(@declarations) {
    for @declarations -> $decl {
      my $type            = ~$decl[0];
      my Int $line-number = to-line-number($decl[0].from);
      my Int $kind        =  %to-symbol-kind{$type};
      my %record = %(
        name => ~$decl[1],
        kind => $kind,
        location => {
          uri => $uri,
          range => {
            start => {
              line      => $line-number,
              character => 0, # $decl[0].from
            },
            end => {
              line      => $line-number,
              character => 0, # $decl[0].from
            },
          },
        },
      );
      @results.push(%record);
    }
  }
  
  # Find all package declarations
  my @package-declarations = $source-code ~~ m:global/
    # Declaration
    ('class'| 'grammar'| 'module'| 'package'| 'role')
    # Whitespace
    \s+
    # Identifier
    (\w+ ('::' \w+))
  /;
  add-results(@package-declarations);
  
  my @routine-declarations = $source-code ~~ m:global/
    # Declaration
    ('sub'| 'method')
    # Whitespace
    \s+
    # Identifier
    (\w (\w | '-')*)
  /;
  add-results(@routine-declarations);

  # SymbolInformation[]
  return @results;
}

# Called when client gets a 'textDocument/hover' request.
sub on-text-document-hover(%params) {
  my %text-document = %params<textDocument>;
  my $uri = %text-document<uri>;
  my %position = %params<position>;

  my $source-code = %text-documents{$uri}<text> or return [];

  my $hover-text  = '';
  my $line-number = 0;
  my $start-pos  = 0;
  for $source-code.lines -> $line {
    if $line-number == %position<line> {
      my @chars  = $line.comb;
      my $buffer = '';
      my $pos    = %position<character>;
      for 0..@chars.elems - 1 -> $i {
        my $ch = @chars[$i];
        if $ch eq any(' ', '.', '(', ')', '<', '>', ';', ',' , '{', '}', '[', ']', '+', ':') {
          last if $i >= $pos;
          $start-pos = $i;
          $buffer    = '';
        } else {
          $start-pos = $i if $buffer eq '';
          $buffer ~= $ch;
        }
      }
      $hover-text = $buffer.trim;
      last
    }
    $line-number++;
  }

  my $hover-contents = help-search($hover-text);
  $hover-contents = "Unable to find help for '$hover-text'" if $hover-contents eq '';

  #TODO add definition for variables hover support

  {
    # The hover content
    contents => $hover-contents,
    range => {
      start => {
        line      => %position<line>,
        character => $start-pos
      },
      end   => {
        line      => %position<line>,
        character => $start-pos + $hover-text.chars
      }
    }
  };
}

sub help-search(Str $pattern is copy) {

  debug-log("help-search('$pattern')");
  return '' unless %help-index;

	# Trim the pattern and make sure we dont fail on undefined
	$pattern = $pattern // '';
	$pattern = $pattern.trim;

	my @results;
  constant MAX-SIZE = 5;
	for %help-index.keys -> $topic {

		if $topic ~~ m:i/"$pattern"/ {
      @results.push({
  			"name"    => $topic,
  			"matches" => %help-index{$topic}.unique(:as(&lc))
  		});

      last if @results.elems >= MAX-SIZE;
    }

	}

	@results = @results.sort(-> $a, $b { uc($a) leg uc($b) });

	my @contents;
	LOOP: for @results -> $result {

		for @($result<matches>) -> $match {
      # Compose help keyword from matches
			my $name = $match[1].subst(/^ ( 'sub'| 'routine' | 'method' ) /, "").trim;
			my $keyword = $match[0] ~ $name;

      my $proc      = run 'p6doc', '-n', $keyword, :out;
      my $content   = $proc.out.slurp(:close).chomp;
      my $exit-code = $proc.exitcode;
      if $exit-code == 0 {
        # On success, add p6doc output
        @contents.push($content);

        #TODO how many p6doc choices to show the user
        last LOOP
      } else {
        debug-log("p6doc failed with exit code: {$exit-code}")
      }

		}

	}

	@contents.join("\n---\n");
}
