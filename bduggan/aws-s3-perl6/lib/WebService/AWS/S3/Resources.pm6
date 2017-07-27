# WebService::AWS::S3::Resources
use XML::Class;

class S3::Owner does XML::Class[xml-element => "Owner"] {
    has Str $.id is xml-element('ID');
    has Str $.display-name is xml-element("DisplayName");
}

class S3::Bucket does XML::Class[xml-element => "Bucket"] {
    has Str $.name is xml-element("Name");
    has DateTime $.creation-date is xml-element("CreationDate");
}

class S3::BucketList does XML::Class[xml-element => "Buckets"]
    does Iterable
 {
    has S3::Bucket @.buckets handles <<AT-POS elems>>;
    method iterator() {
      return @.buckets.iterator;
    }
    method AT-KEY($k) {
      return @.buckets.first: *.name eq $k;
    }
    method EXISTS-KEY($k) {
      return so @.buckets.first: *.name eq $k;
   }
}

class S3::BucketListResult does XML::Class[
    xml-element => "ListAllMyBucketsResult",
    xml-namespace => "http://s3.amazonaws.com/doc/2006-03-01/"
    ] {
    also does Iterable;
    has S3::Owner $.owner;
    has S3::BucketList $.buckets handles <<AT-POS AT-KEY EXISTS-KEY elems>>;
    method iterator {
        return $.buckets.iterator;
    }
}

class S3::Object does XML::Class[
    xml-element => 'Contents'
] {
  has S3::Owner $.owner;
  has S3::Bucket $.bucket is rw;
  has Str $.key is xml-element('Key'),
  has DateTime $.last-modified is xml-element('LastModified');
  has Str $.etag is xml-element('ETag');
  has Int $.size is xml-element('Size');
  has Str $.storage-class is xml-element('StorageClass');
  method url {
    return 's3://' ~ self.bucket.name ~ '/' ~ self.key;
  }
}

class S3::Prefix does XML::Class[
    xml-element => "CommonPrefixes"
] {
  has @.prefix is xml-element('Prefix');
}

class S3::ObjectList does XML::Class[
    xml-element => 'ListBucketResult'
] {
  also does Iterable;
  has $.name is xml-element('Name');
  has $.prefix is xml-element('Prefix');
  has $.marker is xml-element('Marker');
  has $.max-keys is xml-element('MaxKeys');
  has $.delimiter is xml-element('Delimiter');
  has Bool $.is-truncated is xml-element('IsTrunctated');
  has S3::Object @.objects handles <AT-POS EXISTS-POS elems>;
  has S3::Prefix @.common-prefixes;
  method AT-KEY($k) {
    return @.objects.first: *.key eq $k;
  }
  method iterator { @.objects.iterator }
}

class S3::Error does XML::Class[
    xml-element => 'Error'
] {
    has $.code is xml-element('Code');
    has $.message is xml-element('Message');
    has $.aws-access-key-id is xml-element('AWSAccessKeyId');
    has $.string-to-sign is xml-element('StringToSign');
    has $.signature-provided is xml-element('SignatureProvided');
    has $.canonical-request is xml-element('CanonicalRequest');
    has $.canonical-request-bytes is xml-element('CanonicalRequestBytes');
    has $.request-id is xml-element('RequestId');
    has $.host-id is xml-element('HostId');
}
