// This example demostrate resolving backend with DNS resolving.
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build example with `bal build --cloud=k8s dns_caller_service/` command.
// Deploy sample with `kubectl apply -f <project_home>/target/kubernetes/dns_caller_service` command.
// Check list of deployment with `kubectl get deployments`
// Expose service as nodeport with `kubectl expose deployment <deployment_name> --type=NodePort` command
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <nodeport_service_name>` to get service endpoint
// Inovke the endpoint from browser. ex: http://127.0.0.1:55352/caller/greeting

import ballerina/http;

final http:Client clientEndpoint = check new ("http://backend-service.default.svc.cluster.local:9091");
service /caller on new http:Listener(9090) { 
    resource function get greeting() returns error|string { 
        string payload = check clientEndpoint->get("/backend/greeting");
        return "Response from backend server: " + payload; 
    }
}