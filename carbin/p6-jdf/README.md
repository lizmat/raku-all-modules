# Printing::Jdf #

This is a module for parsing Adobe Job Definition Format files that use Kodak's
SSi extensions.

## Example ##

    my $xml = slurp('/path/to/file.jdf');
    my $jdf = Printing::Jdf.new($xml);

See the [imposition.pl6](imposition.pl6) script for an example of using
this module to list the templates, adjustments and page details from a
JDF file.

## Documentation ##

### Printing::Jdf ###

#### .Auditpool ####

Returns a Printing::Jdf::AuditPool object for the provided JDF file

#### .ResourcePool ####

Returns a Printing::Jdf::ResourcePool object for the provided JDF file

#### ::mm (Str, Int, Rat) --> Int ####

Converts Pts to Millimetres, rounded to the closest millimetre

### Printing::Jdf::AuditPool ###

#### .Created ####

Returns a Hash with the following keys:

    <Str>   AgentName => the name of the generator used to create the JDF file
    <Str>   AgentVersion => the version of the generator
    <DateTime> TimeStamp => object representing the date the file was created

### Printing::Jdf::ResourcePool ###

#### .ColorantOrder ####

Returns a List of Strings of the names of the colours in the document

#### .Layout ####

Returns a Hash with the following keys:

    <Int> Bleed => the amount of bleed used in the document, in millimetres
    PageAdjustments => a Hash representing the page offsets
        Odd => odd page offsets
            <Int> X => horizontal offset
            <Int> Y => vertical offset
        Even => even page offsets
            <Int> X => horizontal offset
            <Int> Y => vertical offset
    Signatures => an array of the Signatures in the document
        Each Signature is a Hash containing the following keys:
            <Str> Name => the name of the signature
            <Int> PressRun => the number of the press run
            <IO::Path> Template => an IO::Path object of the template file

#### .Runlist ####

Returns an Array of Hashes representing each page in the runlist

    <Int> Run => the run number of the page
    <Int> Page => the page number
    <IO::Path> Url => a IO::Path object for the file
    <Bool> Centered => a Bool that is True if the page is centered
    Offsets => a Hash of the page offsets in millimetres
        see Layout<PageAdjustments>
    Scaling => a Hash with the keys <X> and <Y> representing the scaling percentage of the page

## License ##

This module is licensed under the terms of the ISC License.

Adobe, Kodak, Preps and Creo are trademarks of their respective owners.
