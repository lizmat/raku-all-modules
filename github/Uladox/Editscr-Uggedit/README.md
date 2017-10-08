# Editsrc-Uggedit
>"The obvious in-source Perl6 based solution to avoid repetion in modifing text by using embedded code with your languages of choice, or just scanning using a perl6 module."
aka
>"That one thing that does all that crazy language stuff an things."


## The pitch
Joepaulaten was a librarian in the C sense. The job the poor fellow had the unluck misfortune of undertaking was the maintaining of the header file for the library. Everytime a datastructure changed, the bloke had to copy the changes into the the header file for the library. The task was simple enough, just copy and paste, but the task just gnawed at him due to its repetative nature. One day he wrote a script to do the task for him, and after an hour and a half or so it worked. Soon the directory was either filled with scripts or had a large script. All seemed good to Joepaulaten.  
**What he did not realize was that the writing of scripts was a repetative process.**

### So what's the solution?
This is a question where there is no real perfect answer. How do we avoid repeating ourselves when it comes to text, especially in situations where a simple program can fix the problem once and for all, but clutters a directory and has a possibly unclear purpose. Many people feel the purpose should be made clear by seperating code and data, such that it is natural to have all these scripts in a single place. I feel the program should be right where the text it is acting on is, embedded in an obvious fashion with maybe a comment, since code is data to me. This program is designed around the idea of *obvious* embedding of code around data that itself might be code in a way that is reasonably consistant between languages when it makes sense to be. Also I just like looking for excuses to mix code togeather in ways that aren't *entirely* stupid.

### Ok, I get it. So how do I actually use this?
#### Here is a file that has Uggedit fields called *basic*

```
#//@uggedit src_k {
Some text is to be
put on in this field
Due to languages without
multiline comments, the denoter
of an uggedit field: //@uggedit
allows an optional single character
before it.
//@uggedit src_k }
//@uggedit src_k/edit code perl6 {
$field ~= "Look: \"This text won't be added the first time\"\n";
#! # Also for languages without multiline comments
#! # A line stating with any character, then a '!'
#! # followed by whitespace will still be read
#! print  "just without those things read\n";
//@uggedit src_k/edit }
```

#### Here is a test that should explain a bit

```
use v6;

use Test;
plan 3;

use Editsrc::Uggedit;
{
    my $test-Uggedit = Editsrc::Uggedit::Editor.new(
     	editLineName => 'src_k',
    	editFile => 'basic',
	    ignoreEditLine => True,
	    addText => True,
	    addTextOnce => True,
	    textToAdd => "# This is some added Text\n",
	    captureField => True,
    );
    my $capturedText = $test-Uggedit.edit;
    ok $capturedText.index("# This is some added Text").defined,
      'Able to add Text';
    ok 1 == $capturedText.comb(/"# This is some added Text"/),
      'Only added text once';
    $test-Uggedit.ignoreEditLine = False;
    $test-Uggedit.addText = False;
    $capturedText = $test-Uggedit.edit;
    ok $capturedText.index('Look: "This text won\'t be added the first time"').defined,
      'Able to run perl 6 code';
}

done;
```
Here is an example based off a test that does the following:

1. Starts to initialize an Editsrc::Uggedit::Editor object (*Editsrc::Uggedit::Editor.new(*...*)*)
2. Tells the object the field to look for (*editLineName => 'src_k'*) and file name (*editFile => 'basic'*) 
3. Tells the object to ignore what execution instructions the file contains (*ignoreEditLine => True*)
4. Tells the object to add text along with other properties relating to adding text (*addText => True, addTextOnce => True, textToAdd => "# This is some added Text\n"*)
5. Tells the object to return text in fields (the text returned is after modification) (*captureField => True*)
6. After initialization finishes the *edit* method is called on the object which causes it to begin editing returning the captured fields
7. The test checks to see if the object has added the text to the file it has said to add. The captured fields contain the text so in order to check if it has added the text to the file it only needs to check the returned captured fields
8. The test next checks that the text has only been added once
9. Values are reassigned so that execution instructions are not ignored making allowing embedded code to be executed
10. The test then checks to see if the text has been inserted into the fields meaning the code can be executed

As you can see, **there is more than one way to do it** (modify text).

### Everything about it
#### To do

### Goals
* Make Uggedit use a perl 6 grammer
* Seperate quoting subroutines into their own package
* Support more lanugaes
* More explaination in the Readme
* Far more tests
