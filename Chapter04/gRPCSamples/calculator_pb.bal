import ballerina/grpc;

public isolated client class OrderCalculateClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, ROOT_DESCRIPTOR, getDescriptorMap());
    }

    isolated remote function calculateOneByOne(OrderItem|ContextOrderItem req) returns (float|grpc:Error) {
        map<string|string[]> headers = {};
        OrderItem message;
        if (req is ContextOrderItem) {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("OrderCalculate/calculateOneByOne", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <float>result;
    }

    isolated remote function calculateOneByOneContext(OrderItem|ContextOrderItem req) returns (ContextFloat|grpc:Error) {
        map<string|string[]> headers = {};
        OrderItem message;
        if (req is ContextOrderItem) {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("OrderCalculate/calculateOneByOne", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <float>result, headers: respHeaders};
    }

    isolated remote function calculateAsStream() returns (CalculateAsStreamStreamingClient|grpc:Error) {
        grpc:StreamingClient sClient = check self.grpcClient->executeBidirectionalStreaming("OrderCalculate/calculateAsStream");
        return new CalculateAsStreamStreamingClient(sClient);
    }
}

public client class CalculateAsStreamStreamingClient {
    private grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendOrderItem(OrderItem message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextOrderItem(ContextOrderItem message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveFloat() returns float|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return <float>payload;
        }
    }

    isolated remote function receiveContextFloat() returns ContextFloat|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <float>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public client class OrderCalculateFloatCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendFloat(float response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextFloat(ContextFloat response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }
}

public type ContextOrderItem record {|
    OrderItem content;
    map<string|string[]> headers;
|};

public type ContextFloat record {|
    float content;
    map<string|string[]> headers;
|};

public type OrderItem record {|
    string itemId = "";
    int quantity = 0;
|};

const string ROOT_DESCRIPTOR = "0A1063616C63756C61746F722E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F223F0A094F726465724974656D12160A066974656D496418012001280952066974656D4964121A0A087175616E7469747918022001280352087175616E746974793290010A0E4F7264657243616C63756C61746512400A1163616C63756C617465417353747265616D120A2E4F726465724974656D1A1B2E676F6F676C652E70726F746F6275662E466C6F617456616C756528013001123C0A1163616C63756C6174654F6E6542794F6E65120A2E4F726465724974656D1A1B2E676F6F676C652E70726F746F6275662E466C6F617456616C7565620670726F746F33";

isolated function getDescriptorMap() returns map<string> {
    return {"calculator.proto": "0A1063616C63756C61746F722E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F223F0A094F726465724974656D12160A066974656D496418012001280952066974656D4964121A0A087175616E7469747918022001280352087175616E746974793290010A0E4F7264657243616C63756C61746512400A1163616C63756C617465417353747265616D120A2E4F726465724974656D1A1B2E676F6F676C652E70726F746F6275662E466C6F617456616C756528013001123C0A1163616C63756C6174654F6E6542794F6E65120A2E4F726465724974656D1A1B2E676F6F676C652E70726F746F6275662E466C6F617456616C7565620670726F746F33", "google/protobuf/wrappers.proto": "0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F62756622230A0B446F75626C6556616C756512140A0576616C7565180120012801520576616C756522220A0A466C6F617456616C756512140A0576616C7565180120012802520576616C756522220A0A496E74363456616C756512140A0576616C7565180120012803520576616C756522230A0B55496E74363456616C756512140A0576616C7565180120012804520576616C756522220A0A496E74333256616C756512140A0576616C7565180120012805520576616C756522230A0B55496E74333256616C756512140A0576616C756518012001280D520576616C756522210A09426F6F6C56616C756512140A0576616C7565180120012808520576616C756522230A0B537472696E6756616C756512140A0576616C7565180120012809520576616C756522220A0A427974657356616C756512140A0576616C756518012001280C520576616C756542570A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"};
}

