import ballerina/time;
public type Event record {
    string eventId;
    string eventType;
    string entityType;
    string entityId;
    string eventData;
    time:Time timestamp;
};