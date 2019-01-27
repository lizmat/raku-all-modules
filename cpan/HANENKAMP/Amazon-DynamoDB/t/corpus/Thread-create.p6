%(
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
    TableName => tn('Thread'),
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
)
