// This sample demostrate the readiness and liveness check of the Kubernetes deployment.
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build with `bal build --cloud=k8s health_check/` command.
// Execute `kubectl apply -f <project_home>/target/kubernetes/health_check` command.
// Execute `kubectl get deployments`.
// Deployment list show this deployment does not ready since localhost:9091/backend/health_check does not exist.
// If you removed readiness and try out this sample, you will see, this deployment start and ready.

import ballerina/http;
service / on new http:Listener(9090) {
    resource function get sayHello() returns error|string { 
        return "Hello, World!"; 
    }
    resource function get liveness() returns error|string { 
        return "pong"; 
    }
    resource function get readiness() returns error|string {
        http:Client clientEndpoint = check new ("http://localhost:9091");
        string response = check clientEndpoint->get("/backend/health_check");
        return "pong"; 
    }
}