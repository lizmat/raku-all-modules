#!/usr/bin/env perl6
use v6;
use File::Temp;

package Editsrc::Uggedit {

    # Code that allows shared variables
    sub uncomment($arg) {
	my @processedComments = $arg.lines.map: {
	    m:s/^[.'!'\s]?(.*)/[*-1];
        }
	return @processedComments.join("\n") ~ "\n";
    }

    sub reverseEscape($arg) {
	return $arg.subst(/"\\"/, "\\\\", :g).subst(/"\t"/, "\\t", :g).subst(/"\n"/, "\\n", :g).subst(/'"'/, '\\"', :g);
    }

    sub unreverseEscape($arg) {
		my regex oddSlash { '\\'['\\\\']* };
		return $arg.subst(/"\\\""/, '"', :g).subst(/<!after <oddSlash>>"\\n"/, "\n", :g).subst(/<!after <oddSlash>>"\\t"/, "\t", :g).subst(/"\\\\"/, "\\", :g);
    }

    sub dollarEscape($arg) {
	return $arg.subst(/'$'/, '\\$', :g);
    }

    my $reverseEscapeCode-Perl5 = Q:to/END/;
    sub uggedit_reverseEscape {
	my $arg = shift;
	$arg =~ s/\\/\\\\/ig;
	$arg =~ s/\n/\\n/ig;
	$arg =~ s/\t/\\t/ig;
	$arg =~ s/\"/\\\"/ig;
	return $arg;
    }
    END

    my $reverseEscapeCode-Perl6 = Q:to/END/;
    sub uggedit-reverseEscape($arg) {
	return $arg.subst(/"\\"/, "\\\\", :g).subst(/"\t"/, "\\t", :g).subst(/"\n"/, "\\n", :g).subst(/'"'/, '\\"', :g);
    }
    END

    my $reverseEscapeCode-Python = Q:to/END/;
    def uggedit_reverseEscape(arg):
      return arg.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\"", "\\\"")
    END

# The editor, is the main part of Uggedit
class Editsrc::Uggedit::Editor {
    # Rewritable strings
    has $.editLineName is rw;
    has $.editFile     is rw;
    has $.textToAdd    is rw;

    # Rewritable booleans
    has $.ignoreEditLine  is rw = False;
    has $.printField      is rw = False;
    has $.printEditLine   is rw = False;
    has $.captureField    is rw = False;
    has $.captureNonField is rw = False;
    has $.addText         is rw = False;
    has $.addTextOnce     is rw = False;
    has $.addTextUnique   is rw = False;
    has $.codeAsField     is rw = False;



    # Inaccessable strings
    has $!fileContents         = '';
    has $!capturedContents     = '';
    has $!unprintedEditLine    = '';
    has $!currentField         = '';
    has $!lastField            = '';
    has $!lastbuffer           = '';
    has $!currentbuffer        = '';
    has $!language             = '';

    # Inaccessable booleans, used
    # For better error messages
    has $!onEditLine       = False;
    has $!continueEditLine = False;
    has $!inComment        = False;
    has $!inFieldNext      = False;
    has $!inField          = False;
    has $!textAdded        = False;
    has $!isCode           = False;

    # Inaccessable Integers
    has $!lineNumber = 1;

    # Variables to be shared between code in comments
    has %.sharedVars = ();

    method reset {
	# Inaccessable strings
	$!fileContents         = '';
	$!capturedContents     = '';
	$!unprintedEditLine    = '';
	$!currentField         = '';
	$!lastField            = '';
	$!lastbuffer           = '';
	$!currentbuffer        = '';
	$!language             = '';
	$!onEditLine       = False;
	$!continueEditLine = False;
	$!inComment        = False;
	$!inFieldNext      = False;
	$!inField          = False;
	$!textAdded        = False;
	$!isCode           = False;
	$!lineNumber = 1;
	%.sharedVars = ();
    }

    # Sadly it is impossible to make this code cleaner due to the complexity
    # of lanugages. I have tried quite a bit. You have been warned.
    has %.forLanguage = (
	'perl' => sub ($varFile) {
	    my $codeInit = $reverseEscapeCode-Perl5;
	    my $codeExit =
	    qq[open(my \$uggeditFile, '>', '$varFile') or
	       die 'Failed to open file to save shared varibles';\n];
	    for %!sharedVars.kv -> $key, $value {
		$codeInit ~= "my \$$key = " ~ '"' ~
		    dollarEscape(reverseEscape($value)) ~ "\";\n";
		$codeExit ~=
		  qq[print \$uggeditFile "$key" . ' ' . uggedit_reverseEscape(\$$key) . "\\n";\n];
	    }
	    $codeExit ~= 'close $uggeditFile';
	    #print $!currentField;
	    #exit;
	    return $codeInit ~ uncomment($!currentField) ~ $codeExit;
	},
	'perl6' => sub ($varFile) {
	    my $codeInit = $reverseEscapeCode-Perl6;
	    my $codeExit =
	    qq[my \$uggeditFile = open('$varFile', :w) or
	       die 'Failed to open file to save shared varibles';\n];
	    for %!sharedVars.kv -> $key, $value {
		$codeInit ~= "my \$$key = " ~ '"' ~
		    dollarEscape(reverseEscape($value)) ~ "\";\n";
		$codeExit ~=
		  qq[\$uggeditFile.print("$key" ~ ' ' ~ uggedit-reverseEscape(\$$key) ~ "\\n");\n];
	    }
	    $codeExit ~= 'close $uggeditFile';
	    return $codeInit ~ uncomment($!currentField) ~ $codeExit;
	},
	'python' => sub ($varFile) {
	    my $codeInit = $reverseEscapeCode-Python;
	    my $codeExit = "uggeditFile = open('$varFile', 'w')\n";
	    for %!sharedVars.kv -> $key, $value {
		$codeInit ~= "$key = " ~ '"' ~
		    reverseEscape($value) ~ "\"\n";
		$codeExit ~=
		    "uggeditFile.write('$key' + ' ' + uggedit_reverseEscape($key) + \"\\n\")\n"; 
	    }
	    $codeExit ~= 'uggeditFile.close' ~ "\n";
	    return $codeInit ~ uncomment($!currentField) ~ $codeExit;
	},
    );

    method !execComment {
	my ($codeFile, $codeHandle) = tempfile;
		my ($varFile,  $varHandle ) = tempfile;
		my $varHandleReadable = open($varFile, :r);
		self.messedUp if not defined %!forLanguage{$!language};
		%!sharedVars{'field'} = $!lastField;
		my $commentCode = %!forLanguage{$!language}.($varFile);
		$codeHandle.print($commentCode);
		#print slurp($codeFile);
		my $errcode = shell qq{$!language $codeFile};
		self.messedUp($errcode.exitcode) if $errcode != 0;
		close $codeHandle;
		while defined my $varFileLine = $varHandleReadable.get {
		    my ($readVarName, $readVarValue) =
		        split(' ', $varFileLine, 2);
		    %!sharedVars{$readVarName} = 
			unreverseEscape($readVarValue);
		}
		$!lastField =  %!sharedVars{'field'};
		close $varHandle;
		close $varHandleReadable;
    }

    # Code run when a field ends
    method !endParen {
	$!inField      = False;
	$!printField   = False;
	# $!captureField = False if not $!ignoreEditLine;
	# $!captureNonField = False if not $!ignoreEditLine;
	self!execComment if $!isCode;
	if $!addText {
	    if $!addTextUnique {
		$!currentField ~= $!textToAdd if
		  not $!currentField.index($!textToAdd).defined
	    } else {
	     	$!currentField ~= $!textToAdd;
	    }
	    $!addText = False if $!addTextOnce;
	}
	$!capturedContents ~= $!lastbuffer if $!captureNonField;
	$!capturedContents ~= $!lastField if $!captureField;
	$!fileContents ~= $!lastbuffer;
	$!fileContents ~= $!lastField;
	$!lastField = $!currentField;
	$!lastbuffer = $!currentbuffer;
	$!currentField = "";
	$!currentbuffer = "";
    }

    # Hash for executing code
    has %.editLineKeys is rw = (
	';'                => sub ($arg?) { $!onEditLine       = False; },
	'\\'               => sub ($arg?) { $!continueEditLine = True;  },
	'#'                => sub ($arg?) { $!inComment        = True;  },
	'{'                => sub ($arg?) { $!inFieldNext      = True;  },
	'}'                => sub ($arg?) { self!endParen },
	'print-field'      => sub ($arg?) { $!printField       = True
					     if not $!ignoreEditLine;   },
        'capture-field'    => sub ($arg?) { $!captureField     = True
					      if not $!ignoreEditLine;  },
        'print-editline'   => sub ($arg?) { $!printEditLine    = True
					      if not $!ignoreEditLine;  },
        'capture-editline' => sub ($arg?) { $!captureNonField  = True
					      if not $!ignoreEditLine;  },
	'add-text'         => sub ($arg?) { $!addText          = True
					      if not $!ignoreEditLine;  },
	'print'            => sub ($arg?) { print shift($arg)
					      if not $!ignoreEditLine;  },
	'put'              => sub ($arg?) { print shift($arg) ~ "\n"
					      if not $!ignoreEditLine;  },
	'var'              => sub ($arg?) { %!sharedVars{shift($arg)} = "undef"
					      if not $!ignoreEditLine;  },
	'code'             => sub ($arg?) { $!isCode          = True
					      if not $!ignoreEditLine;
					    $!language = shift($arg);   },
    );

    method messedUp($errcode = Int){
	my $errorMsg = 'Uggedit failed';
	$errorMsg ~= ' on an edit line'                     if $!onEditLine;
	$errorMsg ~= ' after continuing an editline'        if $!continueEditLine;
	$errorMsg ~= ' in a comment'                        if $!inComment;
	$errorMsg ~= ' with the next line being in a field' if $!inFieldNext;
	$errorMsg ~= ' while in a field'                    if $!inField;
	$errorMsg ~= ' during the capture of an editline'   if $!captureNonField;
	$errorMsg ~= ' having added text'                   if $!textAdded;
	$errorMsg ~= " in the process of scanning code using language $!language" if $!isCode;
	$errorMsg ~= " during execution of said code resulting in error code: $errcode" if
	    defined $errcode;
	$errorMsg ~= " in file: $!editFile on line: $!lineNumber";
	$errorMsg ~= "\n\t The language you are using for Uggedit is unsupported currently\n" if
	    not defined %!forLanguage{$!language};	
	die $errorMsg;
    }

    # Reads comments starting with 
    method edit {
	self.reset();
	die "Undefined file in Uggedit" if  not defined $!editFile;
	my $editFileHandle = open $!editFile, :r;
	while defined my $editFileLine = $editFileHandle.get {
	    if $editFileLine ~~ m{^.?'//@uggedit'} or $!continueEditLine {
		$!continueEditLine = False;
		my @editArgs = split(/\s+/, $editFileLine);
		while my $editArg = shift @editArgs {
		    if $!onEditLine and not $!inComment {
			%!editLineKeys{$editArg}.(@editArgs) if
			defined %!editLineKeys{$editArg};
		    } else {
			$!onEditLine = True if $!editLineName eq $editArg or
			($!editLineName ~ "/edit") eq $editArg;
		    }
		}
	    }
	    if $!printEditLine {
		print $!unprintedEditLine ~ "\n";
		print $editFileLine ~ "\n";
		$!unprintedEditLine = "";
		$!printEditLine = False if not $!continueEditLine;
	    } elsif $!onEditLine {
		$!unprintedEditLine ~= $editFileLine ~ "\n";
	    }

	    $!currentField ~= $editFileLine ~ "\n" if $!inField;
	    print $editFileLine ~ "\n" if $!printField and $!inField;
	    $!currentbuffer ~= $editFileLine ~ "\n" if not $!inField;

	    # Put reseting satements here
	    if $!inFieldNext and not $!continueEditLine {
		$!inField     = True;
		$!inFieldNext = False;
	    }

	    if not $!continueEditLine {
		$!onEditLine      = False;
		$!printEditLine   = False;
	    }

	    $!inComment = False;
	    $!lineNumber += 1;
	}
	$!capturedContents ~= $!currentbuffer if $!captureNonField;
	$!capturedContents ~= $!currentField if $!captureField;
	$!fileContents ~= $!lastbuffer;
	$!fileContents ~= $!lastField;
	$!fileContents ~= $!currentbuffer;
	close $editFileHandle;
	spurt $!editFile, $!fileContents;
	return $!capturedContents;
    }
}

}

