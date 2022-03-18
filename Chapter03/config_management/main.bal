// This sample to demostrate how to handle configs in Kubernetes
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build the project with `bal build --cloud=k8s config_management/`
// Execute `kubectl apply -f <project_home>/target/kubernetes/config_management`
// Check list of deployment with `kubectl get deployments`
// Expose service as nodeport with `kubectl expose deployment <deployment_name> --type=NodePort` command
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <nodeport_service_name>` to get service endpoint
// Inovke the endpoint with curl command. ex: curl -X GET http://127.0.0.1:53054/hello/config

import ballerina/http;

configurable string key1 = "abc";
service /hello on new http:Listener(9090) { 
    resource function get config() returns error|string {
        return key1; 
    }
}