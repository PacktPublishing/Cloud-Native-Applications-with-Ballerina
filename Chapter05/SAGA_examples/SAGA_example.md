We will use previously created Customer/Inventory/InventoryItem records from the oms_server example
Start RabbitMQ service
Start the Order service with `bal run order_api/`
Start the Order handler with `bal run order_handler/`
Start the Orchestrator with `bal run orchestrator_handler/`
Start Inventory handler with `bal run inventory_handler/`
Add new order with the following curl
curl -X POST  http://localhost:9090/OrderAPI/order  -d '{"shippingAddress": "225, Rose St, New York", "customerId": "<customer_id>"}'
Add product to order with the following curl
curl -X POST  http://localhost:9090/OrderAPI/addProductToOrder  -d '{"orderId": "<orderId>", "inventoryItemId": "<inventory_item_id>", "quantity":10}'
Add item to a product with the following curl
curl -X GET  http://localhost:9090/OrderAPI/validateOrder/<order_id>

