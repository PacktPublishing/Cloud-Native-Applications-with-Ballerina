import ballerina/io;
import ballerina/runtime;

public function main() returns error? {
    worker w1 {
        foreach int i in 0 ... 10 {
            io:println("Worker 1 with index " + i.toString());
            runtime:sleep(500);
        }
    }
    worker w2 {
        foreach int i in 0 ... 10 {
            io:println("Worker 2 with index " + i.toString());
            runtime:sleep(500);
        }
    }
    _ = wait {w1, w2};
    io:println("End of execution");
}