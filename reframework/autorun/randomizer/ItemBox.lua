local ItemBox = {}


function ItemBox.GetAnyAvailable()
	callCurentChapter = Scene.getGameManager():call("get_CurrentChapter()")
	if callCurentChapter <= 4 then
		return false
	else
		return true
	end
end

-- function ItemBox.GetAnyAvailable()
--     --local scene = Scene.getSceneObject()
--     local gimmick_objects = scene:call("findComponents", sdk.typeof(sdk.game_namespace("InteractSendFsm")))
   
--     for k, comp in pairs(gimmick_objects) do
--         local gimmick = comp:call("get_GameObject()")
--         local gimmickName = gimmick:call("get_Name()")

--         -- if the gimmick contains "ItemLocker" and contains "_control", it's an item box
--         -- not checking if it *starts* with "ItemLocker" because Capcom likes to add crap to the beginning of the names (looking at you RE3R)
--         -- (also, Lua is a terrible language with no modern features)
--         if string.find(gimmickName, "ItemBox") then
--             return gimmick
--         end
--     end

--     return nil
-- 

function ItemBox.AddItem(itemId, count)
	-- log.debug(tostring(itemId))
	-- log.debug(count)
	local itemBoxData = Inventory.GetInventory():get_field("<ItemBoxData>k__BackingField")
	itemBoxData:call("addItem(System.String, System.Int32, app.WeaponGun.WeaponGunSaveData)", itemId, count, nil)
    return
end

return ItemBox
