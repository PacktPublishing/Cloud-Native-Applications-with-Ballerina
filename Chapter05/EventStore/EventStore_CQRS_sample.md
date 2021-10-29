We will use previously created Customer/Inventory/InventoryItem records from the oms_server example
Start RabbitMQ service
Start the Order service with `bal run order_api/`
Start the Order Command handler with `bal run order_command_handler/`
Add new order with the following curl
curl -X POST  http://localhost:9090/OrderAPI/addNewOrder  -d '{"shippingAddress": "225, Rose St, New York", "customerId": "<customer_id>"}'
Add product to order with the following curl
curl -X POST  http://localhost:9090/OrderAPI/addProductToOrder  -d '{"entityId": "<entity_id>", "inventoryItemId": "<inventory_item_id>", "quantity":10}'
Generate snapshot with the following curl
curl -X GET  http://localhost:9090/OrderAPI/generateSnapshot/2029-03-28+10%3A23%3A42
