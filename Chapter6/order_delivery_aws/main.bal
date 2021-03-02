import ballerinax/awslambda;
//import ballerina/io;
import ballerina/email;
import ballerina/encoding;

type Order record{|
    readonly string orderId;
    string customerEmail;
    string inventoryEmail;
    string address;
|};
type OrderTable table<Order> key(orderId);

OrderTable orders = table [{
    orderId: "43234234",
    customerEmail: "customer@mail.com",
    inventoryEmail: "inventory@mail.com",
    address: "215, abc rd, New York"
}];

@awslambda:Function
public function sendDeliveryRequestMail(awslambda:Context ctx, json item) returns json|error {
    string orderId = <string> check item.req.orderId;
    string taskToken = <string> check item.taskToken;
    string encodedTaskToken = check encoding:encodeUriComponent(taskToken, "UTF-8");
    Order orderToSend = orders.get(orderId);
    string deliveryAddress = orderToSend.inventoryEmail;
    string mailToSend = string `New order received with ID ${orderToSend.orderId} to address ${orderToSend.address}
    Click following link to approve the delivery. 
    https://xxxx.execute-api.us-west-1.amazonaws.com/staging/confirmdeliveryrequest?orderId=${orderId}&taskToken=${encodedTaskToken}"`;
    check sendEmail(deliveryAddress, "Order confirmation", mailToSend);
    return { "status" : "success"};
}

@awslambda:Function
public function sendDeliveryConfirmMail(awslambda:Context ctx, json item) returns json|error {
    string orderId = <string> check item.orderId;
    Order orderToSend = orders.get(orderId);
    string customerAddress = orderToSend.customerEmail;
    string mailToSend = string `Your order with ID ${orderToSend.orderId} sent`;
    check sendEmail(customerAddress, "Order delivered", mailToSend);
    return { "status" : "success"};
}

function sendEmail(string to, string subject, string body) returns error?{
        email:SmtpClient smtpClient = check new ("mailhost.com",
        "xxxx" , "xxxx");
    email:Message email = {
        to: [to],
        subject: subject,
        body: body,
        'from: "mymail@mail.com"
    };
    check smtpClient->sendEmailMessage(email);
}