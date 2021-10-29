// Start the service with `bal run oms_server/`
// Add new customer with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addCustomer  -d '{"firstName": "Tim", "lastName": "Wilson", "shippingAddress": "New York", "billingAddress": "New York", "email": "tim@mail.com", "country": "USA"}'
// Add new order with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addNewOrder  -d '{"shippingAddress": "225, Rose St, New York", "customerId": "<customer_id>"}'
// Add new supplier with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addSupplier  -d '{"supplierName": "ABC textiles"}'
// Add new product with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addProduct  -d '{"productName": "T shirt", "supplierId": "<supplier_id>", "price":50}'
// Add new inventry with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addInventory  -d '{"inventryName": "ABC invetries", "supplierId": "<supplier_id>"}'
// Add product to InventoryItem with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addProductToInventory  -d '{"inventoryId": "<inventory_id>", "productId": "<product_id>", "quantity":100}'
// Add product to order with the following curl
// curl -X POST  http://localhost:9090/OrderAPI/addProductToOrder  -d '{"orderId": "<orderId>", "inventoryItemId": "<inventory_item_id>", "quantity":10}'
// Add item to a product with the following curl
// curl -X GET  http://localhost:9090/OrderAPI/validateOrder/<order_id>

import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/java.jdbc;
import ballerina/sql;

const dbUser = "root";
const dbPassword = "root";
const jdbcUrl = "jdbc:mysql://localhost:3306/OMS_BALLERINA";

service /OrderAPI  on new http:Listener(9090) { 
    resource function post addNewOrder(@http:Payload json orderDetails) returns json|http:InternalServerError { 
        do {
            json shippingAddress = check orderDetails.shippingAddress;
            json customerId = check orderDetails.customerId;
            string orderId = check createOrder(shippingAddress.toString(), customerId.toString());
            json response = {
                code: 200,
                orderId: orderId
            };
            return response;
        } on fail error e{
            log:printError("Error while adding order", e);
            http:InternalServerError internalError = {};
            return internalError;
        }
    }
    resource function post customer(http:Caller caller, http:Request req, @http:Payload json customerDetails) returns error? { 
        json firstName = check customerDetails.firstName;
        json lastName = check customerDetails.lastName;
        json shippingAddress = check customerDetails.shippingAddress;
        json billingAddress = check customerDetails.billingAddress;
        json email = check customerDetails.email;
        json country = check customerDetails.country;

        string customerId = check addCustomer(firstName.toString(), lastName.toString(), shippingAddress.toString(), 
                billingAddress.toString(), email.toString(), country.toString());
        check caller->respond({
            code:200,
            customerId: customerId
        });
    }
    resource function post product(http:Caller caller, http:Request req, @http:Payload json productDetails) returns error? { 
        json productName = check productDetails.productName;
        json supplierId = check productDetails.supplierId;
        json price = check productDetails.price;
        string productId = check addProduct(productName.toString(), supplierId.toString(),  <float>price);
        check caller->respond({
            code:200,
            productId: productId
        });
    }
    
    resource function post supplier(http:Caller caller, http:Request req, @http:Payload json supplierDetails) returns error? { 
        json supplierName = check supplierDetails.supplierName;
        string supplierId = check addSupplier(supplierName.toString());
        check caller->respond({
            code:200,
            supplierId: supplierId
        });
    }

    resource function post inventory(@http:Payload json inventoryDetails) returns error|json { // change as this
        json inventryName = check inventoryDetails.inventryName;
        json supplierId = check inventoryDetails.supplierId;
        string inventoryId = check addInventory(inventryName.toString(), supplierId.toString());
        return {
            code:200,
            inventoryId: inventoryId
        };
    }
    
    resource function post addProductToInventory(http:Caller caller, http:Request req, @http:Payload json inventoryItemDetails) returns error? { 
        json inventoryId = check inventoryItemDetails.inventoryId;
        json productId = check inventoryItemDetails.productId;
        json quantity = check inventoryItemDetails.quantity;
        string inventoryItemId = check addProductToInventory(inventoryId.toString(), productId.toString(), <int>quantity);
        check caller->respond({
            code:200,
            inventoryItemId: inventoryItemId
        });
    } 
    
    resource function post addProductToOrder(http:Caller caller, http:Request req, @http:Payload json productDetails) returns error? { 
        json orderId = check productDetails.orderId;
        json inventoryItemId = check productDetails.inventoryItemId;
        json quantity = check productDetails.quantity;
        string orderItemId = check addProductToOrder(orderId.toString(), inventoryItemId.toString(), <int>quantity);
        check caller->respond({
            code:200,
            orderItemId: orderItemId
        });
    } 

    resource function get validateOrder/[string orderId](http:Caller caller, http:Request req) returns error? { 
        boolean status = check validateOrder(orderId);
        check caller->respond({
            code:200,
            verificationStatus: status
        });
    } 
    
}

function responseError500(http:Caller caller) returns error?{
    http:Response res = new;
    res.statusCode = 500;
    check caller->respond(res);
}

function validateOrder(string orderId) returns error|boolean{
    OrderItemTable orderItems = check getOrderItemTableByOrderId(orderId);
    boolean validOrder = true;
    foreach OrderItem item in orderItems {
        int orderQuantity = item.quantity;
        int inventoryQuantity = check getAvailableProductQuantity(item.inventoryItemId);
        if orderQuantity > inventoryQuantity {
            validOrder = false;
            break;
        }
    }
    if validOrder {
        check reserveOrderItems(orderItems);
        check setOrderStatus(orderId, "Verified");
        log:printInfo("Order validation successfull");
        return true;
    } else {
        check setOrderStatus(orderId, "VerificationFailed");
        log:printInfo("Order validation failed");
        return false;
    }
}

public function reserveOrderItems(OrderItemTable orderItems) returns error?{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    foreach OrderItem item in orderItems {
        string inventoryItemId = item.inventoryItemId;
        int quantity = item.quantity;
        sql:ExecutionResult result = check jdbcClient->execute(`UPDATE InventoryItems SET Quantity = Quantity - ${quantity} WHERE 
        InventoryItemId = ${inventoryItemId}`);
        string pendingOrderId = uuid:createType1AsString();
        result = check jdbcClient->execute(`INSERT INTO PendingOrderItems(PendingOrderItemId, OrderId, InventoryItemId, Quantity) VALUES 
        (${pendingOrderId}, ${item.orderId}, ${inventoryItemId}, ${quantity})`);
    }
    check jdbcClient.close();
    return;
}

function setOrderStatus(string orderId, string status) returns error? {
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    sql:ParameterizedQuery updateOrder = `UPDATE Orders SET Status = ${status} WHERE OrderId = ${orderId}`; 
    sql:ExecutionResult result = check jdbcClient->execute(updateOrder);
    check jdbcClient.close();
}

function createOrder(string shippingAddress, string customerId) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string orderId = uuid:createType1AsString();
    sql:ParameterizedQuery createOrder = `INSERT INTO OMS_BALLERINA.Orders( 
        OrderId, ShippingAddress, CustomerId, Status)  
        VALUES(${orderId}, ${shippingAddress}, ${customerId}, 'Created')`; 
    sql:ExecutionResult result = check jdbcClient->execute(createOrder); 
    check jdbcClient.close();
    return orderId;
}

function addProduct(string productName, string supplierId, float price) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string productId = uuid:createType1AsString();
    sql:ParameterizedQuery createProduct = `INSERT INTO OMS_BALLERINA.Products( 
        ProductId, ProductName, Price, SupplierId)  
        VALUES(${productId}, ${productName}, ${price}, ${supplierId})`; 
    sql:ExecutionResult result = check jdbcClient->execute(createProduct); 
    check jdbcClient.close();
    return productId;
}

function addSupplier(string supplierName) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string supplierId = uuid:createType1AsString();
    sql:ParameterizedQuery createProduct = `INSERT INTO OMS_BALLERINA.Suppliers( 
        SupplierId, SupplierName)  
        VALUES(${supplierId}, ${supplierName})`; 
    sql:ExecutionResult result = check jdbcClient->execute(createProduct); 
    check jdbcClient.close();
    return supplierId;
}

function addInventory(string inventryName, string supplierId) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string InventryId = uuid:createType1AsString();
    sql:ParameterizedQuery createProduct = `INSERT INTO OMS_BALLERINA.Inventories( 
        InventoryId, Name, SupplierId)  
        VALUES(${InventryId}, ${inventryName}, ${supplierId})`; 
    sql:ExecutionResult result = check jdbcClient->execute(createProduct); 
    check jdbcClient.close();
    return InventryId;
}

function addCustomer(string firstName, string lastName, string shippingAddress, 
                string billingAddress, string email, string country) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string customerId = uuid:createType1AsString();
    sql:ParameterizedQuery createProduct = `INSERT INTO OMS_BALLERINA.Customers( 
        CustomerId, FirstName, LastName, ShippingAddress, BillingAddress, Email, Country)  
        VALUES(${customerId}, ${firstName}, ${lastName}, ${shippingAddress}, ${billingAddress}, 
            ${email}, ${country})`; 
    sql:ExecutionResult result = check jdbcClient->execute(createProduct); 
    check jdbcClient.close();
    return customerId;
}

function addProductToInventory(string inventoryId, string productId, int quantity) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string inventoryItemId = uuid:createType1AsString();
        sql:ParameterizedQuery addProduct = `INSERT INTO OMS_BALLERINA.InventoryItems( 
        InventoryItemId, InventoryId, ProductId, Quantity)  
        VALUES(${inventoryItemId}, ${inventoryId},${productId}, ${quantity})`; 
    sql:ExecutionResult result = check jdbcClient->execute(addProduct); 
    check jdbcClient.close();
    return inventoryItemId;
}

function addProductToOrder(string orderId, string inventoryItemId, int quantity) returns error|string{
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    string orderItemId = uuid:createType1AsString();
        sql:ParameterizedQuery addProduct = `INSERT INTO OMS_BALLERINA.OrderItems( 
        OrderItemId, OrderId, Quantity, InventoryItemId)  
        VALUES(${orderItemId}, ${orderId}, ${quantity}, ${inventoryItemId})`; 
    sql:ExecutionResult result = check jdbcClient->execute(addProduct); 
    check jdbcClient.close();
    return orderItemId;
}

public function getOrderItemTableByOrderId(string orderId) returns OrderItemTable|error {
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT * FROM OrderItems WHERE OrderId=${orderId}`, OrderItem);
    stream<OrderItem, sql:Error> orderItemStream = <stream<OrderItem, sql:Error>>resultStream;
    OrderItemTable orderItemTable = table [];
    error? e = orderItemStream.forEach(function(OrderItem orderItem) {
        orderItemTable.put(orderItem);
    });
    check jdbcClient.close();
    return orderItemTable;
}

function getAvailableProductQuantity(string inventoryItemId) returns int|error {
    jdbc:Client jdbcClient = check new (jdbcUrl, dbUser, dbPassword);
    stream<record{}, error> resultStream = jdbcClient->query(`SELECT Quantity FROM InventoryItems WHERE 
    InventoryItemId = ${inventoryItemId}`);
    record {|record {} value;|}? result = check resultStream.next();
    if (result is record {|record {} value;|}) {
        return <int>result.value["Quantity"];
    }
    check jdbcClient.close();
    return error("Inventory table is empty");
}