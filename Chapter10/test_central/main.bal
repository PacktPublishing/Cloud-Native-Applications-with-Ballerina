// Run the program with `bal run use_ballerina_central/`
import ballerina/io;
import ballerina/time;
import dhanushka/invoice_util;

public function main() {
    table<invoice_util:Product> products = table [
        {productName: "SD card reader", quantity: 1, unitPrice: 20},
        {productName: "USB cable", quantity: 2, unitPrice: 1}
    ];
    time:Utc invoiceDate = time:utcNow();
    invoice_util:Invoice invoice = {customerName: "John", 
    customerAddress: "New York", 
    customerBillingAddress: "California", 
    customerMobileNumber: "0123456",
    discount: 0,
    productList: products,
    invoiceDate: invoiceDate};
    xml invoiceHTML = invoice_util:generateInvoice(invoice);
    io:println(invoiceHTML);
}
