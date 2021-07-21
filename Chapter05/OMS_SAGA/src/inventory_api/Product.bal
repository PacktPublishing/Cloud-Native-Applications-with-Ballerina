type Product record {
    readonly string productId;
    string productName;
    float price;
    string supplierId;
};
type ProductTable table<Product> key(productId);