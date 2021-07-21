// Go to RabbitMQ home and start RabbitMQ with `./sbin/rabbitmq-server` command
// Use `brew services start rabbitmq` for HomeBrew
// Start consumer with `bal run rabbitmq/rabbitmq_consumer/`
// Start producer with `bal run rabbitmq/rabbitmq_producer/`
import ballerina/io;
import ballerinax/rabbitmq;
listener rabbitmq:Listener channelListener = new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
@rabbitmq:ServiceConfig {
    queueName: "TestQueue"
}
service rabbitmq:Service on channelListener {
    remote function onMessage(rabbitmq:Message message, rabbitmq:Caller caller) returns error? {
        string messageContent = check string:fromBytes(message.content);
        json responseMessage = checkpanic messageContent.fromJsonString();
        io:print("The message received: " + responseMessage.toString());
    }
}