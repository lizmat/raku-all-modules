${:ConditionExpression("attribute_not_exists(Replies)"), :Key(${:ForumName(${:S("Amazon DynamoDB")}), :Subject(${:S("How do I update multiple items?")})}), :ReturnValues("ALL_OLD"), :TableName("Thread")}