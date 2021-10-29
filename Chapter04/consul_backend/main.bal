// This example is to demostrate service descovery with Consul
// Build this sample with `bal build --cloud=k8s consul_backend/`
// Execute `kustomize build consul_backend/ | kubectl apply -f -` command
// Go to the consul_caller_service example and follow instructions

import ballerina/http;
service /backend on new http:Listener(9091) { // change base path and resource function name
    resource function get greeting() returns error|string { 
        return "Hello from backend server!"; 
    }
}