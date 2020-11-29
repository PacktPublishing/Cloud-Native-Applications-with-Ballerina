import ballerina/io;

class User { 
    private string firstName; 
    private string lastName; 
    private string address; 
    public function init(string firstName, string lastName, string address) { 
        self.firstName = firstName; 
        self.lastName = lastName; 
        self.address = address; 
    } 
    public function getUserDetails() returns string { 
         return string `${self.firstName} ${self.lastName} from ${self.address}`; 
    } 
} 
public function main() {
    User user = new("Sherlock", "Holmes", "221b Baker St, Marylebone, London"); 
    io:println(user.getUserDetails());
}
