import ballerina/time;
public type Snapshot record {
    string snapshotId;
    string entityType;
    string entityId;
    int entityVersion;
    string message;
    time:Time timestamp;
};