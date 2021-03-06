// This example demostrate how to use evironement variable to discover backend service
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build this sample with `bal build --cloud=k8s env_caller_service/` command
// Execute with `kubectl apply -f <project_home>/target/kubernetes/env_caller_service`
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <service_name>` to get service endpoint
// Inovke the endpoint with `curl -X GET http://127.0.0.1:53054/caller/sayHello`

import ballerina/http;
import ballerina/os;

const BACKEND_SERVICE_SERVICE_HOST = "BACKEND_SERVICE_SERVICE_HOST";
const BACKEND_SERVICE_SERVICE_PORT = "BACKEND_SERVICE_SERVICE_PORT";

service /caller on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        string backendServiceHost = os:getEnv(BACKEND_SERVICE_SERVICE_HOST);
        string backendServicePort = os:getEnv(BACKEND_SERVICE_SERVICE_PORT);
        http:Client clientEndpoint = check new ("http://" + backendServiceHost + ":" + backendServicePort);
        string payload = check clientEndpoint->get("/backend/sayHello");
        check caller->respond("Response from backend server: " +  payload);
    }
}