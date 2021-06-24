import ballerinax/kafka;

kafka:ProducerConfiguration producerConfiguration = {
    acks: "all",
    retryCount: 3
};
kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfiguration);
public function main() returns error? {
    json message = {"data": "Hello from Ballerina"};
    check kafkaProducer->send({topic: "TestTopic", value: message.toString().toBytes() });
    check kafkaProducer->'flush();
}