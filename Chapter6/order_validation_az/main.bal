import ballerinax/azure_functions as af;
import ballerina/email;
type Order record {|
    readonly string orderId;
    string customerEmail;
    float totalPrice;
|};
type OrderTable table<Order> key(orderId);
OrderTable orders = table [{
    orderId: "343232",
    customerEmail: "customer@mail.com",
    totalPrice: 50
}];

const maxCreditLimit = 300;
@af:Function
public function submitOrder(af:Context ctx, 
            @af:HTTPTrigger { authLevel: "anonymous" } af:HTTPRequest req, 
            @af:QueueOutput { queueName: "order-queue" } af:StringOutputBinding msg) 
            returns @af:HTTPOutput af:HTTPBinding {
    msg.value = req.query.get("orderId");
    return { statusCode: 200, payload: "Submited successfully" };
}

@af:Function
public function validateOrder(af:Context ctx, 
        @af:QueueTrigger { queueName: "order-queue" } string inMsg,
        @af:QueueOutput { queueName: "order-success-queue" } af:StringOutputBinding outSuccessMsg,
        @af:QueueOutput { queueName: "order-fail-queue" } af:StringOutputBinding outFailedMsg) {
            string inputMessage = inMsg.substring(1, inMsg.length() - 1);
            Order orderItem = orders.get(inputMessage);
            if (orderItem.totalPrice > maxCreditLimit) {
                outFailedMsg.value = inputMessage;
            } else {
                outSuccessMsg.value = inputMessage;
            }
}
@af:Function
public function validateOrderSuccess(af:Context ctx, 
        @af:QueueTrigger { queueName: "order-success-queue" } string inMsg) returns error?{
    ctx.log("In Message: " + inMsg);
    ctx.log("Metadata: " + ctx.metadata.toString());
    string inputMessage = inMsg.substring(1, inMsg.length() - 1);
    Order orderItem = orders.get(inputMessage);
    check sendEmail(orderItem.customerEmail, "Order validation success", "Order validation successful for order ID: " + orderItem.orderId);
}

@af:Function
public function validateOrderFail(af:Context ctx, 
        @af:QueueTrigger { queueName: "order-fail-queue" } string inMsg) returns error?{
    ctx.log("In Message: " + inMsg);
    ctx.log("Metadata: " + ctx.metadata.toString());
    string inputMessage = inMsg.substring(1, inMsg.length() - 1);
     Order orderItem = orders.get(inputMessage);
    check sendEmail(orderItem.customerEmail, "Order validation failed", "Order validation failed for the order ID: " + orderItem.orderId);
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