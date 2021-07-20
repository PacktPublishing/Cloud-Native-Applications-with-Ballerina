// This example is to demonstrate resource utilzation of the Ballerina Kubernetes deployment
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build the project with `bal build --cloud=k8s resource_utilization/` command
// Check the <project_home>/target/kubernetes/resource_utilization/resource_utilization.yaml file
import ballerina/http;

service /hello on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello, World!"); 
    }
}