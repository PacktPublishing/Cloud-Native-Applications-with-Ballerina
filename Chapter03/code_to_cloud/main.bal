// ----Docker sample-------
// build this sample with `bal build --cloud=docker code_to_cloud/` command
// Execute with `docker run -d -p 9090:9090 -it dhanushka/code_to_cloud:v0.1.0`
// Test the endpoint with `curl -X GET http://localhost:9090/hello/greeting`

// ----Kubernetes sample---
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build this sample with `bal build --cloud=k8s code_to_cloud/` command
// Execute with `kubectl apply -f <project_home>/target/kubernetes/code_to_cloud`.
// Replace `<project_home>` with the project home location
// Execute `kubectl get pods` to get list of pods
// Check list of deployment with `kubectl get deployments`
// Expose service as nodeport with `kubectl expose deployment <deployment_name> --type=NodePort` command
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <nodeport_service_name>` to get service endpoint
// Inovke the endpoint with `curl -X GET http://127.0.0.1:53054/hello/greeting`
import ballerina/http;
service /hello on new http:Listener(9090) { 
    resource function get greeting() returns error|string {
        return "Hello, World!"; 
    }
}