use v6;

use JSON::Fast;
use String::CRC32;
use Test;
use Amazon::DynamoDB;

use lib 't/lib';
use Test::Amazon::DynamoDB;

my $rid = 1;
my @reqs;
my @ress;
my $ddb = new-dynamodb-actions(
    scheme   => 'https',
    hostname => 'testing',
    port     => 1234,
    ua       => class :: does Amazon::DynamoDB::UA {
        method request(:$method, :$uri, :%headers, :$content --> Promise) {
            start {
                push @reqs, %(
                    :$method,
                    :$uri,
                    :%headers,
                    :$content,
                );

                my $text = start { to-json(@ress.pop, :sorted-keys) };
                my $blob = $text.then({ .result.encode('UTF-8') });

                %(
                    Status => 200,
                    Header => %(
                        x-amzn-requestid => $rid++,
                        x-amz-crc32     => String::CRC32::crc32(await $blob),
                    ),
                    RawContent => $blob,
                    DecodedContent => $text,
                );
            }
        }
    }.new,
);

my @methods = <
    BatchGetItem BatchWriteItem CreateTable DeleteItem
    DeleteTable DescribeLimits DescribeTable GetItem
    ListTables PutItem Query Scan
    UpdateItem UpdateTable
>;

for @methods -> $method {
    my %req-data = test-data("AWS-{$method}-Request");
    my %res-data = test-data("AWS-{$method}-Response");
    @ress.push: %res-data;

    my $res = await $ddb."$method"(|%req-data);

    is @reqs.elems, 1;

    my $req = @reqs.pop;

    # not testing WebService::AWS::Auth::V4
    $req<headers><Authorization>:delete;
    $req<headers><X-Amz-Date>:delete;

    is-deeply $req, %(
        method => 'POST',
        uri    => 'https://testing:1234/',
        headers => %(
            Content-Type => 'application/x-amz-json-1.0',
            Host => 'testing',
            X-Amz-Target => "DynamoDB_20120810.$method",
        ),
        content => to-json(%req-data, :sorted-keys),
    ), "$method request";

    is $res<RequestId>:delete, $rid-1, "$method response RequestId";
    is-deeply $res, %res-data, "$method response";
}

done-testing;
