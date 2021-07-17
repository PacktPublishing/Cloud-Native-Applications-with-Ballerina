import ballerina/time;
public type Invoice record {
    string customerName;
    string customerAddress;
    string customerBillingAddress;
    string customerMobileNumber;
    time:Utc invoiceDate;
    float discount;
    table<Product> productList;
};