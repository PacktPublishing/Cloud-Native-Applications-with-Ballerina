// This is an example backend implementation that we will used with other samples.
// Use `eval $(minikube docker-env)` to change to minikube environment
// You can build this backend with `bal build --cloud=k8s backend_service/` command.
// Deploy the backend service with `kubectl apply -f <project_home>/target/kubernetes/backend_service` command.
// Go to the env_caller_service and dns_caller_service examples and follow instructions.
import ballerina/http;
service /backend on new http:Listener(9091) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello from backend server!"); 
    }
}