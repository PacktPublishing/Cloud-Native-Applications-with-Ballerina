// This sample demostrate the readiness and liveness check of the Kubernetes deployment.
// Build with `bal build --cloud=k8s health_check/` command.
// Execute `kubectl apply -f <project_home>/target/kubernetes/health_check` command.
// Execute `kubectl get deployments`.
// Deployment list show this deployment does not ready since localhost:9091/backend/health_check does not exist.
// If you removed readiness and try out this sample, you will see, this deployment start and ready.

import ballerina/http;
service /hello on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello, World!"); 
    }
    resource function get liveness_check(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("pong"); 
    }
    resource function get readiness_check(http:Caller caller, http:Request req) returns @tainted error? {
        http:Client clientEndpoint = check new ("http://localhost:9091");
        any response = check clientEndpoint->get("/backend/health_check");
        check caller->respond("pong"); 
    }
}