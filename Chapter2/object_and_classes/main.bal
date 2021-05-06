import ballerina/io;

type User object {
    string firstName;
    string lastName;
    public function getUserDetails() returns string;
};
class Customer {
    *User;
    string shippingAddress;
    public function init(string firstName, string lastName, string shippingAddress) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.shippingAddress = shippingAddress;
    }
    public function getUserDetails() returns string {
            return string  `${self.firstName} customer from ${self.shippingAddress}`;
    }
}
class Supplier {
    *User;
    string inventoryAddress;
    public function init(string firstName, string lastName, string inventoryAddress) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.inventoryAddress = inventoryAddress;
    }
    public function getUserDetails() returns string {
            return string  `${self.firstName} supplier from ${self.inventoryAddress}`;
    }
}
public function main() returns error? {
    User customer = new Customer("Sherlock", "Holmes", "221b Baker St, Marylebone, London");
    User supplier = new Supplier("Tom", "Cruise", "Syracuse, New York");
    io:println(customer.getUserDetails());
    io:println(supplier.getUserDetails());
}
