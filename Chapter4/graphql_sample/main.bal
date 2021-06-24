// Build with `bal run graphql_sample/` command
// Test with following curl command
// curl -XPOST -H "Content-type: application/json" -d '{ "query": " { inventory(inventoryId: \"53542364\") { name, inventoryItems{quantity}} }" }' 'http://localhost:9090/graphql'
import ballerina/graphql;
import ballerina/http;
http:Listener httpListener = check new(9090);
service graphql:Service /graphql on new graphql:Listener(httpListener) {
    resource function get inventory(string inventoryId) returns Inventory|error {
        Inventory[] item = inventory.filter(function (Inventory value) returns boolean {
            if value.inventoryId == inventoryId {
                return true;
            } else {
                return false;
            }
        });
        if item.length() > 0{
            return item[0];
        } else {
            return error("No matching id found");
        }
    }
}
public type Inventory record {
    string inventoryId;
    string name;
    InventoryItem[] inventoryItems;
};
public type InventoryItem record {
    *Product;
    string inventoryItemId;
    int quantity;
};
public type Product record {
    string productId;
    string name;
    float price;

};
Inventory[] inventory = [{
    name: "Tom's wears",
    inventoryId: "25234234",
    inventoryItems: [{
        productId: "5434323",
        name: "T-shirt",
        price: 20,
        inventoryItemId: "3423909340",
        quantity: 120
    }]
},{
    name: "My Choice",
    inventoryId: "53542364",
    inventoryItems: [{
        productId: "6434432",
        name: "Shirt",
        price: 25,
        inventoryItemId: "3423654323",
        quantity: 50
    }]
}];