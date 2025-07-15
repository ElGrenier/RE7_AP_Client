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



-- local interactType = sdk.find_type_definition(sdk.game_namespace("InteractObjectBase"))

-- if interactType then
--     local interact_method = interactType:get_method("FsmExecute")

--     sdk.hook(interact_method, function(args)
--         local compFeedbackFSM = sdk.to_managed_object(args[2])
--         local parentOfComponent = sdk.to_managed_object(compFeedbackFSM:call("get_GameObject"))

--         Inspect.Log() -- intentional line break
--         Inspect.Log("Item Object", InspectItem.GetName(parentOfComponent))
--         Inspect.Log("Parent Object", InspectItem.GetParentName(parentOfComponent))
--         Inspect.Log("Folder Path", InspectItem.GetFolderPath(parentOfComponent))
--         Inspect.Log("Player Position", InspectPlayer.GetPositionString())

--         if InspectTypewriter.IsTypewriter(parentOfComponent) then
--             Inspect.Log("Recorder Location ID", InspectTypewriter.GetLocationId(parentOfComponent))
--             Inspect.Log("Recorder Map ID", InspectTypewriter.GetMapId(parentOfComponent))
--         end
--     end)
-- end


-- List of "hardcodded" item test (to remove them from inventory, and skip to chapter 2)

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



        -- log.debug(item_name)
        -- log.debug(tostring(item_folder))
        -- log.debug("Item Position", "[" .. tostring(table.concat(item_position_path, ",")) .. "]")

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
                -- Storage.UpdateLastSavedItems() -- Now that i check all the time if the game is ACTUALLY saving, i don't have to rely on the player to save
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
            log.debug("Archipelago is not connected.")

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

            -- If we're interacting with the victory location, send victory and bail
            -- if Archipelago.CheckForVictoryLocation(location_to_check) then
            --     Archipelago.SendLocationCheck(location_to_check)
            --     GUI.AddText("Goal Completed!")

            --     return
            -- end

            -- Special item condition here
            if item_name == skip_chap_2_item_name and item_folder_path == skip_chap_2_folder_path then
                log.debug("DEBUG : Trying Skipping to Chap 2")
                local gameManager = Scene.getGameManager()
                gameManager:call("chapterJumpRequest(System.String, System.Boolean, System.String)", "Chapter3_Start", false, "")

            elseif item_name == knife_item_name and item_folder_path == knife_folder_path and item_parent_name == knife_parent_name then
                log.debug("DEBUG : Trying to remove knife from Inventory")
                Inventory.RemoveItem("Knife")
            
            elseif item_name == g17_item_name and item_folder_path == g17_folder_path and item_parent_name == g17_parent_name then
                log.debug("DEBUG : Trying to remove the G17 from Inventory")
                Inventory.RemoveItem("Handgun_G17")
                Inventory.removed_gun = false

            elseif item_name == snd_g17_item_name and item_folder_path == snd_g17_folder_path and item_parent_name == snd_g17_parent_name then
                log.debug("DEBUG : Trying to remove the snd G17 from Inventory")
                Inventory.cinematic_removed_gun = false

            elseif item_name == grenade_launcher_item_name and item_folder_path == grenade_launcher_folder_path and item_parent_name == grenade_launcher_parent_name then
                log.debug("DEBUG : Trying to remove the Grenade Launcher from Inventory")
                Inventory.RemoveItem("GrenadeLauncher")
                Inventory.removed_grenade_launcher = false
            end
    
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

-- Is this even needed by anything in RE7?
-- -------------------------
-- function Items.SetupStatueUIHook()
    -- local gimmickStatueBehavior = sdk.find_type_definition(sdk.game_namespace("gimmick.action.GimmickDialLockBehavior"))
    -- local safeLateUpdateMethod = gimmickStatueBehavior:get_method("lateUpdate")

    -- -- checks to see if a safe gui close was requested and, if so, close it
    -- sdk.hook(safeLateUpdateMethod, function (args)
    --     if Items.cancelNextStatueUI then
    --         local compFromHook = sdk.to_managed_object(args[2])
    --         local statueObject = compFromHook:call('get_GameObject()') -- the dial gimmick
    --         local compGimmickGUI = statueObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gui.RopewayGimmickAttachmentGUI")))
    --         local compGimmickAttach = statueObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.GimmickAttachment")))
    --         local dialControlObject = compGimmickAttach:get_field("_GimmickControl"):get_GameObject()

    --         if not dialControlObject then
    --             return
    --         end

    --         -- for some reason, *some* of the statues will throw an error despite properly marking off as they should
    --         --   i think it's related to the game having two statue controls on some of them (why?!), but don't care enough to dig into more.
    --         --   so just pcall that f**ker and ignore the error, since it works anyways
    --         pcall(function () 
    --             local compAddItems = dialControlObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.option.AddItemsToInventorySettings")))
    --             local compDialSettings = dialControlObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.option.AttachmentAlphabetLockSettings")))
    --             local settingList = compAddItems:get_field("SettingList")
    --             local itemPosObject = settingList[0]:get_field("ItemPositions")
    --             local itemPositions = itemPosObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("item.ItemPositions")))
    --             local statueName = statueObject:call("get_Name()")
    --             local lastInteractableName = ""
                
    --             if Items.lastInteractable then 
    --                 lastInteractableName = Items.lastInteractable:call("get_Name()")
    --             end

    --             if string.gsub(tostring(lastInteractableName), '_control', '_gimmick') ~= statueName then
    --                 return
    --             end

    --             compFromHook:call("setFinished()")

    --             if compFromHook:get_field("_CurState") > 1 then
    --                 Items.cancelNextStatueUI = false
    --                 Items.lastInteractable = nil
    --                 itemPositions:vanishItemAndSave()
    --                 itemPosObject:call("set_Enabled", false)
                    
    --                 compAddItems:set_field("SettingList", nil)
    --                 compAddItems:call("set_Enabled", false)
    --                 compDialSettings:call("TransmitCorrectAnswer", compGimmickGUI)
    --                 compGimmickGUI:call("SetSatisfy()")
    --                 compFromHook:call("set_Enabled", false)
    --             end            
    --         end)
    --     end
    -- end)
-- end

-- Is this even needed by anything in RE7?
-- -------------------------
-- function Items.SetupSafeUIHook()
    -- local gimmickSafeBoxBehavior = sdk.find_type_definition(sdk.game_namespace("gui.GimmickSafeBoxDialBehavior"))
    -- local safeLateUpdateMethod = gimmickSafeBoxBehavior:get_method("CheckInput")

    -- -- checks to see if a safe gui close was requested and, if so, close it
    -- sdk.hook(safeLateUpdateMethod, function (args)
    --     if Items.cancelNextSafeUI then
    --         local compFromHook = sdk.to_managed_object(args[2])
    --         local safeBoxObject = compFromHook:call('get_GameObject()') -- the dial gimmick
    --         local compGimmickGUI = safeBoxObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gui.RopewayGimmickAttachmentGUI")))
    --         local compGimmickBody = safeBoxObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.GimmickBody")))
    --         local compFsmState = safeBoxObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("FsmStateController")))
    --         local safeBoxControlObject = compGimmickBody:get_field("_GimmickControl"):call("get_GameObject()")
    --         local safeBoxControlParent = safeBoxControlObject:get_Transform():get_Parent():get_GameObject()
    --         local compInteractBehavior = safeBoxControlObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.action.InteractBehavior")))
    --         local compDialSettings = safeBoxControlObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.option.AttachmentSafeBoxDialSettings")))
    --         local compAddItem = safeBoxControlParent:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("gimmick.option.AddItemToInventorySettings")))
    --         local itemPosObject = compAddItem:get_field("ItemPositions")
    --         local itemPositions = itemPosObject:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("item.ItemPositions")))

    --         Items.cancelNextSafeUI = false
    --         itemPositions:vanishItemAndSave()
    --         compGimmickGUI:call("SetSatisfy()")
    --         compAddItem:set_field("Enable", false) -- I guess set_Enabled is only for gameobjects and not components? smh
    --         compDialSettings:call("TransmitCorrectAnswer", compGimmickGUI)
    --     end
    -- end)
-- end

-- this was a test to swap items to a different visual item. might not work anymore.
-- function Items.SwapAllItemsTo(item_name)
--     scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
--     item_objects = scene:call("findGameObjectsWithTag(System.String)", "Item")

--     for k, item in pairs(item_objects:get_elements()) do
--         item_name = item:call("get_Name()")
--         item_folder = item:call("get_Folder()")
--         item_folder_path = item_folder:call("get_Path()")
--         item_component = item:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("item.ItemPositions")))

--         if item_component then
--             item_id = item_component:get_field("InitializeItemId")

--             if item_id then -- all item_numbers are hex to decimal, use decimal here
--                 if new_item_name == "spray" then
--                     item_number = 1
--                     item_count = 1
--                 elseif new_item_name == "handgun ammo" then
--                     item_number = 15
--                     item_count = 30
--                 elseif new_item_name == "wood crate" then
--                     item_number = 294
--                     item_count = 1
--                 elseif new_item_name == "picture block" then
--                     item_number = 98
--                     item_count = 1
--                 end

--                 item_component:set_field("InitializeItemId", item_number)
--                 item_component:set_field("InitializeCount", item_count)
--                 item_component:call("createInitializeItem()")
--             end
--         end
--     end
-- end

return Items
