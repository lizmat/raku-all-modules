#! env perl
#
# Copyright (c) 2012, Martin Schuette <info@mschuette.name>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use PDF::API6;
use PDF::DAO;
use OpenSSL;
use Digest::SHA1::Native;

my $add_mdp = 0;            # not tested; add DocMDP-signature attributes
my $input_filename = "test.pdf";
my $tempfilename   = '/tmp/tmp.pdf';
my $outfilename    = '/tmp/test.pdf';

# 'pkcs7' is the preferred way, inserts a detached PKCS#7 signature
# the (untested) alternative is 'rsa' which adds a PKCS#1 of SHA-1
my $sig_algorithm = 'pkcs7';
my $sig_length    = 20480;

# certificates:
my $cacert_filename   = "ca-crt.pem";
my $x509_filename     = "server-crt.pem";
my $priv_key_filename = "server-key.pem";
my $ssl = OpenSSL.new;
my $cacert   = $ssl.use-certificate-file($cacert_filename);
my $x509     = $ssl.use-certificate-file($x509_filename);
my $priv_key = $ssl.use-privatekey-file($priv_key_filename);

warn :$x509.perl;
warn $x509.email;

# prepare different values for the signature meta-data
sub pdf_timestamp {
    return now;
}

sub pdf_location {
  chomp qx{hostname};
}
##
##sub pdf_contactinfo {
##  return PDFStr($x509->email());
##}
##
##sub pdf_signername {
##  return PDFStr($x509->subject_name->as_string);
##}
##
### Basic structure: we have to insert 4 dictionaries into the PDF:
### 
### 1. an AcroForm dictionary, which has an Array of Form elements.
###    Here only one reference to our Field dictionary.
### 2. the Field dictionary (with /FT/Sig)
### 3. the Signature dictionary (with /Type/Sig) containing the
###    "signature itself" in its /Contents
### 4. the Annotation dictionary (with /Type/Annot /Subtype/Widget)
###    to link the signature to a page and possibly to a graphic
##
##my $pdf = PDF::API2->open($input_filename);
##my $p = $pdf->{catalog}->{' parent'};
##
### create Signature dictionary (with /Type/Sig)
##my $sigdict = PDF::API2::Basic::PDF::Dict->new();
##$sigdict->{Type}      = PDFName("Sig");
##$sigdict->{Filter}    = PDFName("Adobe.PPKLite");
##$sigdict->{Reason}    = PDFStr("Testing my PDF Signature Demo Tool");
##$sigdict->{Name}      = pdf_signername();
##$sigdict->{ContactInfo} = pdf_contactinfo();
##$sigdict->{Location}  = pdf_location();
##$sigdict->{M}         = pdf_timestamp();
### algorithm/encoding dependent fields and values:
##if ($sig_algorithm eq 'rsa') {
##  $sigdict->{SubFilter} = PDFName('adbe.x509.rsa.sha1');
##  my @certs;
##  push @certs, PDFStr $x509->as_string(FORMAT_ASN1);
##  push @certs, PDFStr $cacert->as_string(FORMAT_ASN1);
##  # only for PCKS#1:
##  $sigdict->{Cert}      = PDFArray @certs if ($sig_algorithm eq 'rsa');
##} else {
##  $sigdict->{SubFilter} = PDFName('adbe.pkcs7.detached');
##}
### placeholder:
##$sigdict->{Contents}  = PDFStrHex("\0" x $sig_length);
##$sigdict->{ByteRange} = PDF::API2::Basic::PDF::Literal->new("[0 00000000 00000000 00000000]");
##
##if ($add_mdp) {
##	# for DocMDP signatures we insert a secondary dict with more info
##	my $sigrefdict = PDF::API2::Basic::PDF::Dict->new();
##	$sigrefdict->{Type}   = PDFName("SigRef");
##	$sigrefdict->{TransformMethod} = PDFName("DocMDP");
##	$sigrefdict = $p->new_obj($sigrefdict);
##	$sigdict->{Reference} = PDFArray($sigrefdict);
##}
### finalize object:
##$sigdict     = $p->new_obj($sigdict);
##
### the Field dictionary gets an Annotation Widget as a child element
##my $sigannotdict = PDF::API2::Basic::PDF::Dict->new();
##
### Field dictionary (with /FT/Sig)
##my $sigformdict = PDF::API2::Basic::PDF::Dict->new();
##$sigformdict->{FT}      = PDFName("Sig");
##$sigformdict->{T}       = PDFStr("Demo Signature");
##$sigformdict->{V}       = $sigdict;
##$sigformdict->{Kids}    = PDFArray($sigannotdict);
##$sigformdict = $p->new_obj($sigformdict);
##
### Annotation Widget, contd.
##$sigannotdict->{Type}    = PDFName("Annot");
##$sigannotdict->{Subtype} = PDFName("Widget");
##$sigannotdict->{F}       = PDFNum(4);
##$sigannotdict->{Parent}  = $sigformdict;
##$sigannotdict->{Rect}    = PDF::API2::Basic::PDF::Literal->new("[0 0 0 0]");
##$sigannotdict->{P}       = $pdf->openpage(1);
##$sigannotdict->{H}       = PDFName("N");
##$sigannotdict = $p->new_obj($sigannotdict);
##
##
##
##if ($add_mdp) {
##	my $permdict = PDF::API2::Basic::PDF::Dict->new();
##	$permdict->{DocMDP}   = $sigdict;
##	$permdict = $p->new_obj($permdict);
##	$pdf->{catalog}->{'Perm'} = $permdict;
##}
##
### create AcroForm dictionary
### TODO: if one is present, then only append to it
##my @formarray;
##push @formarray, $sigformdict;
##my $acroformdict = PDF::API2::Basic::PDF::Dict->new();
##$acroformdict->{Fields}   = PDFArray @formarray;
##$acroformdict->{SigFlags} = PDFNum(3);
##$acroformdict = $p->new_obj($acroformdict);
##
##$pdf->{catalog}->{'AcroForm'} = $acroformdict;
##$pdf->{pdf}->out_obj($pdf->{catalog});
##
### so now we have the temporary document with zeroes
##$pdf->saveas($tempfilename);
##say "added AcroForm: $input_filename --> $tempfilename";
##
##sub make_signature {
##  my $tempfilename = shift;
##  my $outfilename = shift;
##
##  # calc ByteRange
##  my $data = read_file($tempfilename, { binmode => ':raw' });
##  my $sig_start = rindex($data, '/Contents <000000000000000000000');
##  $sig_start += length '/Contents ';
##  my $sig_end = index($data, '0000>', $sig_start);
##  $sig_end += length '0000>';
##  my $sig_trail = length($data) - $sig_end;
##  my $range = sprintf("/ByteRange [0 %8d %8d %8d]", $sig_start, $sig_end, $sig_trail);
##  $data =~ s/\/ByteRange \[0 00000000 00000000 00000000\]/$range/;
##  say "calc'd $range";
##  if ($sig_end - $sig_start != 2+2*$sig_length) {
##	say "Hey, that ByteRange is wrong!";
##  }
##  
##  # prepare content for digest
##  my $plaintext = substr($data, 0, $sig_start) . substr($data, $sig_end, $sig_trail);
##  my $plaintextfilename = '/tmp/plaintext.pdf';
##  write_file($plaintextfilename, {binmode => ':raw'}, $plaintext);
##  say "debug-output, signature input in $plaintextfilename";
## 
##  if ($sig_algorithm eq 'rsa') {
##	# calc SHA1
##	say "SHA-1 is " . sha1_hex($plaintext);
##	my $digest = sha1($plaintext);
##
##	# calc Sig
##	my $rsa_priv = Crypt::OpenSSL::RSA->new_private_key($priv_key);
##	$rsa_priv->use_sha1_hash();
##	$rsa_priv->use_pkcs1_padding();
##	my $signature = $rsa_priv->sign($digest);
##
##	my $rsa_verify = Crypt::OpenSSL::RSA->new_public_key($x509->pubkey());
##	say "calc'd Signature";
##	if (!$rsa_verify->verify($digest, $signature)) {
##		say "Hey, that Signature is wrong!";
##	};
##	write_file('/tmp/signature.p1', {binmode => ':raw'}, $signature);
##	say "debug-output, signature in /tmp/signature.p1";
##  
##	my $sig_enc = PDFStrHex($signature)->as_pdf;
##	chop $sig_enc;    # remove closing '>'
##	substr($data, $sig_start, length($sig_enc), $sig_enc);
##	write_file($outfilename, {binmode => ':raw'}, $data);
##	say "added Signature: $tempfilename --> $outfilename";
##  } else {
##	
##	# this is ugly, but there is no Perl interface to openssl's pkcs#7 function:
##	use MIME::Base64;
##	my $signature = `cat $plaintextfilename | openssl smime -binary -sign -certfile $cacert_filename -signer $x509_filename -inkey $priv_key_filename | sed -e '1,/^Content-Disposition:/d;/^-----/d;/^\$/d'`;
##    $signature = decode_base64($signature);
##	write_file('/tmp/signature.p1', {binmode => ':raw'}, $signature);
##	say "debug-output, signature in /tmp/signature.p1";
##  
##	my $sig_enc = PDFStrHex($signature)->as_pdf;
##	chop $sig_enc;    # remove closing '>'
##	#$sig_enc = substr($sig_enc, 1);
##	substr($data, $sig_start, length($sig_enc), $sig_enc);
##	write_file($outfilename, {binmode => ':raw'}, $data);
##	say "added Signature: $tempfilename --> $outfilename";
##
##  }
##}
##
##make_signature($tempfilename, $outfilename);
##
##
