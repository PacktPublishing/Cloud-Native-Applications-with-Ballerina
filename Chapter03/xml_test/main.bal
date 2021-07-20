// This sample demostrate how to manipulate XML content in Ballerina
// Execute the sample with `bal run xml_test/` command
import ballerina/io;

public function main() returns error?{
    xml orderItem1 = xml `<orderItem itemId="3244543">
        <quantity>12</quantity>
        <price>100</price>
    </orderItem>`;
    xml orderItem2 = xml `<orderItem itemId="988443">
        <quantity>10</quantity>
        <price>320</price>   
    </orderItem>`;

    xml orderItems = orderItem1 + orderItem2;
    xml orderDetail = xml `<order orderId="342345">
        <customerName customerId = "34254234">Tom</customerName>
        <shippingAddress>2307  Oak Street, Old Forge, New York, USA</shippingAddress>
        <orderItems>${orderItems}</orderItems>
    </order>`;

    io:println("Customer XML object " + orderDetail.toString());
    io:println("Customer Name " + (orderDetail/<customerName>).toString());
    string|error customerId = orderDetail/<customerName>.customerId;
    if customerId is string {
        io:println("Customer Id " + customerId);
    }
}
