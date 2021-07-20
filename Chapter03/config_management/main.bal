// This sample to demostrate how to handle configs in Kubernetes
// Use `eval $(minikube docker-env)` to change to minikube environment
// Build the project with `bal build --cloud=k8s config_management/`
// Execute `kubectl apply -f <project_home>/target/kubernetes/config_management`
// Execute `kubectl get services` to get list of services
// Execute `minikube service --url <service_name>` to get service endpoint
// Inovke the endpoint from browser. ex: http://127.0.0.1:53054/hello/readConfig

import ballerina/http;
import ballerina/io;

service /hello on new http:Listener(9090) { 
    resource function get readConfig(http:Caller caller, http:Request req) returns error? {
        string readContent = check io:fileReadString("/home/conf/init.conf");
        check caller->respond(readContent); 
    }
}