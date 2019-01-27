NAME
====

Amazon::DynamoDB - Low-level access to the DynamoDB API

SYNOPSIS
========

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

DESCRIPTION
===========

This module provides an asynchronous, low-level API that interacts directly with DynamoDB. This is a low-level implementation that sticks as close as possible to the API described by AWS, keeping the names of actions and parameter names as-is (i.e., not using nice kabob-case most Perl 6 modules use, but the PascalCase that most AWS APIs present natively). This has the benefit of allowing you to use the AWS documentation directly.

The API is currently very primitive and may change to provide better type-checking in the future.

DIAGNOSTICS
===========

The following exceptions may be thrown by this module:

X::Amazon::DynamoDB::APIException
---------------------------------

This encapsulates the errors returned from the API itself. The name of the error can be checked at the `type` method and the message in `message`. It has the following accessors:

  * request-id The request id returned with the error.

  * raw-type The __type returned with the error (a combination of the API version and error type).

  * type The error type pulled from the raw-type.

  * message The detailed message sent with the error.

This is the exception you will most likely want to capture. For this reason, a special helper named `of-type` is provided to aid in easy matching.

For example, if you want to perform a `CreateTable` operation, but ignore any "ResourceInUseException" indicating that the table already exists, it is recommended that you do something like this:

    my $ddb = Amazon::DynamoDB.new;
    $ddb.CreateTable( ... );

    CATCH {
        when X::Amazon::DynamoDB::APIException.of-type('ResourceInUseException') {
            # ignore
        }
    }

X::Amazon::DynamoDB::CommunicationError
---------------------------------------

This is a generic error, generally caused by HTTP connection problems, but might be caused by especially fatal errors in the API. The message is simply "Communication Error", but provides two attributes for more information:

  * request This is the `HTTP::Request` that was attempted.

  * response This is the `HTTP::Response` that was received (which might be a fake response generated by the user agent if no response was received.

X::Amazon::DynamoDB::CRCError
-----------------------------

Every response from DynamoDB includes a CRC32 checksum. This module verifies that checksum on every request. If the checksum given by Amazon does not match the checksum calculated, this error will be thrown.

It provides these attributes:

  * got-crc32 This is the integer CRC32 we calculated.

  * expected-crc32 This is the integer CRC32 Amazon sent.

ASYNC API
=========

The API for this is asynchronous. Mostly, this means that the API methods return a [Promise](Promise) that will be kept with a [Hash](Hash) containing the results. If you want a purely syncrhonous API, you just need to place an `await` before every call to the library.

Under the hood, the implementation is currently implemented to use [Cro::HTTP::Client](Cro::HTTP::Client) if present. If not present, then [HTTP::UserAgent](HTTP::UserAgent) is used instead, though all actions will run on separate threads from the calling thread.

METHODS
=======

method new
----------

    multi method new(
        AWS::Session :$session,
        AWS::Credentials :$credentials,
        Str :$scheme = 'https',
        Str :$domain = 'amazonaws.com',
        Str :$hostname,
        Int :$port,
        HTTP::UserAgent :$ua,
    ) returns Amazon::DynamoDB

All arguments to new are optional. The `$session` and `$credentials` will be constructed lazily if not given to `new` using default settings.

By default, the `$port` and `$hostname` are unset. This means that no port will be specified (just the default port for the scheme will be used) and the `hostname` used till be constructed from the `$domain` and region defined in the session.

See [AWS::Session](AWS::Session) and [AWS::Credentials](AWS::Credentials) for details on how to customize your settings. However, if you are familiar with how botocore/aws-cli and other tools configure themselves, this will be familiar.

method session
--------------

    method session() returns AWS::Session is rw

Getter/setter for the session used to configure AWS settings.

method credentials
------------------

    method credentials() returns AWS::Credentials is rw

Getter/setter for the credentails used to contact AWS.

method scheme
-------------

    method scheme() returns Str

Getter for the scheme. Defaults to "https".

method domain
-------------

    method domain() returns Str

Getter for the domain. Defaults to "amazonaws.com".

method hostname
---------------

    method hostname() returns Str

This returns the hostname that will be contacted with DynamoDB calls. It is either set by the `hostname` setting when calling `new` or constructed from the `domain` and configured region.

method port
-----------

    method port() returns Int

This returns the port number to use when contacting DynamoDB. This returns `Nil` if the default port is used (i.e., 80 when `scheme` is "http" or 443 when "https").

API METHODS
===========

These are the methods implemented as part of the AWS API. Please see the AWS API documentation for more detail as to what each argument does and the structure of the return value.

method BatchGetItem
-------------------

    method BatchGetItem(
             :%RequestItems!,
        Str  :$ReturnConsumedCapacity,
    ) returns Promise

The BatchGetItem operation returns the attributes of one or more items from one or more tables. You identify requested items by primary key.

See the [AWS BatchGetItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html).

method BatchWriteItem
---------------------

    method BatchWriteItem(
             :%RequestItems!
        Str  :$ReturnConsumedCapacity,
        Str  :$ReturnItemCollectionMetrics,
    ) returns Promise

The BatchWriteItem operation puts or deletes multiple items in one or more tables. A single call to BatchWriteItem can write up to 16 MB of data, which can comprise as many as 25 put or delete requests. Individual items to be written can be as large as 400 KB.

See the [AWS BatchWriteItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html).

method DeleteItem
-----------------

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

Deletes a single item in a table by primary key. You can perform a conditional delete operation that deletes the item if it exists, or if it has an expected attribute value.

See the [AWS DeleteItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html).

method GetItem
--------------

    method GetItem(
             :%Key!,
        Str  :$TableName!,
             :@AttributesToGet,
        Bool :$ConsistentRead,
             :%ExpressionAttributeNames,
        Str  :$ProjectionExpression,
        Str  :$ReturnConsumedCapacity,
    ) returns Promise

The GetItem operation returns a set of attributes for the item with the given primary key. If there is no matching item, GetItem does not return any data and there will be no Item element in the response.

See the [AWS GetItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html).

method PutItem
--------------

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

Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new item already exists in the specified table, the new item completely replaces the existing item. You can perform a conditional put operation (add a new item if one with the specified primary key doesn't exist), or replace an existing item if it has certain attribute values. You can return the item's attribute values in the same operation, using the ReturnValues parameter.

See the [AWS PutItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html).

method Query
------------

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

The Query operation finds items based on primary key values. You can query any table or secondary index that has a composite primary key (a partition key and a sort key).

See the [AWS Query API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html).

method Scan
-----------

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

The Scan operation returns one or more items and item attributes by accessing every item in a table or a secondary index. To have DynamoDB return fewer items, you can provide a FilterExpression operation.

See the [AWS Scan API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html).

method UpdateItem
-----------------

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

Edits an existing item's attributes, or adds a new item to the table if it does not already exist. You can put, delete, or add attribute values. You can also perform a conditional update on an existing item (insert a new attribute name-value pair if it doesn't exist, or replace an existing name-value pair if it has certain expected attribute values).

See the [AWS UpdateItem API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html).

method CreateTable
------------------

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

The CreateTable operation adds a new table to your account. In an AWS account, table names must be unique within each region. That is, you can have two tables with same name if you create the tables in different regions.

See the [AWS CreateTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html).

method DeleteTable
------------------

    method DeleteTable(
        Str :$TableName,
    ) returns Promise

The DeleteTable operation deletes a table and all of its items. After a DeleteTable request, the specified table is in the DELETING state until DynamoDB completes the deletion. If the table is in the ACTIVE state, you can delete it. If a table is in CREATING or UPDATING states, then DynamoDB returns a ResourceInUseException. If the specified table does not exist, DynamoDB returns a ResourceNotFoundException. If table is already in the DELETING state, no error is returned.

See the [AWS DeleteTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html).

method DescribeTable
--------------------

    method DescribeTable(
        Str  :$TableName!,
    ) returns Promise

Returns information about the table, including the current status of the table, when it was created, the primary key schema, and any indexes on the table.

See the [AWS DescribeTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html).

method DescribeTimeToLive
-------------------------

    method DescribeTimeToLive(
        Str  :$TableName!,
    ) returns Promise

Gives a description of the Time to Live (TTL) status on the specified table.

See the [AWS DescribeTimeToLive API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTimeToLive.html).

method ListTables
-----------------

    method ListTables(
        Str  :$ExclusiveStartTableName,
        Int  :$Limit,
    ) returns Promise

Returns an array of table names associated with the current account and endpoint. The output from ListTables is paginated, with each page returning a maximum of 100 table names.

See the [AWS ListTables API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html).

method UpdateTable
------------------

    method UpdateTable(
        Str  :$TableName!,
             :@AttributeDefinitions,
             :@GlobalSecondaryIndexUpdates,
             :%ProvisionedThroughput,
             :%StreamSpecification,
    ) returns Promise

Modifies the provisioned throughput settings, global secondary indexes, or DynamoDB Streams settings for a given table.

See the [AWS UpdateTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html).

method UpdateTimeToLive
-----------------------

    method UpdateTimeToLive(
        Str  :$TableName!,
             :%TableToLiveSpecification!,
    ) returns Promise

The UpdateTimeToLive method will enable or disable TTL for the specified table. A successful UpdateTimeToLive call returns the current TimeToLiveSpecification; it may take up to one hour for the change to fully process. Any additional UpdateTimeToLive calls for the same table during this one hour duration result in a ValidationException.

See the [AWS UpdateTimeToLive API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html).

method CreateGlobalTable
------------------------

    method CreateGlobalTable(
        Str  :$GlobalTableName!,
             :@ReplicationGroup!,
    ) returns Promise

Creates a global table from an existing table. A global table creates a replication relationship between two or more DynamoDB tables with the same table name in the provided regions.

See the [AWS CreateGlobalTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateGlobalTable.html).

method DescribeGlobalTable
--------------------------

    method DescribeGlobalTable(
        Str  :$GlobalTableName!,
    ) returns Promise

Returns information about the specified global table.

See the [AWS DescribeGlobalTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeGlobalTable.html).

method ListGlobalTables
-----------------------

    method ListGlobalTables(
        Str  :$ExclusiveStartGlobalTableName,
        Int  :$Limit,
        Str  :$RegionName,
    ) returns Promise

Lists all global tables that have a replica in the specified region.

See the [AWS ListGlobalTables API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListGlobalTables.html).

method UpdateGlobalTable
------------------------

    method UpdateGlobalTable(
        Str  :$GlobalTableName!,
             :@ReplicaUpdates!,
    ) returns Promise

Adds or removes replicas in the specified global table. The global table must already exist to be able to use this operation. Any replica to be added must be empty, must have the same name as the global table, must have the same key schema, and must have DynamoDB Streams enabled and must have same provisioned and maximum write capacity units.

See the [AWS UpdateGlobalTable API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateGlobalTable.html).

method ListTagsOfResource
-------------------------

    method ListTagsOfResource(
        Str  :$ResourceArn!,
        Str  :$NextToken,
    ) returns Promise

List all tags on an Amazon DynamoDB resource. You can call ListTagsOfResource up to 10 times per second, per account.

See the [AWS ListTagsOfResource API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTagsOfResource.html).

method TagResource
------------------

    method TagResource(
        Str  :$ResourceArn!,
             :@Tags!,
    ) returns Promise

Associate a set of tags with an Amazon DynamoDB resource. You can then activate these user-defined tags so that they appear on the Billing and Cost Management console for cost allocation tracking. You can call TagResource up to 5 times per second, per account.

See the [AWS TagResource API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TagResource.html).

method UntagResource
--------------------

    method UntagResource(
        Str  :$ResourceArn!,
             :@TagKeys!,
    ) returns Promise

Removes the association of tags from an Amazon DynamoDB resource. You can call UntagResource up to 5 times per second, per account.

See the [AWS UntagResource API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UntagResource.html).

method CreateBackup
-------------------

    method CreateBackup(
        Str  :$BackupName!,
        Str  :$TableName!,
    ) returns Promise

Creates a backup for an existing table.

See the [AWS CreateBackup API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateBackup.html).

method DeleteBackup
-------------------

    method DeleteBackup(
        Str  :$BackupArn!,
    ) returns Promise

Deletes an existing backup of a table.

See the [AWS DeleteBackup API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteBackup.html).

method DescribeBackup
---------------------

    method DescribeBackup(
        Str  :$BackupArn!,
    ) returns Promise

Describes an existing backup of a table.

See the [AWS DescribeBackup API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeBackup.html).

method DescribeContinuousBackups
--------------------------------

    method DescribeContinuousBackups(
        Str  :$TableName!,
    ) returns Promise

Checks the status of continuous backups and point in time recovery on the specified table. Continuous backups are ENABLED on all tables at table creation. If point in time recovery is enabled, PointInTimeRecoveryStatus will be set to ENABLED.

See the [AWS DescribeContinuousBackups API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeContinuousBackups.html).

method ListBackups
------------------

    method ListBackups(
        Str  :$ExclusiveStartBackupArn,
        Int  :$Limit,
        Str  :$TableName,
        Int  :$TimeRangeLowerBound,
        Int  :$TimeRangeUpperBound,
    ) returns Promise

List backups associated with an AWS account. To list backups for a given table, specify TableName. ListBackups returns a paginated list of results with at most 1MB worth of items in a page. You can also specify a limit for the maximum number of entries to be returned in a page.

See the [AWS ListBackups API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListBackups.html).

method RestoreTableFromBackup
-----------------------------

    method RestoreTableFromBackup(
        Str  :$BackupArn!,
        Str  :$TargetTableName!,
    ) returns Promise

Creates a new table from an existing backup. Any number of users can execute up to 4 concurrent restores (any type of restore) in a given account.

See the [AWS RestoreTableFromBackup API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableFromBackup.html).

method DescribeLimits
---------------------

    method DescribeLimits() returns Promise

Returns the current provisioned-capacity limits for your AWS account in a region, both for the region as a whole and for any one DynamoDB table that you create there.

See the [AWS DescribeLimits API documentation](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html).

