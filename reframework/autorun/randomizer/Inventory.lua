local Inventory = {}

function Inventory.GetInventoryManager()
    return sdk.get_managed_singleton(sdk.game_namespace("InventoryManager"))
end

function Inventory.GetInventoryClassObject()
    local inventoryManager = Inventory.GetInventoryManager()
    
    return inventoryManager:get_field("_Inventory")
end

function Inventory.GetSlotManagerClassObject()
    return Inventory.GetInventoryClassObject():get_field("<ItemSlotManager>k__BackingField")
end

function Inventory.GetNextAvailableSlot()
    log.debug('a')
    if not Inventory.HasSpaceForItem() then
        return nil
    end
    log.debug('b')
    local slotData = Inventory.GetSlotManagerClassObject():get_field("_SlotData")
    local itemSlots = slotData:get_field("_ItemSlots")
    log.debug('c')
    local mItems = itemSlots:get_field("mItems")

    log.debug('d')
    for k, v in pairs(mItems) do
        log.debug('e')
        if not v:get_field("_ItemParam") then -- return the first index that doesn't have an item
            return k
        end
        log.debug('f')
    end
end

function Inventory.GetMaxSlots()
    local slotData = Inventory.GetSlotManagerClassObject():get_field("_SlotData")
    local playerCurrentMaxSlots = slotData:get_field("_SlotNum")

    return playerCurrentMaxSlots
end

function Inventory.IncreaseMaxSlots(amount)
    local slotData = Inventory.GetSlotManagerClassObject():get_field("_SlotData")
    local playerCurrentMaxSlots = slotData:get_field("_SlotNum")
    
    slotData:call("set_SlotNum", playerCurrentMaxSlots + amount)
end

function Inventory.GetCurrentItems()
    log.debug('aaa')
    local inventoryClassObject = Inventory.GetInventoryClassObject()
    log.debug('aab')
    local itemList = inventoryClassObject:get_field("_ItemList")
    log.debug('aac')
    local mItems = itemList:get_field("mItems")
    log.debug('aad')
    local items = {}

    for i, item in pairs(mItems) do
        log.debug('aae')
        if item ~= nil then
            table.insert(items, item:get_field("Item"))
        end
    end

    log.debug('aaf')
    return items
end

function Inventory.HasSpaceForItem()
    log.debug('aa')
    local currentItems = Inventory.GetCurrentItems()
    log.debug('ab')
    
    -- unlike in RE2R, in RE7, the main character actually starts without items, so handle differently
    if #currentItems == 0 then
        return true
    end

    log.debug('ac')
    return #currentItems + 2 < Inventory.GetMaxSlots() -- leave a 2 slot padding for non-randomized pickups
end

function Inventory.HasItemId(item_id, weapon_id)
    local currentItems = Inventory.GetCurrentItems()

    for k, item in pairs(currentItems) do
        itemfield_id = item:get_field("ItemDataID")
        weaponfield = item:get_field("<weapon>k__BackingField")
        weaponfield_id = nil

        if weaponfield then
            weaponfield_id = weaponfield:get_field("WeaponID")
        end

        if itemfield_id == item_id or (weaponfield_id ~= nil and weaponfield_id == weapon_id) then
            return true
        end
    end

    return false
end

function Inventory.AddItem(itemId, weaponId, weaponParts, bulletId, count)
    log.debug("1")
    local itemSlotManager = Inventory.GetSlotManagerClassObject()    
    log.debug("2")
    local newItem = ValueType.new(sdk.find_type_definition(sdk.game_namespace("Item")))
    log.debug("3")
    local nextAvailableSlot = Inventory.GetNextAvailableSlot()
    log.debug("4")
    
    if weaponId ~= nil and weaponId > 0 then -- is a weapon
        -- todo, do
    else -- is an item
        log.debug("5")
        newItem:set_field("ItemDataID", itemId)
        newItem:set_field("ItemStackNum", count)
        log.debug("6")
        itemSlotManager:call("add(app.Item, System.Int32)", newItem, nextAvailableSlot) -- come back to this
        log.debug("7")
    end


    -- for k, itemComp in pairs(allItems) do
    --     if itemComp ~= nil then
    --         local itemDataId = itemComp:get_field("ItemDataID")

    --         if itemDataId ~= nil then
    --             log.debug("item data id: " .. tostring(itemDataId))
    --         end

    --         if weaponId ~= nil and weaponId > 0 and false then -- is a weapon, replace false with actual checking
    --             log.debug("foo")
    --         elseif itemId ~= nil and itemId == itemDataId then
    --             local itemGameObject = itemComp:call("get_GameObject")
    --             local itemGameObjectFolder = itemGameObject:call("get_Folder")
    --             local newGameObject = Helpers.gameObject("rrr_" .. itemId)
                
    --             if newGameObject == nil then
    --                 newGameObject = itemGameObject:call("create(System.String, via.Folder)", "rrr_" .. itemId, itemGameObjectFolder)
    --             end

    --             local newComp = newGameObject:call("createComponent(System.Type)", sdk.typeof(sdk.game_namespace("Item")))

    --             log.debug(tostring(newComp))
    --             log.debug(tostring(newGameObject))

    --             newComp:set_field("ItemDataID", itemId)
    --             newComp:set_field("ItemStackNum", count)

    --             inventoryClassObject:call("addItem(app.Item, via.GameObject)", newComp, newGameObject)
    --         end
    --     end
    -- end


    return false
end

function Inventory.SwapItem(fromItemIds, fromWeaponIds, itemId, weaponId, weaponParts, bulletId, count)
    -- local inventoryManager = Inventory.GetInventoryManager()
    -- local playerInventory = inventoryManager:get_CurrentInventory()
    -- local playerInventorySlots = playerInventory:get_field("_Slots")
    -- local playerCurrentMaxSlots = playerInventory:get_field("_CurrentSlotSize")
    -- local mItems = playerInventorySlots:get_field("mItems")
    -- local items = {}
    
    -- for i, item in pairs(mItems:get_elements()) do
    --     if item ~= nil then
    --         local slotItemId = item:call("get_ItemID()")
    --         local slotWeaponId = item:call("get_WeaponType()")
    --         local slotIndex = item:get_Index()

    --         if fromItemIds then
    --             for k, fromItemId in pairs(fromItemIds) do
    --                 if slotItemId == fromItemId then
    --                     if itemId > 0 then -- is an item
    --                         playerInventory:setSlot(slotIndex, itemId, count, 0, 0)
    --                     end
            
    --                     return true
    --                 end
    --             end
    --         end

    --         if fromWeaponIds then
    --             for k, fromWeaponId in pairs(fromWeaponIds) do
    --                 if slotWeaponId == fromWeaponId then
    --                     if weaponId > 0 then -- is a weapon
    --                         local set_slot_weapon_string = "setSlot(System.Int32, " .. sdk.game_namespace("EquipmentDefine.WeaponType") .. ", " .. sdk.game_namespace("EquipmentDefine.WeaponParts") .. ", " .. sdk.game_namespace("gamemastering.Item.ID") .. ", System.Int32, " .. sdk.game_namespace("gamemastering.InventoryManager.ItemExData") .. ")"
    --                         playerInventory:call(set_slot_weapon_string, slotIndex, weaponId, 0, tonumber(bulletId), count, 0)
    --                     end
            
    --                     return true
    --                 end
    --             end
    --         end
    --     end
    -- end

    return false
end

return Inventory
