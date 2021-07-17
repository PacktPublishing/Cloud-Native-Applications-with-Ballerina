import ballerina/test;
import ballerinax/java.jdbc;
import ballerina/http;
import ballerina/sql;

// mock getAvailableProductQuantity function
@test:Mock {
    functionName: "getAvailableProductQuantity"
}
test:MockFunction getAvailableProductQuantityMockFunc = new();
function mockGetAvailableProductQuantity(jdbc:Client jdbcClient, string inventoryItemId) returns int|error{
    return 1;
}

// mock jdbc object
public class MockjdbcClient {
    public function execute(string|sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|sql:Error{
        sql:ExecutionResult result = {
            affectedRowCount: 1,
            lastInsertId: 1
        };
        return result;
    }
}

jdbc:Client jdbcClient = check new ("jdbc:h2:file:./target/sample1");

@test:Mock { functionName: "getAvailableProductQuantity" }
test:MockFunction availableProductQuantityMockFn = new();

@test:Config {}
function testCheckValidOrder() {
    test:when(availableProductQuantityMockFn).thenReturn(20);
    OrderItem[] orderItem = [
        {orderItemId: "3234",
        orderId: "38403294",
        quantity: 10,
        inventoryItemId: "834209"}
    ];
    boolean|error status = checkValidOrder(jdbcClient, orderItem);
    if status is boolean {
        test:assertTrue(status, msg = "Cannot fulfil order");
    } else {
        test:assertFail(msg = "Error returned" + status.toString());
    }
}

@test:Config {}
function testCheckValidOrderIntegration() returns error?{
    http:Client clientEP = check new ("http://localhost:9090");
    http:Response|error response = clientEP->post("/post", "POST: Hello World");
    if (response is http:Response) {

    } else {
        test:assertFail(msg = "Error response");
    }
}