import ballerina/io;
import ballerinax/rabbitmq;

# Prints `Hello World`.

public function main() {
    io:println("Hello World!");
}
public function sum(int a, int b) returns int{
    return a + b;
}

public function sendMessage(string queueName, string channelMessage) returns error?{
    rabbitmq:Connection connection = new ({host: "localhost", port: 5672});
    rabbitmq:Channel inventoryChannel = new (connection);
    var queueResult = inventoryChannel->queueDeclare({queueName: queueName});
    if (queueResult is error) {
        io:println("An error occurred while creating the queue.");
    }
    var sendResult = check inventoryChannel->basicPublish(channelMessage, queueName);
}