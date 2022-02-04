// ----Ballerina object sample-------
// Run this sample with `bal run object_sample/` command

import ballerina/io;

type User object { 
    string firstName; 
    string lastName; 
    string address; 
    public function getUserDetails() returns string; 
};


public function main() returns error? { 
    User user = object User {
      public function init() { 
            self.firstName = "Sherlock"; 
            self.lastName = "Holmes"; 
            self.address = "221b Baker St, Marylebone, London"; 
      }   

      public function getUserDetails() returns string{
            return string  `${self.firstName} ${self.lastName} from ${self.address}`;
        }
    };
    io:println(user.getUserDetails()); 
}
