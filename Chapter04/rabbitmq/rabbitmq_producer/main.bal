import ballerinax/rabbitmq;

public function main() returns error?{
    rabbitmq:Client newClient = check new(rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
    check newClient->queueDeclare("TestQueue");
    json message = {"data": "Hello from Ballerina"};
    check newClient->publishMessage({ content: message.toString().toBytes(), routingKey: "TestQueue" });
}
