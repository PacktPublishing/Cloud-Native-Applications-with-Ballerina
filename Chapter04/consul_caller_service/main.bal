// This example is to demostrate service descovery with Consul
// Build this sample with `bal build --cloud=k8s consul_caller_service/` command.
// Execute `kustomize build consul_caller_service/ | kubectl apply -f -` command to deploy caller service.
// Execute `minikube service hashicorp-consul-ui` to access the Consul UI and list caller service and backend service.
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <service_name>` to get service endpoint
// Inovke the endpoint from browser. ex: http://127.0.0.1:53054/caller/greeting

import ballerina/http; // change base path and resource function name

service /caller on new http:Listener(9090) { // remove caller and return the value
    resource function get greeting() returns error|string { 
        http:Client clientEndpoint = check new ("http://consul-backend:9091");
        string payload = check clientEndpoint->get("/backend/greeting");
        return "Response from backend server: " + payload;
    }
}