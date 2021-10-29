// Start with `bal run HelloWorld/`
import ballerina/http;

service /hello on new http:Listener(9091) {  
    resource function get greeting() returns error|string {  
        return "Hello, World!";  
    } 
} 