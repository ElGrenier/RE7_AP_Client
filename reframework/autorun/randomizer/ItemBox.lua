local ItemBox = {}


function ItemBox.GetAnyAvailable()
	return true
	-- local gameManager = Scene.getGameManager()
	-- local currentChapter = gameManager:call("get_CurrentChapter()")
	-- if currentChapter ~= 4 then
	-- 	return true
	-- else
	-- 	return nil
	-- end
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
end

return ItemBox
