// This example is to demostrate service descovery with Consul
// Build this sample with `bal build --cloud=k8s consul_caller_service/` command.
// Execute `kustomize build consul_caller_service/ | kubectl apply -f -` command to deploy caller service.
// Execute `kubectl port-forward service/consul-server --namespace consul 8500:8500` for port forward consul ui.
// Now you can access consule ui with `http://localhost:8500/ui/` link
// Check list of deployment with `kubectl get deployments`
// Expose service as nodeport with `kubectl expose deployment <deployment_name> --type=NodePort` command
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <nodeport_service_name>` to get service endpoint
// Inovke the endpoint from browser. ex: http://127.0.0.1:53054/caller/greeting

import ballerina/http; // change base path and resource function name

service /caller on new http:Listener(9090) { // remove caller and return the value
    resource function get greeting() returns error|string { 
        http:Client clientEndpoint = check new ("http://consul-backend:9091");
        string payload = check clientEndpoint->get("/backend/greeting");
        return "Response from backend server: " + payload;
    }
}