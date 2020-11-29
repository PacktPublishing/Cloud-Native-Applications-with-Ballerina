public type ChannelCommandMessage record {
    string serviceType;
    string entityId;
    json message;
};