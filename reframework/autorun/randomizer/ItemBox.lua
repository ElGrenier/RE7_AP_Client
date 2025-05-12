local ItemBox = {}

function ItemBox.GetAnyAvailable()
    --local scene = Scene.getSceneObject()
    local gimmick_objects = scene:call("findComponents", sdk.typeof(sdk.game_namespace("InteractSendFsm")))
   
    for k, comp in pairs(gimmick_objects) do
        local gimmick = comp:call("get_GameObject()")
        local gimmickName = gimmick:call("get_Name()")

        -- if the gimmick contains "ItemLocker" and contains "_control", it's an item box
        -- not checking if it *starts* with "ItemLocker" because Capcom likes to add crap to the beginning of the names (looking at you RE3R)
        -- (also, Lua is a terrible language with no modern features)
        if string.find(gimmickName, "ItemBox") then
            return gimmick

            -- local compGimmickControl = gimmick:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.GimmickControl")))

            -- -- now, check if the item box has a map assigned and that map is active
            -- if compGimmickControl ~= nil and compGimmickControl:get_field("_IsPairComplete") then
            --     return gimmick
            -- end
        end
    end

    return nil
end

-- function ItemBox.GetItems()
--     itemLocker = ItemBox.GetAnyAvailable()
--     itemList = {}

--     -- check that the item box we got is actually available first
--     if itemLocker ~= nil then
--         gimmickItemLockerControlComponent = itemLocker:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.GimmickItemLockerControl")))
--         storageItems = gimmickItemLockerControlComponent:get_field("StorageItems")
--         mItems = storageItems:get_field("mItems")
--         foundOpenSlot = false

--         for i, item in pairs(mItems) do
--             defaultItem = item:get_field("DefaultItem")
--             -- ItemId, WeaponId, WeaponParts, BulletId, Count

--             itemId = defaultItem:get_field("ItemId")
--             weaponId = defaultItem:get_field("WeaponId")

--             -- if we found an empty slot, the item list is complete
--             if itemId <= 0 and weaponId <= 0 then
--                 return itemList
--             end

--             table.insert(itemList, defaultItem)
--         end
--     end

--     return itemList
-- end

local function get_localplayer()
	local object_man = sdk.get_managed_singleton("app.ObjectManager")

	if not object_man then
		return nil
	end

	return object_man:get_field("PlayerObj")
end

local known_typeofs = {}
local function get_component(game_object, type_name)
	local t = known_typeofs[type_name] or sdk.typeof(type_name)

	if t == nil then
		return nil
	end

	known_typeofs[type_name] = t
	return game_object:call("getComponent(System.Type)", t)
end



function ItemBox.AddItem(itemId, count)
	local inventory = get_component(get_localplayer(), "app.Inventory") or re.msg("Inventory nil")
	local itemBoxData = inventory:get_field("<ItemBoxData>k__BackingField")
	
	local signature = "addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)"
	itemBoxData:call(signature, itemId, count, nil)
    return
    -- local itemLocker = ItemBox.GetAnyAvailable()

    -- if itemLocker ~= nil then
    --     local gimmickItemLockerControlComponent = itemLocker:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.GimmickItemLockerControl")))
    --     local storageItems = gimmickItemLockerControlComponent:get_field("StorageItems")
    --     local mItems = storageItems:get_field("mItems")

    --     for i, item in pairs(mItems:get_elements()) do
    --         local slotItemId = item:get_ItemId()
    --         local slotWeaponId = item:get_WeaponId()

    --         if slotItemId <= 0 and slotWeaponId <= 0 then
    --             if weaponId > 0 then
    --                 item:setWeapon(weaponId, 0, count, tonumber(bulletId), 0)
    --             else
    --                 item:set_ItemId(itemId)
    --                 item:set_Count(count) -- love the consistency with player inv
    --             end

    --             return
    --         end            
    --     end
    -- end
end

return ItemBox
