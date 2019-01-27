use v6;

use PDF::Field;

role PDF::Field::Signature
    does PDF::Field {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::TextString;
    use PDF::Signature;

    # See [PDF 32000 Table 252 - Additional entries specific to a signature field]
    ## use ISO_32000::Signature_field;
    ## also does ISO_32000::Signature_field;
    has PDF::Signature $.V is entry(:alias<value>);

    my role LockDict
	does PDF::COS::Tie::Hash {
	# See [PDF 32000 Table 233 - Entries in a signature field lock dictionary]
        ## use ISO_32000::Signature_field_lock;
        ## also does ISO_32000::Signature_field_lock;
 	has PDF::COS::Name $.Type is entry where 'SigFieldLock';     # (Optional) The type of PDF object that this dictionary describes; if present, must be SigFieldLock for a signature field lock dictionary
	my subset ActionName of PDF::COS::Name where 'All'|'Include'|'Exclude';
	has ActionName $.Actions is entry(:required);   # (Required) A name which, in conjunction with Fields, indicates the set of fields that should be locked
	has PDF::COS::TextString @.Fields is entry;                  # (Required if the value of Action is Include or Exclude) An array of text strings containing field names.
    }

    has LockDict $.Lock is entry(:indirect);   # (Optional; must be an indirect reference; PDF 1.5) A signature field lock dictionary that specifies a set of form fields to be locked when this signature field is signed. Table 8.82lists the entries in this dictionary.

    my role SeedValueDict
	does PDF::COS::Tie::Hash {
	# See [PDF 32000 Table 234 - Entries in a signature field seed value dictionary]
        ## use ISO_32000::Signature_field_seed_value;
        ## also does ISO_32000::Signature_field_seed_value;
	has PDF::COS::Name $.Type is entry where 'SV';                 # (Optional) The type of PDF object that this dictionary describes; if present, must be SV for a seed value dictionary.
	has PDF::COS::Name $.Filter is entry;         # (Optional) The signature handler to be used to sign the signature field. Beginning with PDF 1.7, if Filter is specified and the Ff entry indicates this entry is a required constraint, then the signature handler specified by this entry must be used when signing; otherwise, signing must not take place. If Ff indicates that this is an optional constraint, this handler should be used if it is available. If it is not available, a different handler can be used instead.
	has PDF::COS::Name @.SubFilter is entry;      # first name in the array that matches an encoding supported by the signature handler should be the encoding that is actually used for signing. If SubFilter is specified and the Ff entry indicates that this entry is a required constraint, then the first matching encodings must be used when signing; otherwise, signing must not take place. If Ff indicates that this is an optional constraint, then the first matching encoding should be used if it is available. If it is not available, a different encoding can be used.
        my subset DigestMethodName of PDF::COS::Name where 'SHA1'|'SHA256'|'SHA384'|'SHA512'|'RIPEMD160';
	has DigestMethodName @.DigestMethod is entry(:array-or-item); # (Optional; PDF 1.7) An array of names indicating acceptable digest algorithms to use while signing. The valid values are SHA1, SHA256, SHA384, SHA512 and RIPEMD160. The default value is implementation-specific.
	# Note: This property is only applicable if the digital credential signing contains RSA public/private keys. If it contains DSA public/ private key, the digest algorithm is always SHA1 and this attribute is ignored.

	has Numeric $.V is entry(:alias<value>);       # (Optional) The minimum required capability of the signature field seed value dictionary parser. A value of 1 specifies that the parser must be able to recognize all seed value dictionary entries specified in PDF 1.5. A value of 2 specifies that it must be able to recognize all seed value dictionary entries specified in PDF 1.7 and earlier.
	    # The Ff entry indicates whether this is a required constraint.
	    # Note: The PDF Reference fifth edition (PDF 1.6) and earlier, erroneously indicates that the V entry is of type integer. This entry is of type real

        my role CertificateSeedValueDict
	    does PDF::COS::Tie::Hash {
            # See [PDF 32000 Table 235 - Entries in a certificate seed value dictionary]
            ## use ISO_32000::Certificate_seed_value;
            ## also does ISO_32000::Certificate_seed_value;
            has PDF::COS::Name $.Type is entry where 'SVCert';	# (Optional) The type of PDF object that this dictionary describes; if present, shall be SVCert for a certificate seed value dictionary.
            has UInt $.Ff is entry;	# [integer] (Optional) A set of bit flags specifying the interpretation of specific entries in this dictionary. A value of 1 for the flag means that a signer shall be required to use only the specified values for the entry. A value of 0 means that other values are permissible. Bit positions are 1 (Subject); 2 (Issuer); 3 (OID); 4 (SubjectDN); 5 (Reserved); 6 (KeyUsage); 7 (URL).
                # Default value: 0.
            has Str @.Subject is entry;	# [array] (Optional) An array of byte strings containing DER-encoded X.509v3 certificates that are acceptable for signing. X.509v3 certificates are described in RFC 3280, Internet X.509 Public Key Infrastructure, Certificate and Certificate Revocation List (CRL) Profile (see the Link Bibliography ). The value of the corresponding flag in the Ff entry indicates whether this is a required constraint.
            has Str @.SubjectDN is entry;	# [array of dictionaries] (Optional; PDF 1.7) An array of dictionaries, each specifying a Subject Distinguished Name (DN) that shall be present within the certificate for it to be acceptable for signing. The certificate ultimately used for the digital signature shall contain all the attributes specified in each of the dictionaries in this array. (PDF keys and values are mapped to certificate attributes and values.) The certificate is not constrained to use only attribute entries from these dictionaries but may contain additional attributes.The Subject Distinguished Name is described in RFC 3280 (see the Link Bibliography ). The key can be any legal attribute identifier (OID). Attribute names shall contain characters in the set a-z A-Z 0-9 and PERIOD.
                # Certificate attribute names are used as key names in the dictionaries in this array. Values of the attributes are used as values of the keys. Values shall be text strings.
                # The value of the corresponding flag in the Ff entry indicates whether this entry is a required constraint.
            has Str @.KeyUsage is entry;	# [array of ASCII strings] (Optional; PDF 1.7) An array of ASCII strings, where each string specifies an acceptable key-usage extension that shall be present in the signing certificate. Multiple strings specify a range of acceptable key-usage extensions. The key-usage extension is described in RFC 3280.
                # Each character in a string represents a key-usage type, where the order of the characters indicates the key-usage extension it represents. The first through ninth characters in the string, from left to right, represent the required value for the following key-usage extensions:
                # 1 digitalSignature 4 dataEncipherment 7 cRLSign
                # 2 non-Repudiation 5 keyAgreement 8 encipherOnly
                # 3 keyEncipherment 6 keyCertSign 9 decipherOnly
                # Any additional characters shall be ignored. Any missing characters or characters that are not one of the following values, shall be treated as ‘X’. The following character values shall be supported:
                # 0 Corresponding key-usage shall not be set.
                # 1 Corresponding key-usage shall be set.
                # X State of the corresponding key-usage does not matter.
                # EXAMPLE 1 The string values ‘1’ and ‘1XXXXXXXX’ represent settings where the key-usage type digitalSignature is set and the state of all other key-usage types do not matter. The value of the corresponding flag in the Ff entry indicates whether this is a required constraint.
            has Str @.Issuer is entry;	# [array] (Optional) An array of byte strings containing DER-encoded X.509v3 certificates of acceptable issuers. If the signer’s certificate refers to any of the specified issuers (either directly or indirectly), the certificate shall be considered acceptable for signing. The value of the corresponding flag in the Ff entry indicates whether this is a required constraint.
                # This array may contain self-signed certificates.
            has Str @.OID is entry;	# [array] (Optional) An array of byte strings that contain Object Identifiers (OIDs) of the certificate policies that shall be present in the signing certificate.
                # EXAMPLE 2 An example of such a string is: (2.16.840.1.113733.1.7.1.1). This field shall only be used if the value of Issuer is not empty. The certificate policies extension is described in RFC 3280 (see the Link Span ). The value of the corresponding flag in the Ff entry indicates whether this is a required constraint.
            has Str $.URL is entry;	# [ASCII string] (Optional) A URL, the use for which shall be defined by the URLTypeentry.
            has PDF::COS::Name $.URLType is entry where 'Browser'|'Third';	# [Name] (Optional; PDF 1.7) A name indicating the usage of the URL entry. There are standard uses and there can be implementation-specific uses for this URL. The following value specifies a valid standard usage:
                # Browser – The URL references content that shall be displayed in a web browser to allow enrolling for a new credential if a matching credential is not found. The Ff attribute’s URL bit shall be ignored for this usage.
                # Third parties may extend the use of this attribute with their own attribute values, which shall conform to the guidelines described in Link Annex E .
                # The default value is Browser.
        }
	has CertificateSeedValueDict $.Cert is entry;                     # (Optional) A certificate seed value dictionary containing information about the certificate to be used when signing.

        has PDF::COS::TextString @.Reasons is entry;                   # (Optional) An array of text strings that specifying possible reasons for signing a document. If specified, the reasons supplied in this entry replace those used by viewer applications. The Ff entry specifies whether one of the reasons in the array must be used in the signature.
	    # •If the Reasons array is provided and the Ff entry indicates that Reasons is a required constraint, one of the reasons in the array must be used for the signature dictionary; otherwise, signing must not take place. If the Ff entry indicates Reasons is an optional constraint, one of the reasons in the array can be chosen or a custom reason can be provided.
	    # •If the Reasons array is omitted or contains a single 0-character length string and the Ff entry indicates that Reasons is a required constraint, the Reasonentry must be omitted from the signature dictionary

	has UInt %.MDP is entry;                     # (Optional; PDF 1.6) A dictionary containing a single entry whose key is P and whose value is an integer between 0 and 3. A value of 0 defines the signature as an ordinary (non-author) signature (see Section 8.7, “Digital Signatures”). The values 1 through 3 are used for author signatures and correspond to the value of P in a DocMDP transform parameters dictionary (see Table 8.104).
	    # If this entry is not present or does not contain a P entry, no rules are defined regarding the type of signature or its permissions.

        my role TimeStampUrl
        does PDF::COS::Tie::Hash {
            has Str $.URL is entry;
            has Int $.Ff is entry(:default(0)) where 0|1;
        }
	has TimeStampUrl $.TimeStamp is entry;       # (Optional; PDF 1.6) A time stamp dictionary containing two entries:
	    # URL: An ASCII string specifying the URL of a time-stamping server, providing a time stamp that is compliant with RFC 3161, Internet X.509 Public Key Infrastructure Time-Stamp Protocol (see the Bibliography).
            # Ff: An integer whose value is 1 (the signature is required to have a time stamp) or 0 (the signature is not required to have a time stamp). Default value: 0.

	has Bool $.AddRevInfo is entry;              # (Optional; PDF 1.7) A flag indicating whether revocation checking should be carried out. If AddRevInfo is true, the viewer application performs the following additional tasks when signing the signature field:
	    # •Perform revocation checking of the certificate (and the corresponding issuing certificates) used to sign.
	    # •Include the revocation information within the signature value.
	    # A value of true is relevant only if SubFilter is adbe.pkcs7.detached or adbe.pkcs7.sha1. If SubFilter is x509.rsa_sha1, this entry must be omitted or set to false; otherwise, the signature process may fail.
	    # If AddRevInfo is true and the Ff entry indicates this is a required constraint, then the tasks described above must be performed. If they cannot be performed, then signing must fail.

	has UInt $.Ff is entry(:alias<flags>);                      # (Optional) A set of bit flags specifying the interpretation of specific entries in this dictionary. A value of 1 for the flag indicates that the associated entry is a required constraint. A value of 0 indicates that the associated entry is an optional constraint. Bit positions are 1 (Filter); 2 (SubFilter); 3 (V); 4 (Reasons); 5 (LegalAttestation); 6(AddRevInfo); and 7(DigestMethod)

    }

    has SeedValueDict $.SV is entry(:indirect, :alias<seed-value>);           # (Optional; must be an indirect reference; PDF 1.5) A seed value dictionary (see Table 8.83) containing information that constrains the properties of a signature that is applied to this field.
    method DV is rw {$.SV}
}
