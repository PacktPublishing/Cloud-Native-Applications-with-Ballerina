import ballerina/io;

public type Product record {
    string productName;
    int quantity;
    int unitPrice;
};
public function main() {
    table<Product> products = table [
            {productName: "SD card reader", quantity: 1, unitPrice: 20},
            {productName: "USB cable", quantity: 2, unitPrice: 1}
    ];
    float totalPrice = 0;
    foreach Product product in products {
        totalPrice =  totalPrice + <float>product.quantity * product.unitPrice;
    }
    io:println("Total price is: " + totalPrice.toString());
}
