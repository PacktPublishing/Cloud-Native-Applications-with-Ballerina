// This example demostrate resolving backend with DNS resolving.
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build example with `bal build --cloud=k8s dns_caller_service/` command.
// Deploy sample with `kubectl apply -f <project_home>/target/kubernetes/dns_caller_service` command.
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <service_name>` to get service endpoint
// Inovke the endpoint from browser. ex: http://127.0.0.1:55352/caller/sayHello

import ballerina/http;

service /caller on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns @tainted error? { 
        http:Client clientEndpoint = check new ("http://backend-service.default.svc.cluster.local:9091");
        string payload = check clientEndpoint->get("/backend/sayHello");
        check caller->respond("Response from backend server: " + payload); 
    }
}