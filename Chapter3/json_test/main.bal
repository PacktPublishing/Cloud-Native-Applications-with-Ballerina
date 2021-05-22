// This example demostrate the JSON manipulation capabilities of Ballerina
// Execute this sample with the `bal run json_test/` command

import ballerina/io;

type ShippingAddress record {|
    string street;
    string city;
    string country;
|};

type Customer record {|
    string name;
    int age;
    ShippingAddress shippingAddress;
|};

public function main() returns error?{
    json customer = {
        name: "Tom",
        age: 26,
        shippingAddress: {
            street: "2307  Oak Street, Old Forge",
            city: "New York",
            country: "USA"
        }
    };
    map<json> customerMap = <map<json>> customer;
    io:println("Customer name is " + customerMap["name"].toString());
    json customerName =  check customer.name;
    io:println("Customer name is " + customerName.toString());

    json customerData1 = {name: "Tom"};
    json customerData2 = {age: 26, shippingAddress: "1st Lane, New York"};
    json customerData = checkpanic customerData1.mergeJson(customerData2);
    io:println(customerData.toJsonString());

    Customer customerRecord = check customer.cloneWithType(Customer);
    io:println("Customer name is " + customerRecord.name);
}
