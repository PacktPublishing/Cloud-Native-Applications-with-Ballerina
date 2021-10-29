// Start Kafka zookeeper with `./bin/zookeeper-server-start.sh config/zookeeper.properties`
// Start Kafka broker with `./bin/kafka-server-start.sh config/server.properties`
// Start Kafka consumer with `bal run kafka/kafka_consumer`
// Publish messages with `bal run kafka/kafka_producer/`

import ballerinax/kafka;
import ballerina/io;
kafka:ConsumerConfiguration consumerConfigs = {
    groupId: "Consumer1",
    topics: ["TestTopic"],
    pollingInterval: 1
};
listener kafka:Listener kafkaListener = new (kafka:DEFAULT_URL, consumerConfigs);
service kafka:Service on kafkaListener {
    remote function onConsumerRecord(kafka:Caller caller,
                                kafka:ConsumerRecord[] records) {
        foreach var kafkaRecord in records {
            string|error messageContent = string:fromBytes(kafkaRecord.value);
            if messageContent is string {
                json responseMessage = checkpanic messageContent.fromJsonString();
                io:print("The message received: " + responseMessage.toString());
            }
        }
        var commitResult = caller->commit();
        if (commitResult is error) {
            io:println("Error while commit");
        }
    }
}