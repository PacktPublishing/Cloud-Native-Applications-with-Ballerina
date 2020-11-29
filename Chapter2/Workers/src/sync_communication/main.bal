import ballerina/io;
import ballerina/runtime;

public function main() returns error? {
    worker w1 {
        io:println("Worker 1: Started and wait 1s");
        runtime:sleep(1000);
        io:println("Worker 1: Sending message to worker 2");
        56 -> w2;
        io:println("Worker 2: End worker");
        
    }
    worker w2 {
        io:println("Worker 2: Started. wait for worker 1");
        int value = <- w1;
        io:println("Worker 2: Message received");
        runtime:sleep(1000);
        io:println("Worker 2: End worker");
    }
    _ = wait {w1, w2};
    io:println("End of execution");
}
