local Items = {}
Items.isInit = false -- keeps track of whether init things like hook need to run
Items.lastInteractable = nil
Items.cancelNextUI = false

function Items.Init()
    if not Items.isInit then
        Items.isInit = true

        Items.SetupInteractHook()
    end
end



-- List of "hardcoded" item test (to remove them from inventory, and skip to chapter 2) (and fix scenario_qurick)

local skip_chap_2_item_name = "InteractSendFsm"
local skip_chap_2_folder_path = "Chapter/Chapter1/Outside/c01_Outside03/c01_Outside03_sm"

local knife_item_name = "InteractWeapon"
local knife_parent_name = "wp1190_Knife_Get"
local knife_folder_path = "Chapter/Chapter3/ItemSet_c03/MainHouse_West/Common/KeyItem"

local g17_item_name = "InteractWeapon"
local g17_parent_name = "wp1210_Handgun_Get"
local g17_folder_path = "Chapter/Chapter3/Event_c03/Event_c03_1/evProps"

local snd_g17_item_name = "InteractWeapon"
local snd_g17_parent_name = "wp1210_Handgun_Get"
local snd_g17_folder_path = "Chapter/Chapter3/ItemSet_c03/MainHouse_West/Common/KeyItem"

local grenade_launcher_item_name = "InteractWeapon"
local grenade_launcher_parent_name = "wp1110_PortableCannon_Get"
local grenade_launcher_folder_path = "Chapter/Chapter3/ItemSet_c03/MainHouse_East/Normal/KeyItem"

function Items.SetupInteractHook()
    local interactManager = sdk.find_type_definition(sdk.game_namespace("InteractManager"))
    local interactType = sdk.find_type_definition(sdk.game_namespace("InteractObjectBase"))
    local interact_method = interactType:get_method("FsmExecute")

    -- main item hook, does all the AP stuff
    sdk.hook(interact_method, function(args)
        feedbackFSM = sdk.to_managed_object(args[2])
        feedbackParent = sdk.to_managed_object(feedbackFSM:call("get_GameObject"))
        
        item_name = feedbackParent:call("get_Name()")
        item_folder = feedbackParent:call("get_Folder()")
        transform = feedbackParent:call("get_Transform()") 
        pos = feedbackParent:call("get_Transform"):call("get_Parent()"):call("get_Position()")
        posx = Helpers.Round(pos.x)
        posy = Helpers.Round(pos.y)
        posz = Helpers.Round(pos.z)
        item_position_path = { posx, posy, posz }

        item_folder_path = nil
        item_parent_name = nil

        if item_folder then
            item_folder_path = item_folder:call("get_Path()")
        end

        if item_name and item_folder and feedbackParent then
            item_transform = sdk.to_managed_object(feedbackParent:call('get_Transform()'))
            item_transform_parent = sdk.to_managed_object(item_transform:call('get_Parent()'))

            -- non-item things like typewriters here, so do typewriter interaction tracking
            if string.match(item_name, "SaveMenuInteract") then
                if not Typewriters.unlocked_typewriters[item_folder_path] then
                    Typewriters.AddUnlockedText("", item_folder_path)
                end

                Typewriters.Unlock("", item_folder_path)
            elseif item_transform_parent then
                item_parent = sdk.to_managed_object(item_transform_parent:call('get_GameObject()'))
                item_parent_name = item_parent:call("get_Name()")
                item_positions = item_parent:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("Item")))

                if not item_name or not item_folder_path or not item_positions then
                    item_parent_name = "" -- unset so we know it's a non-standard item location
                end
            end
        end

        -- nothing to do with AP if not connected
        if not Archipelago.IsConnected() then
            if Archipelago.hasConnectedPrior then
                GUI.AddText("Archipelago is not connected.")
                Items.cancelNextUI = true
            end

            return
        end

        -- if item_name and item_folder_path are not nil (even empty strings), do a location lookup to see if we should get an item
        if item_name ~= nil and item_folder_path ~= nil then
            local location_to_check = {}
            location_to_check['item_object'] = item_name
            location_to_check['parent_object'] = item_parent_name or ""
            location_to_check['folder_path'] = item_folder_path
            location_to_check['item_position'] = item_position_path or ""

            If we're interacting with the victory location, send victory and bail
            if Archipelago.CheckForVictoryLocation(location_to_check) then
                Archipelago.SendLocationCheck(location_to_check)
                GUI.AddText("Goal Completed!")

                return
            end

            -- Special item condition here

            -- elseif item_name == knife_item_name and item_folder_path == knife_folder_path and item_parent_name == knife_parent_name then
            --     Inventory.RemoveItem("Knife")
        
            if item_name == g17_item_name and item_folder_path == g17_folder_path and item_parent_name == g17_parent_name then
                Inventory.RemoveItem("Handgun_G17")
                Inventory.removed_gun = false

            elseif item_name == snd_g17_item_name and item_folder_path == snd_g17_folder_path and item_parent_name == snd_g17_parent_name then
                Inventory.cinematic_removed_gun = false

            elseif item_name == grenade_launcher_item_name and item_folder_path == grenade_launcher_folder_path and item_parent_name == grenade_launcher_parent_name then
                Inventory.RemoveItem("GrenadeLauncher")
                Inventory.removed_grenade_launcher = false
            end

            Scenario.UpdateScenarioState(item_name, item_folder_path, item_parent_name)

            local isLocationRandomized = Archipelago.IsLocationRandomized(location_to_check)

            if Archipelago.IsItemLocation(location_to_check) and (Archipelago.SendLocationCheck(location_to_check) or Archipelago.IsConnected()) then

                -- if it's an item, call vanish to get rid of it
                if item_positions and isLocationRandomized then
                    -- Vanish the item
                    item_positions:set_field("ItemStackNum", 0) 
                end
            end
        end
    end)
end


-- This is always broken with a new game, lol -- It is needed, but dunno how to reuse it
-- --------------------
-- function Items.SetupDisconnectWaitHook()
    -- local guiNewInventoryTypeDef = sdk.find_type_definition(sdk.game_namespace("gui.NewInventoryBehavior"))
    -- local guiNewInventoryMethod = guiNewInventoryTypeDef:get_method("setCaptionState")

    -- -- small hook that handles cancelling inventory UIs when having connected before and being not reconnected
    -- sdk.hook(guiNewInventoryMethod, function (args)
    --     if Items.cancelNextUI then
    --         local uiMaster = Scene.getSceneObject():findGameObject("UIMaster")
    --         local compGuiMaster = uiMaster:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gui.GUIMaster")))

    --         Items.cancelNextUI = false
    --         compGuiMaster:closeInventoryForce()
    --     end
    -- end)
-- end

return Items
