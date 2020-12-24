import ballerina/io;
import ballerina/time;

public function main() {
    table<Product> products = table [
            {productName: "SD card reader", quantity: 1, unitPrice: 20},
            {productName: "USB cable", quantity: 2, unitPrice: 1}
        ];
    time:Time invoiceDate = time:currentTime();
    time:Time|error invoiceDateResult = time:createTime(2017, 3, 28, 23, 42, 45, 554, "America/Panama");
    if(invoiceDateResult is time:Time) {
        invoiceDate = invoiceDateResult;
    }
    Invoice invoce = {customerName: "John", 
    customerAddress: "New York", 
    customerBillingAddress: "California", 
    customerMobileNumber: "0123456",
    discount: 0,
    productList: products,
    invoiceDate: invoiceDate};
    xml invoceHTML = generateInvoice(invoce);
    io:println(invoceHTML);
}
