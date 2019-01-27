use v6;
unit class Amazon::DynamoDB:ver<0.3>:auth<github:zostay>;

use AWS::Session;
use AWS::Credentials;

use Amazon::DynamoDB::UA;

=begin pod

=head1 NAME

Amazon::DynamoDB - Low-level access to the DynamoDB API

=head1 SYNOPSIS

    use Amazon::DynamoDB;

    my $ddb = Amazon::DynamoDB.new

    await $ddb.CreateTable(
        AttributeDefinitions => [
            {
                AttributeName => 'ForumName',
                AttributeType => 'S',
            },
            {
                AttributeName => 'Subject',
                AttributeType => 'S',
            },
            {
                AttributeName => 'LastPostDateTime',
                AttributeType => 'S',
            },
        ],
        TableName => 'Thread',
        KeySchema => [
            {
                AttributeName => 'ForumName',
                KeyType       => 'HASH',
            },
            {
                AttributeName => 'Subject',
                KeyType       => 'RANGE',
            },
        ],
        LocalSecondaryIndexes => [
            {
                IndexName => 'LastPostIndex',
                KeySchema => [
                    {
                        AttributeName => 'ForumName',
                        KeyType       => 'HASH',
                    },
                    {
                        AttributeName => 'LastPostDateTime',
                        KeyType       => 'RANGE',
                    }
                ],
                Projection => {
                    ProjectionType => 'KEYS_ONLY'
                },
            },
        ],
        ProvisionedThroughput => {
            ReadCapacityUnits  => 5,
            WriteCapacityUnits => 5,
        },
    );

    $ddb.PutItem(
        TableName => "Thread",
        Item => {
            LastPostDateTime => {
                S => "201303190422"
            },
            Tags => {
                SS => ["Update","Multiple Items","HelpMe"]
            },
            ForumName => {
                S => "Amazon DynamoDB"
            },
            Message => {
                S => "I want to update multiple items in a single call. What's the best way to do that?"
            },
            Subject => {
                S => "How do I update multiple items?"
            },
            LastPostedBy => {
                S => "fred@example.com"
            }
        },
        ConditionExpression => "ForumName <> :f and Subject <> :s",
        ExpressionAttributeValues => {
            ':f' => {S => "Amazon DynamoDB"},
            ':s' => {S => "How do I update multiple items?"}
        }
    );

    my $res = await $ddb.GetItem(
        TableName => "Thread",
        Key => {
            ForumName => {
                S => "Amazon DynamoDB"
            },
            Subject => {
                S => "How do I update multiple items?"
            }
        },
        ProjectionExpression => "LastPostDateTime, Message, Tags",
        ConsistentRead => True,
        ReturnConsumedCapacity => "TOTAL"
    );

    say "Message: $res<Item><Message><S>";

=head1 DESCRIPTION

This module provides an asynchronous, low-level API that interacts directly with
DynamoDB.  This is a low-level implementation that sticks as close as possible
to the API described by AWS, keeping the names of actions and parameter names
as-is (i.e., not using nice kabob-case most Perl 6 modules use, but the
PascalCase that most AWS APIs present natively). This has the benefit of
allowing you to use the AWS documentation directly.

The API is currently very primitive and may change to provide better
type-checking in the future.

=head1 DIAGNOSTICS

The following exceptions may be thrown by this module:

=head2 X::Amazon::DynamoDB::APIException

This encapsulates the errors returned from the API itself. The name of the error can be checked at the C<type> method and the message in C<message>. It has the following accessors:

=item request-id The request id returned with the error.
=item raw-type The __type returned with the error (a combination of the API version and error type).
=item type The error type pulled from the raw-type.
=item message The detailed message sent with the error.

This is the exception you will most likely want to capture. For this reason, a special helper named C<of-type> is provided to aid in easy matching.

For example, if you
want to perform a C<CreateTable> operation, but ignore any
"ResourceInUseException" indicating that the table already exists, it is
recommended that you do something like this:

    my $ddb = Amazon::DynamoDB.new;
    $ddb.CreateTable( ... );

    CATCH {
        when X::Amazon::DynamoDB::APIException.of-type('ResourceInUseException') {
            # ignore
        }
    }

=head2 X::Amazon::DynamoDB::CommunicationError

This is a generic error, generally caused by HTTP connection problems, but might
be caused by especially fatal errors in the API. The message is simply
"Communication Error", but provides two attributes for more information:

=item request This is the C<HTTP::Request> that was attempted.

=item response This is the C<HTTP::Response> that was received (which might be a fake response generated by the user agent if no response was received.

=head2 X::Amazon::DynamoDB::CRCError

Every response from DynamoDB includes a CRC32 checksum. This module verifies that checksum on every request. If the checksum given by Amazon does not match the checksum calculated, this error will be thrown.

It provides these attributes:

=item got-crc32 This is the integer CRC32 we calculated.

=item expected-crc32 This is the integer CRC32 Amazon sent.

=head1 ASYNC API

The API for this is asynchronous. Mostly, this means that the API methods return
a L<Promise> that will be kept with a L<Hash> containing the results. If you
want a purely syncrhonous API, you just need to place an C<await> before every
call to the library.

Under the hood, the implementation is currently implemented to use
L<Cro::HTTP::Client> if present. If not present, then L<HTTP::UserAgent> is used
instead, though all actions will run on separate threads from the calling
thread.

=head1 METHODS

=head2 method new

    multi method new(
        AWS::Session :$session,
        AWS::Credentials :$credentials,
        Str :$scheme = 'https',
        Str :$domain = 'amazonaws.com',
        Str :$hostname,
        Int :$port,
        HTTP::UserAgent :$ua,
    ) returns Amazon::DynamoDB

All arguments to new are optional. The C<$session> and C<$credentials> will be
constructed lazily if not given to C<new> using default settings.

By default, the C<$port> and C<$hostname> are unset. This means that no port
will be specified (just the default port for the scheme will be used) and the
C<hostname> used till be constructed from the C<$domain> and region defined in
the session.

See L<AWS::Session> and L<AWS::Credentials> for details on how to customize your
settings. However, if you are familiar with how botocore/aws-cli and other tools
configure themselves, this will be familiar.

=head2 method session

    method session() returns AWS::Session is rw

Getter/setter for the session used to configure AWS settings.

=head2 method credentials

    method credentials() returns AWS::Credentials is rw

Getter/setter for the credentails used to contact AWS.

=head2 method scheme

    method scheme() returns Str

Getter for the scheme. Defaults to "https".

=head2 method domain

    method domain() returns Str

Getter for the domain. Defaults to "amazonaws.com".

=head2 method hostname

    method hostname() returns Str

This returns the hostname that will be contacted with DynamoDB calls. It is
either set by the C<hostname> setting when calling C<new> or constructed from
the C<domain> and configured region.

=head2 method port

    method port() returns Int

This returns the port number to use when contacting DynamoDB. This returns
C<Nil> if the default port is used (i.e., 80 when C<scheme> is "http" or 443
when "https").

=head1 API METHODS

These are the methods implemented as part of the AWS API. Please see the AWS API
documentation for more detail as to what each argument does and the structure of
the return value.

=head2 method BatchGetItem

    method BatchGetItem(
             :%RequestItems!,
        Str  :$ReturnConsumedCapacity,
    ) returns Promise

The BatchGetItem operation returns the attributes of one or more items from one
or more tables. You identify requested items by primary key.

See the L<AWS BatchGetItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html>.

=head2 method BatchWriteItem

    method BatchWriteItem(
             :%RequestItems!
        Str  :$ReturnConsumedCapacity,
        Str  :$ReturnItemCollectionMetrics,
    ) returns Promise

The BatchWriteItem operation puts or deletes multiple items in one or more
tables. A single call to BatchWriteItem can write up to 16 MB of data, which can
comprise as many as 25 put or delete requests. Individual items to be written
can be as large as 400 KB.

See the L<AWS BatchWriteItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html>.

=head2 method DeleteItem

    method DeleteItem(
             :%Key!,
        Str  :$TableName!,
        Str  :$ConditionalOperator,
        Str  :$ConditionExpression,
        Str  :$Expected,
             :%ExpressionAttributeNames,
             :%ExpressionAttributeValues,
        Str  :$ReturnConsumedCapacity,
        Str  :$ReturnItemCollectionMetrics,
        Str  :$ReturnValues,
    ) returns Promise

Deletes a single item in a table by primary key. You can perform a conditional
delete operation that deletes the item if it exists, or if it has an expected
attribute value.

See the L<AWS DeleteItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html>.

=head2 method GetItem

    method GetItem(
             :%Key!,
        Str  :$TableName!,
             :@AttributesToGet,
        Bool :$ConsistentRead,
             :%ExpressionAttributeNames,
        Str  :$ProjectionExpression,
        Str  :$ReturnConsumedCapacity,
    ) returns Promise

The GetItem operation returns a set of attributes for the item with the given
primary key. If there is no matching item, GetItem does not return any data and
there will be no Item element in the response.

See the L<AWS GetItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html>.

=head2 method PutItem

    method PutItem(
             :%Item!,
        Str  :$TableName!,
        Str  :$ConditionalOperator,
        Str  :$ConditionExpression,
             :%Expected,
             :%ExressionAttributeNames,
             :%ExpressionAttributeValues,
        Str  :$ReturnConsumedCapacity,
        Str  :$ReturnItemCollectionMetrics,
        Str  :$ReturnValues,
    ) returns Promise

Creates a new item, or replaces an old item with a new item. If an item that has
the same primary key as the new item already exists in the specified table, the
new item completely replaces the existing item. You can perform a conditional
put operation (add a new item if one with the specified primary key doesn't
exist), or replace an existing item if it has certain attribute values. You can
return the item's attribute values in the same operation, using the ReturnValues
parameter.

See the L<AWS PutItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html>.

=head2 method Query

    method Query(
        Str  :$TableName!,
             :@AttributesToGet,
        Str  :$ConditionalOperator,
        Bool :$ConsistentRead,
             :%ExclusiveStartKey,
             :%ExpressionAttributeNames,
             :%ExpressionAttributeValues,
        Str  :$FilterExpression,
        Str  :$IndexName,
        Str  :$KeyConditionExpression,
             :%KeyConditions,
        Int  :$Limit,
        Str  :$ProjectionExpression,
             :%QueryFilter,
        Str  :$ReturnConsumedCapacity,
        Bool :$ScanIndexForward,
        Str  :$Select,
    ) returns Promise

The Query operation finds items based on primary key values. You can query any
table or secondary index that has a composite primary key (a partition key and a
sort key).

See the L<AWS Query API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html>.

=head2 method Scan

    method Scan(
        Str  :$TableName!,
             :@AttributesToGet,
        Str  :$ConditionalOperator,
        Bool :$ConsistentRead,
             :%ExclusiveStartKey,
             :%ExpressionAttributeNames,
             :%ExpressionAttributeValues,
        Str  :$FilterExpression,
        Str  :$IndexName,
        Int  :$Limit,
        Str  :$ProjectionExpression,
             :%QueryFilter,
        Str  :$ReturnConsumedCapacity,
             :%ScanFilter,
        Int  :$Segment,
        Str  :$Select,
        Int  :$TotalSegments,
    ) returns Promise

The Scan operation returns one or more items and item attributes by accessing
every item in a table or a secondary index. To have DynamoDB return fewer items,
you can provide a FilterExpression operation.

See the L<AWS Scan API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html>.

=head2 method UpdateItem

    method UpdateItem(
             :%Key!,
        Str  :$TableName!,
             :%AttributeUpdates,
        Str  :$ConditionalOperator,
        Str  :$ConditionExpression,
             :%Expected,
             :%ExpressionAttributeNames,
             :%ExpressionAttributeValues,
        Str  :$ReturnConsumedCapacity,
        Str  :$ReturnItemCollectionMetrics,
        Str  :$ReturnValues,
        Str  :$UpdateExpression,
    ) returns Promise

Edits an existing item's attributes, or adds a new item to the table if it does
not already exist. You can put, delete, or add attribute values. You can also
perform a conditional update on an existing item (insert a new attribute
name-value pair if it doesn't exist, or replace an existing name-value pair if
it has certain expected attribute values).

See the L<AWS UpdateItem API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html>.

=head2 method CreateTable

    method CreateTable(
             :@AttributeDefinitions!,
        Str  :$TableName!,
             :@KeySchema!,
             :%ProvisionedThroughput!,
             :@GlobalSecondaryIndexes,
             :@LocalSecondaryIndexes,
             :%SSESpecification,
             :%StreamSpecification,
    ) returns Promise

The CreateTable operation adds a new table to your account. In an AWS account,
table names must be unique within each region. That is, you can have two tables
with same name if you create the tables in different regions.

See the L<AWS CreateTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html>.

=head2 method DeleteTable

    method DeleteTable(
        Str :$TableName,
    ) returns Promise

The DeleteTable operation deletes a table and all of its items. After a
DeleteTable request, the specified table is in the DELETING state until DynamoDB
completes the deletion. If the table is in the ACTIVE state, you can delete it.
If a table is in CREATING or UPDATING states, then DynamoDB returns a
ResourceInUseException. If the specified table does not exist, DynamoDB returns
a ResourceNotFoundException. If table is already in the DELETING state, no error
is returned.

See the L<AWS DeleteTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html>.

=head2 method DescribeTable

    method DescribeTable(
        Str  :$TableName!,
    ) returns Promise

Returns information about the table, including the current status of the table,
when it was created, the primary key schema, and any indexes on the table.

See the L<AWS DescribeTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html>.

=head2 method DescribeTimeToLive

    method DescribeTimeToLive(
        Str  :$TableName!,
    ) returns Promise

Gives a description of the Time to Live (TTL) status on the specified table.

See the L<AWS DescribeTimeToLive API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTimeToLive.html>.

=head2 method ListTables

    method ListTables(
        Str  :$ExclusiveStartTableName,
        Int  :$Limit,
    ) returns Promise

Returns an array of table names associated with the current account and
endpoint. The output from ListTables is paginated, with each page returning a
maximum of 100 table names.

See the L<AWS ListTables API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html>.

=head2 method UpdateTable

    method UpdateTable(
        Str  :$TableName!,
             :@AttributeDefinitions,
             :@GlobalSecondaryIndexUpdates,
             :%ProvisionedThroughput,
             :%StreamSpecification,
    ) returns Promise

Modifies the provisioned throughput settings, global secondary indexes, or
DynamoDB Streams settings for a given table.

See the L<AWS UpdateTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html>.

=head2 method UpdateTimeToLive

    method UpdateTimeToLive(
        Str  :$TableName!,
             :%TableToLiveSpecification!,
    ) returns Promise

The UpdateTimeToLive method will enable or disable TTL for the specified table.
A successful UpdateTimeToLive call returns the current TimeToLiveSpecification;
it may take up to one hour for the change to fully process. Any additional
UpdateTimeToLive calls for the same table during this one hour duration result
in a ValidationException.

See the L<AWS UpdateTimeToLive API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html>.

=head2 method CreateGlobalTable

    method CreateGlobalTable(
        Str  :$GlobalTableName!,
             :@ReplicationGroup!,
    ) returns Promise

Creates a global table from an existing table. A global table creates a
replication relationship between two or more DynamoDB tables with the same table
name in the provided regions.

See the L<AWS CreateGlobalTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateGlobalTable.html>.

=head2 method DescribeGlobalTable

    method DescribeGlobalTable(
        Str  :$GlobalTableName!,
    ) returns Promise

Returns information about the specified global table.

See the L<AWS DescribeGlobalTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeGlobalTable.html>.

=head2 method ListGlobalTables

    method ListGlobalTables(
        Str  :$ExclusiveStartGlobalTableName,
        Int  :$Limit,
        Str  :$RegionName,
    ) returns Promise

Lists all global tables that have a replica in the specified region.

See the L<AWS ListGlobalTables API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListGlobalTables.html>.

=head2 method UpdateGlobalTable

    method UpdateGlobalTable(
        Str  :$GlobalTableName!,
             :@ReplicaUpdates!,
    ) returns Promise

Adds or removes replicas in the specified global table. The global table must
already exist to be able to use this operation. Any replica to be added must be
empty, must have the same name as the global table, must have the same key
schema, and must have DynamoDB Streams enabled and must have same provisioned
and maximum write capacity units.

See the L<AWS UpdateGlobalTable API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateGlobalTable.html>.

=head2 method ListTagsOfResource

    method ListTagsOfResource(
        Str  :$ResourceArn!,
        Str  :$NextToken,
    ) returns Promise

List all tags on an Amazon DynamoDB resource. You can call ListTagsOfResource up
to 10 times per second, per account.

See the L<AWS ListTagsOfResource API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTagsOfResource.html>.

=head2 method TagResource

    method TagResource(
        Str  :$ResourceArn!,
             :@Tags!,
    ) returns Promise

Associate a set of tags with an Amazon DynamoDB resource. You can then activate
these user-defined tags so that they appear on the Billing and Cost Management
console for cost allocation tracking. You can call TagResource up to 5 times per
second, per account.

See the L<AWS TagResource API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TagResource.html>.

=head2 method UntagResource

    method UntagResource(
        Str  :$ResourceArn!,
             :@TagKeys!,
    ) returns Promise

Removes the association of tags from an Amazon DynamoDB resource. You can call
UntagResource up to 5 times per second, per account.

See the L<AWS UntagResource API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UntagResource.html>.

=head2 method CreateBackup

    method CreateBackup(
        Str  :$BackupName!,
        Str  :$TableName!,
    ) returns Promise

Creates a backup for an existing table.

See the L<AWS CreateBackup API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateBackup.html>.

=head2 method DeleteBackup

    method DeleteBackup(
        Str  :$BackupArn!,
    ) returns Promise

Deletes an existing backup of a table.

See the L<AWS DeleteBackup API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteBackup.html>.

=head2 method DescribeBackup

    method DescribeBackup(
        Str  :$BackupArn!,
    ) returns Promise

Describes an existing backup of a table.

See the L<AWS DescribeBackup API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeBackup.html>.

=head2 method DescribeContinuousBackups

    method DescribeContinuousBackups(
        Str  :$TableName!,
    ) returns Promise

Checks the status of continuous backups and point in time recovery on the
specified table. Continuous backups are ENABLED on all tables at table creation.
If point in time recovery is enabled, PointInTimeRecoveryStatus will be set to
ENABLED.

See the L<AWS DescribeContinuousBackups API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeContinuousBackups.html>.

=head2 method ListBackups

    method ListBackups(
        Str  :$ExclusiveStartBackupArn,
        Int  :$Limit,
        Str  :$TableName,
        Int  :$TimeRangeLowerBound,
        Int  :$TimeRangeUpperBound,
    ) returns Promise

List backups associated with an AWS account. To list backups for a given table,
specify TableName. ListBackups returns a paginated list of results with at most
1MB worth of items in a page. You can also specify a limit for the maximum
number of entries to be returned in a page.

See the L<AWS ListBackups API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListBackups.html>.

=head2 method RestoreTableFromBackup

    method RestoreTableFromBackup(
        Str  :$BackupArn!,
        Str  :$TargetTableName!,
    ) returns Promise

Creates a new table from an existing backup. Any number of users can execute up
to 4 concurrent restores (any type of restore) in a given account.

See the L<AWS RestoreTableFromBackup API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableFromBackup.html>.

=head2 method DescribeLimits

    method DescribeLimits() returns Promise

Returns the current provisioned-capacity limits for your AWS account in a
region, both for the region as a whole and for any one DynamoDB table that you
create there.

See the L<AWS DescribeLimits API documentation|https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html>.

=end pod

class GLOBAL::X::Amazon::DynamoDB::CommunicationError is Exception {
    has %.request;
    has %.response;

    method message() { "Communication Error" }
}

class GLOBAL::X::Amazon::DynamoDB::CRCError is Exception {
    has Int $.got-crc32;
    has Int $.expected-crc32;

    method message() { "Response failed CRC32 check, expected $!expected-crc32, but got $!got-crc32" }
}

class GLOBAL::X::Amazon::DynamoDB::APIException is Exception {
    has Str $.request-id;
    has Str $.raw-type;
    has Str $.message;

    method type(::?CLASS:D:) { $!raw-type.split('#', 2)[1] }

    method of-type(::?CLASS:U: $type) {
        -> $x {
            $x ~~ ::?CLASS
                && $x.defined
                && $x.type eq $type
        }
    }
}

has AWS::Session $.session is rw;
has AWS::Credentials $.credentials is rw;

has Str $.scheme = 'https';
has Str $.domain = 'amazonaws.com';
has Str $.hostname;
has Int $.port;

use Amazon::DynamoDB::UA::Cro;
has Amazon::DynamoDB::UA $.ua = Amazon::DynamoDB::UA::Cro.new;

method hostname() returns Str:D { $!hostname.defined ?? $!hostname !! "dynamodb.$.region.$!domain" }
method port-suffix() returns Str:D { $!port.defined ?? ":$!port" !! "" }

method session() returns AWS::Session is rw {
    $!session //= AWS::Session.new;
    return-rw $!session;
}

method credentials() returns AWS::Credentials is rw {
    $!credentials //= load-credentials($.session);
    return-rw $!credentials;
}

method access-key() { $.credentials.access-key }
method secret-key() { $.credentials.secret-key }
method region()     { $.session.region }

method make-ddb-request($target, *%request) {
    use HTTP::Request::Common;
    use JSON::Fast;
    use WebService::AWS::Auth::V4;

    my %crisp-request = %request.grep({ ?.value });

    # :sorted-keys helps tests pass... we should probably make the tests
    # smarter, though and drop :sorted-keys
    my $body = to-json(%crisp-request, :sorted-keys);
    my $uri  = "$!scheme://$.hostname$.port-suffix/";

    my %headers =
        Host         => $.hostname,
        Content-Type => 'application/x-amz-json-1.0',
        X-Amz-Date   => amz-date-formatter(DateTime.now),
        X-Amz-Target => "DynamoDB_20120810.$target",
        ;

    my Str @headers = %headers.map({ "{.key}:{.value}" });

    my $v4 = WebService::AWS::Auth::V4.new(
        :method<POST>, :$body, :$uri, :@headers, :$.region, :service<dynamodb>,
        :access_key($.access-key), :secret($.secret-key)
    );

    my $authorization = $v4.signing-header.substr("Authorization: ".chars);
    %headers<Authorization> = $authorization;

    my %req = :method<POST>, :$uri, :%headers, :content($body);

    $!ua.request(|%req).then: {
        my %res = .result;

        if %res<Status> == 200 {
            use String::CRC32;

            my $request-id = %res<Header><x-amzn-requestid>.Str;
            my $crc32      = Int(%res<Header><x-amz-crc32>.Str);

            my $got-crc32 = String::CRC32::crc32(await %res<RawContent>);

            if $crc32 != $got-crc32 {
                die X::Amazon::DynamoDB::CRCError.new(
                    expected-crc32 => $crc32,
                    got-crc32      => $got-crc32,
                );
            }

            my %response = from-json(await %res<DecodedContent>);
            %response<RequestId> = $request-id;

            # RETURN
            %response;
        }
        elsif %res<Status> == 400
                && %res<Header><content-type> eq 'application/x-amz-json-1.0'
                && from-json(await %res<DecodedContent>) -> $error {

            if $error<__type> && $error<message> {
                my $request-id = %res<x-amzn-requestid>.Str,
                die X::Amazon::DynamoDB::APIException.new(
                    request-id => $request-id,
                    raw-type   => $error<__type>,
                    message    => $error<message>,
                );
            }
            else {
                die X::Amazon::DynamoDB::CommunicationError.new(
                    request  => %req,
                    response => %res,
                );
            }
        }
        else {
            die X::Amazon::DynamoDB::CommunicationError.new(
                request  => %req,
                response => %res,
            );
        }
    };
}

method BatchGetItem(
         :%RequestItems!,

    Str  :$ReturnConsumedCapacity,
) returns Promise {
    self.make-ddb-request('BatchGetItem',
        :%RequestItems,

        :$ReturnConsumedCapacity,
    );
}

method BatchWriteItem(
         :%RequestItems!,

    Str  :$ReturnConsumedCapacity,
    Str  :$ReturnItemCollectionMetrics,
) returns Promise {
    self.make-ddb-request('BatchWriteItem',
        :%RequestItems,

        :$ReturnConsumedCapacity,
        :$ReturnItemCollectionMetrics,
    );
}

method DeleteItem(
         :%Key!,
    Str  :$TableName!,

    Str  :$ConditionalOperator,
    Str  :$ConditionExpression,
    Str  :$Expected,
         :%ExpressionAttributeNames,
         :%ExpressionAttributeValues,
    Str  :$ReturnConsumedCapacity,
    Str  :$ReturnItemCollectionMetrics,
    Str  :$ReturnValues,
) returns Promise {
    self.make-ddb-request('DeleteItem',
        :%Key,
        :$TableName,

        :$ConditionalOperator,
        :$ConditionExpression,
        :$Expected,
        :%ExpressionAttributeNames,
        :%ExpressionAttributeValues,
        :$ReturnConsumedCapacity,
        :$ReturnItemCollectionMetrics,
        :$ReturnValues,
    );
}

method GetItem(
         :%Key!,
    Str  :$TableName!,

         :@AttributesToGet,
    Bool :$ConsistentRead,
         :%ExpressionAttributeNames,
    Str  :$ProjectionExpression,
    Str  :$ReturnConsumedCapacity,
) returns Promise {
    self.make-ddb-request('GetItem',
        :%Key,
        :$TableName,

        :@AttributesToGet,
        :$ConsistentRead,
        :%ExpressionAttributeNames,
        :$ProjectionExpression,
        :$ReturnConsumedCapacity,
    );
}

method PutItem(
         :%Item!,
    Str  :$TableName!,

    Str  :$ConditionalOperator,
    Str  :$ConditionExpression,
         :%Expected,
         :%ExressionAttributeNames,
         :%ExpressionAttributeValues,
    Str  :$ReturnConsumedCapacity,
    Str  :$ReturnItemCollectionMetrics,
    Str  :$ReturnValues,
) returns Promise {
    self.make-ddb-request('PutItem',
        :%Item,
        :$TableName,

        :$ConditionalOperator,
        :$ConditionExpression,
        :%Expected,
        :%ExressionAttributeNames,
        :%ExpressionAttributeValues,
        :$ReturnConsumedCapacity,
        :$ReturnItemCollectionMetrics,
        :$ReturnValues,
    );
}

method Query(
    Str  :$TableName!,

         :@AttributesToGet,
    Str  :$ConditionalOperator,
    Bool :$ConsistentRead,
         :%ExclusiveStartKey,
         :%ExpressionAttributeNames,
         :%ExpressionAttributeValues,
    Str  :$FilterExpression,
    Str  :$IndexName,
    Str  :$KeyConditionExpression,
         :%KeyConditions,
    Int  :$Limit,
    Str  :$ProjectionExpression,
         :%QueryFilter,
    Str  :$ReturnConsumedCapacity,
    Bool :$ScanIndexForward,
    Str  :$Select,
) returns Promise {
    self.make-ddb-request('Query',
        :$TableName,

        :@AttributesToGet,
        :$ConditionalOperator,
        :$ConsistentRead,
        :%ExclusiveStartKey,
        :%ExpressionAttributeNames,
        :%ExpressionAttributeValues,
        :$FilterExpression,
        :$IndexName,
        :$KeyConditionExpression,
        :%KeyConditions,
        :$Limit,
        :$ProjectionExpression,
        :%QueryFilter,
        :$ReturnConsumedCapacity,
        :$ScanIndexForward,
        :$Select,
    );
}

method Scan(
    Str  :$TableName!,

         :@AttributesToGet,
    Str  :$ConditionalOperator,
    Bool :$ConsistentRead,
         :%ExclusiveStartKey,
         :%ExpressionAttributeNames,
         :%ExpressionAttributeValues,
    Str  :$FilterExpression,
    Str  :$IndexName,
    Int  :$Limit,
    Str  :$ProjectionExpression,
         :%QueryFilter,
    Str  :$ReturnConsumedCapacity,
         :%ScanFilter,
    Int  :$Segment,
    Str  :$Select,
    Int  :$TotalSegments,
) returns Promise {
    self.make-ddb-request('Scan',
        :$TableName,

        :@AttributesToGet,
        :$ConditionalOperator,
        :$ConsistentRead,
        :%ExclusiveStartKey,
        :%ExpressionAttributeNames,
        :%ExpressionAttributeValues,
        :$FilterExpression,
        :$IndexName,
        :$Limit,
        :$ProjectionExpression,
        :%QueryFilter,
        :$ReturnConsumedCapacity,
        :%ScanFilter,
        :$Segment,
        :$Select,
        :$TotalSegments,
    );
}

method UpdateItem(
         :%Key!,
    Str  :$TableName!,

         :%AttributeUpdates,
    Str  :$ConditionalOperator,
    Str  :$ConditionExpression,
         :%Expected,
         :%ExpressionAttributeNames,
         :%ExpressionAttributeValues,
    Str  :$ReturnConsumedCapacity,
    Str  :$ReturnItemCollectionMetrics,
    Str  :$ReturnValues,
    Str  :$UpdateExpression,
) returns Promise {
    self.make-ddb-request('UpdateItem',
        :%Key,
        :$TableName,

        :%AttributeUpdates,
        :$ConditionalOperator,
        :$ConditionExpression,
        :%Expected,
        :%ExpressionAttributeNames,
        :%ExpressionAttributeValues,
        :$ReturnConsumedCapacity,
        :$ReturnItemCollectionMetrics,
        :$ReturnValues,
        :$UpdateExpression,
    );
}

method CreateTable(
         :@AttributeDefinitions!,
    Str  :$TableName!,
         :@KeySchema!,
         :%ProvisionedThroughput!,

         :@GlobalSecondaryIndexes,
         :@LocalSecondaryIndexes,
         :%SSESpecification,
         :%StreamSpecification,
) returns Promise {
    self.make-ddb-request('CreateTable',
        :@AttributeDefinitions,
        :$TableName,
        :@KeySchema,
        :%ProvisionedThroughput,

        :@GlobalSecondaryIndexes,
        :@LocalSecondaryIndexes,
        :%SSESpecification,
        :%StreamSpecification,
    );
}

method DeleteTable(
    Str :$TableName,
) returns Promise {
    self.make-ddb-request('DeleteTable', :$TableName);
}

method DescribeTable(
    Str  :$TableName!,
) returns Promise {
    self.make-ddb-request('DescribeTable', :$TableName);
}

method DescribeTimeToLive(
    Str  :$TableName!,
) returns Promise {
    self.make-ddb-request('DescribeTimeToLive', :$TableName);
}

method ListTables(
    Str  :$ExclusiveStartTableName,
    Int  :$Limit,
) returns Promise {
    self.make-ddb-request('ListTables',
        :$ExclusiveStartTableName,
        :$Limit,
    );
}

method UpdateTable(
    Str  :$TableName!,

         :@AttributeDefinitions,
         :@GlobalSecondaryIndexUpdates,
         :%ProvisionedThroughput,
         :%StreamSpecification,
) returns Promise {
    self.make-ddb-request('UpdateTable',
        :$TableName,

        :@AttributeDefinitions,
        :@GlobalSecondaryIndexUpdates,
        :%ProvisionedThroughput,
        :%StreamSpecification,
    );
}

method UpdateTimeToLive(
    Str  :$TableName!,
         :%TableToLiveSpecification!,
) returns Promise {
    self.make-ddb-request('UpdateTimeToLive',
        :$TableName,
        :%TableToLiveSpecification,
    );
}

method CreateGlobalTable(
    Str  :$GlobalTableName!,
         :@ReplicationGroup!,
) returns Promise {
    self.make-ddb-request('CreateGlobalTable',
        :$GlobalTableName,
        :@ReplicationGroup,
    );
}

method DescribeGlobalTable(
    Str  :$GlobalTableName!,
) returns Promise {
    self.make-ddb-request('DescribeGlobalTable',
        :$GlobalTableName,
    );
}

method ListGlobalTables(
    Str  :$ExclusiveStartGlobalTableName,
    Int  :$Limit,
    Str  :$RegionName,
) returns Promise {
    self.make-ddb-request('ListGlobalTables',
        :$ExclusiveStartGlobalTableName,
        :$Limit,
        :$RegionName,
    );
}

method UpdateGlobalTable(
    Str  :$GlobalTableName!,
         :@ReplicaUpdates!,
) returns Promise {
    self.make-ddb-request('UpdateGlobalTable',
        :$GlobalTableName,
        :@ReplicaUpdates,
    );
}

method ListTagsOfResource(
    Str  :$ResourceArn!,

    Str  :$NextToken,
) returns Promise {
    self.make-ddb-request('ListTagsOfResource',
        :$ResourceArn,

        :$NextToken,
    );
}

method TagResource(
    Str  :$ResourceArn!,
         :@Tags!,
) returns Promise {
    self.make-ddb-reqeust('TagResource',
        :$ResourceArn,
        :@Tags,
    );
}

method UntagResource(
    Str  :$ResourceArn!,
         :@TagKeys!,
) returns Promise {
    self.make-ddb-request('UntagResource',
        :$ResourceArn,
        :@TagKeys,
    );
}

method CreateBackup(
    Str  :$BackupName!,
    Str  :$TableName!,
) returns Promise {
    self.make-ddb-request('CreateBackup',
        :$BackupName,
        :$TableName,
    );
}

method DeleteBackup(
    Str  :$BackupArn!,
) returns Promise {
    self.make-ddb-request('DeleteBackup', :$BackupArn);
}

method DescribeBackup(
    Str  :$BackupArn!,
) returns Promise {
    self.make-ddb-request('DescribeBackup', :$BackupArn);
}

method DescribeContinuousBackups(
    Str  :$TableName!,
) returns Promise {
    self.make-ddb-request('DescribeContinuousBackups', :$TableName);
}

method ListBackups(
    Str  :$ExclusiveStartBackupArn,
    Int  :$Limit,
    Str  :$TableName,
    Int  :$TimeRangeLowerBound,
    Int  :$TimeRangeUpperBound,
) returns Promise {
    self.make-ddb-request('ListBackups',
        :$ExclusiveStartBackupArn,
        :$Limit,
        :$TableName,
        :$TimeRangeLowerBound,
        :$TimeRangeUpperBound,
    );
}

method RestoreTableFromBackup(
    Str  :$BackupArn!,
    Str  :$TargetTableName!,
) returns Promise {
    self.make-ddb-request('RestoreTableFromBackup',
        :$BackupArn,
        :$TargetTableName,
    );
}

method DescribeLimits() returns Promise {
    self.make-ddb-request('DescribeLimits');
}
