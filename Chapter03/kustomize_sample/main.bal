// This sample demostrate merging two YAML files with Kustomize tool.
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build the sample with `bal build --cloud=k8s kustomize_sample/`
// Execute `kustomize build kustomize_sample/`.
// This will output the updated Kubernetes artifacts
import ballerina/http;
service /hello on new http:Listener(9090) { // change base path and resource function name
    resource function get greeting() returns error|string { 
        return "Hello World!"; 
    }
}