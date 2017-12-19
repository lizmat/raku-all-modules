use v6;

use PDF::Field;

role PDF::Field::Signature
    does PDF::Field {

    use PDF::DAO;
    use PDF::DAO::Tie;

    my role LockDict
	does PDF::DAO::Tie::Hash {
	    # See [PDF 1.7 TABLE 8.82 Entries in a signature field lock dictionary]
	    my subset TypeName of PDF::DAO::Name where 'SigFieldLock';
	    has TypeName $.Type is entry;                   #| (Optional) The type of PDF object that this dictionary describes; if present, must be SigFieldLock for a signature field lock dictionary
	    my subset ActionName of PDF::DAO::Name where 'All' | 'Include' | 'Exclude';
	    has ActionName $.Actions is entry(:required);   #| (Required) A name which, in conjunction with Fields, indicates the set of fields that should be locked
	    has Str @.Fields is entry;                      #| (Required if the value of Action is Include or Exclude) An array of text strings containing field names.
    }

    # [PDF 1.7 TABLE 8.81 Additional entries specific to a signature field]
    has LockDict $.Lock is entry;   #| (Optional; must be an indirect reference; PDF 1.5) A signature field lock dictionary that specifies a set of form fields to be locked when this signature field is signed. Table 8.82lists the entries in this dictionary.
##
    my role SeedValueDict
	does PDF::DAO::Tie::Hash {
##	    # See [PDF 1.7 TABLE 8.83 Entries in a signature field seed value dictionary]
	    my subset TypeName of PDF::DAO::Name where {$_ eq 'SV'};
	    has TypeName $.Type is entry;                 #| (Optional) The type of PDF object that this dictionary describes; if present, must be SV for a seed value dictionary.
	    has PDF::DAO::Name $.Filter is entry;         #| (Optional) The signature handler to be used to sign the signature field. Beginning with PDF 1.7, if Filter is specified and the Ff entry indicates this entry is a required constraint, then the signature handler specified by this entry must be used when signing; otherwise, signing must not take place. If Ff indicates that this is an optional constraint, this handler should be used if it is available. If it is not available, a different handler can be used instead.
	    has PDF::DAO::Name @.SubFilter is entry;      #| first name in the array that matches an encoding supported by the signature handler should be the encoding that is actually used for signing. If SubFilter is specified and the Ff entry indicates that this entry is a required constraint, then the first matching encodings must be used when signing; otherwise, signing must not take place. If Ff indicates that this is an optional constraint, then the first matching encoding should be used if it is available. If it is not available, a different encoding can be used.
            my subset DigestMethodName of PDF::DAO::Name where {$_ eq 'SHA1' | 'SHA256' | 'SHA384' | 'SHA512' | 'RIPEMD160'};
	    has  DigestMethodName $.DigestMethod is entry; #| (Optional; PDF 1.7) An array of names indicating acceptable digest algorithms to use while signing. The valid values are SHA1, SHA256, SHA384, SHA512 and RIPEMD160. The default value is implementation-specific.
	    #| Note: This property is only applicable if the digital credential signing contains RSA public/private keys. If it contains DSA public/ private key, the digest algorithm is always SHA1 and this attribute is ignored.

	    has  Numeric $.V is entry;                     #| (Optional) The minimum required capability of the signature field seed value dictionary parser. A value of 1 specifies that the parser must be able to recognize all seed value dictionary entries specified in PDF 1.5. A value of 2 specifies that it must be able to recognize all seed value dictionary entries specified in PDF 1.7 and earlier.
	    #| The Ff entry indicates whether this is a required constraint.
	    #| Note: The PDF Reference fifth edition (PDF 1.6) and earlier, erroneously indicates that the V entry is of type integer. This entry is of type real

	    has  Hash $.Cert is entry;                     #| (Optional) A certificate seed value dictionary (see Table 8.84) containing information about the certificate to be used when signing.

            has  Str @.Reasons is entry;                   #| (Optional) An array of text strings that specifying possible reasons for signing a document. If specified, the reasons supplied in this entry replace those used by viewer applications. The Ff entry specifies whether one of the reasons in the array must be used in the signature.
	    #| •If the Reasons array is provided and the Ff entry indicates that Reasons is a required constraint, one of the reasons in the array must be used for the signature dictionary; otherwise, signing must not take place. If the Ff entry indicates Reasons is an optional constraint, one of the reasons in the array can be chosen or a custom reason can be provided.
	    #| •If the Reasons array is omitted or contains a single 0-character length string and the Ff entry indicates that Reasons is a required constraint, the Reasonentry must be omitted from the signature dictionary

	    has  UInt %.MDP is entry;                     #| (Optional; PDF 1.6) A dictionary containing a single entry whose key is P and whose value is an integer between 0 and 3. A value of 0 defines the signature as an ordinary (non-author) signature (see Section 8.7, “Digital Signatures”). The values 1 through 3 are used for author signatures and correspond to the value of P in a DocMDP transform parameters dictionary (see Table 8.104).
	    #| If this entry is not present or does not contain a P entry, no rules are defined regarding the type of signature or its permissions.

	    has  Hash $.TimeStamp is entry;               #| (Optional; PDF 1.6) A time stamp dictionary containing two entries:
	    #| URL: An ASCII string specifying the URL of a time-stamping server, providing a time stamp that is compliant with RFC 3161, Internet X.509 Public Key Infrastructure Time-Stamp Protocol (see the Bibliography).
            #| Ff: An integer whose value is 1 (the signature is required to have a time stamp) or 0 (the signature is not required to have a time stamp). Default value: 0.

	    has  Bool $.AddRevInfo is entry;              #| (Optional; PDF 1.7) A flag indicating whether revocation checking should be carried out. If AddRevInfo is true, the viewer application performs the following additional tasks when signing the signature field:
	    #| •Perform revocation checking of the certificate (and the corresponding issuing certificates) used to sign.
	    #| •Include the revocation information within the signature value.
	    #| A value of true is relevant only if SubFilter is adbe.pkcs7.detached or adbe.pkcs7.sha1. If SubFilter is x509.rsa_sha1, this entry must be omitted or set to false; otherwise, the signature process may fail.
	    #| If AddRevInfo is true and the Ff entry indicates this is a required constraint, then the tasks described above must be performed. If they cannot be performed, then signing must fail.

	    has  UInt $.Ff is entry;                      #| this dictionary. A value of 1 for the flag indicates that the associated entry is a required constraint. A value of 0 indicates that the associated entry is an optional constraint. Bit positions are 1 (Filter); 2 (SubFilter); 3 (V); 4 (Reasons); 5 (LegalAttestation); 6(AddRevInfo); and 7(DigestMethod)

    }

    has SeedValueDict $.SV is entry;     #| (Optional; must be an indirect reference; PDF 1.5) A seed value dictionary (see Table 8.83) containing information that constrains the properties of a signature that is applied to this field.
}
