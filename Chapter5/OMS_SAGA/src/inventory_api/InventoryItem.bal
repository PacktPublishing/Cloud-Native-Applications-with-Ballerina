type InventoryItem record {
    readonly string inventoryItemId;
    string inventoryId;
    string productId;
    int quantity;
};
type InventoryItemTable table<InventoryItem> key(inventoryItemId);