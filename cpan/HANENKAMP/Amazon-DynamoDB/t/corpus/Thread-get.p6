%(
    TableName => tn("Thread"),
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
)
