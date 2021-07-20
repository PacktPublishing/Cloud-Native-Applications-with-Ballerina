// This sample demostrate merging two YAML files with Kustomize tool.
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build the sample with `bal build --cloud=k8s kustomize_sample/`
// Execute `kustomize build kustomize_sample/`.
// This will output the updated Kubernetes artifacts
import ballerina/http;
service /hello on new http:Listener(9090) { 
    resource function get sayHello(http:Caller caller, http:Request req) returns error? { 
        check caller->respond("Hello World!"); 
    }
}