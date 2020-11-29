import ballerina/io;

# Prints `Hello World`.

public function main() returns error?{
    io:println("Hello World!");
    InventoryRepository inventoryRepository = check new();
}
