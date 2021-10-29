import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/io;
import ballerina/uuid;

string dbUser = "root";
string dbPassword = "root";
string jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";
public class InventoryRepository {
    jdbc:Client jdbcClient;
    public function init() returns error?{
        io:println("Initializing Inventory Repository");
        jdbc:Client|sql:Error tempClient = new (jdbcUrl, dbUser, dbPassword);
        if tempClient is jdbc:Client {
            self.jdbcClient = tempClient;
        } else {
            return error("Error while initializing client", tempClient);
        }
    }
    public function getInventoryItemTableByinventoryId(int inventoryId) returns @untainted InventoryItemTable|error {
        stream<record{}, error> resultStream = self.jdbcClient->query(`SELECT * FROM InventoryItems WHERE InventoryId=${inventoryId}`, InventoryItem);
        stream<InventoryItem, sql:Error> inventoryStream = <stream<InventoryItem, sql:Error>>resultStream;
        InventoryItemTable inventoryItemTable = table [];
        error? e = inventoryStream.forEach(function(InventoryItem product) {
            inventoryItemTable.put(product);
        });
        if (e is error) {
            return error("Error while reading data", e);
        }
        return inventoryItemTable;
    }
    public function getAvailableProductQuantity(string inventoryItemId) returns @untainted int|error {
        stream<record{}, error> resultStream = self.jdbcClient->query(`SELECT Quantity FROM InventoryItems WHERE 
        InventoryItemId = ${inventoryItemId}`);
        record {|record {} value;|}? result = check resultStream.next();
        if (result is record {|record {} value;|}) {
            return <int>result.value["Quantity"];
        }
        return error("Inventory table is empty");
    }
    public function reserveOrderItems(json orderItems) returns error?{
        json[] orderItemList = <json[]>orderItems;
        foreach json item in orderItemList {
            string orderId = <string> check item.orderId;
            string inventoryItemId = <string> check item.inventoryItemId;
            int quantity = <int> check item.quantity;
            sql:ExecutionResult result = check self.jdbcClient->execute(`UPDATE InventoryItems SET Quantity = Quantity - ${quantity} WHERE 
            InventoryItemId = ${inventoryItemId}`);
            string pendingOrderId = uuid:createType1AsString();
            result = check self.jdbcClient->execute(`INSERT INTO PendingOrderItems(PendingOrderItemId, OrderId, InventoryItemId, Quantity) VALUES 
            (${pendingOrderId}, ${orderId}, ${inventoryItemId}, ${quantity})`);
        }
        return;
    }

}