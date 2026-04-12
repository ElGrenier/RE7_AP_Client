local CutsceneObjects = {}


function CutsceneObjects.Init()
    if Storage.scenarioState == nil then
        return CutsceneObjects
    end

    local shadowPuzzle = Helpers.gameObject("sm9091_ShadowPuzzle02A_Gimmick")
    if shadowPuzzle then
        -- Shadow Puzzle removal/activation
        if Storage.scenarioState <= 4 then
            local interactBase = Helpers.old_component(Helpers.transform(shadowPuzzle):call("find", "Interact_sm9091_ShadowPuzzle02A"):call("get_GameObject"), "InteractObjectBase")
            if interactBase then
                interactBase:set_field("IsEnable", false)
            end
        end

        if Storage.scenarioState >= 5 then
            local interactBase = Helpers.old_component(Helpers.transform(shadowPuzzle):call("find", "Interact_sm9091_ShadowPuzzle02A"):call("get_GameObject"), "InteractObjectBase")
            if interactBase then
                interactBase:set_field("IsEnable", true)
                Storage.scenarioState = 6
            end
        end
    end

-- -- If the Shadow puzzle has been interacted, and that it can't find it anymore, then it consider it being correctly finished (and progress the scenarioState)
--     if Storage.scenarioState == 6 then
--         local shadow_gimm = Helpers.gameObject("sm9091_ShadowPuzzle02A_Gimmick")
--         local shadow_interactObj = Helpers.transform(shadow_gimm):call("find", "Interact_sm9091_ShadowPuzzle02A"):call("get_GameObject")
--         local shadow_interactBase = Helpers.old_component(shadow_interactObj, "InteractObjectBase")
--         if shadow_interactBase == nil then
--             Storage.scenarioState = 7
--         end
--     end

    local door_gimm = Helpers.gameObject("InteractDoor_ItemOpenF")
    if door_gimm then
        if Storage.scenarioState <= 6 then
            -- Desactivate door interaction
            local door_interactButtonBase = Helpers.old_component(Helpers.gameObject("InteractDoor_ItemOpenF"), "InteractDoor")
            if door_interactButtonBase then
                door_interactButtonBase:set_field("IsEnable", false)
            end
        end
    
        if Storage.scenarioState >= 7 and Helpers.Round(Player.GetCurrentPosition().x) == -7.52 and Helpers.Round(Player.GetCurrentPosition().y) == 0.44 and Helpers.Round(Player.GetCurrentPosition().z) == -1.85 then
            local door_interactButtonBase = Helpers.old_component(door_gimm, "InteractDoor")
            if door_interactButtonBase then
                door_interactButtonBase:set_field("IsEnable", true)
            end
        end
    end

    -- Red Dog Head removal/activation

    if Storage.scenarioState <= 7 then
        local gimm = Helpers.gameObject("sm2011_TripleCrest01C_InteractSendFsm")
        if gimm then
            local interactButtonBase = Helpers.old_component(gimm, "InteractSendFsm")
            if interactButtonBase then
                interactButtonBase:set_field("IsEnable", false)
            end
        end
    end

    if Storage.scenarioState >= 8 then
        local gimm = Helpers.gameObject("sm2011_TripleCrest01C_InteractSendFsm")
        if gimm then
            local interactButtonBase = Helpers.old_component(gimm, "InteractSendFsm")
            if interactButtonBase then
                interactButtonBase:set_field("IsEnable", true)
            end
        end
    end

    if Storage.scenarioState <= 8 then
        -- Desactivate door interaction
        local door = Helpers.gameObject("InteractDoor_ItemOpenF")
        if door then
            local door_dog_interactButtonBase = Helpers.old_component(door, "InteractDoor")
            if door_dog_interactButtonBase then
                door_dog_interactButtonBase:set_field("IsEnable", false)
            end
        end
    end

    if Storage.scenarioState >= 9 then
        -- Desactivate door interaction
        local door = Helpers.gameObject("InteractDoor_ItemOpen")
        if door then
            local door_dog_interactButtonBase = Helpers.old_component(door, "InteractDoor")
            if door_dog_interactButtonBase then
                door_dog_interactButtonBase:set_field("IsEnable", false)
            end
        end
    end
end


-- -------------------------------------------------
-- Storage.scenarioState is for the scenario state
-- 0 = No scenario progress
-- 1 = The key to flee the dad has been taken (unset)
-- 2 = The cinematic with the cops has been done (unset)
-- 3 = ??? (unset)
-- 4 = The second gun has been taken (the one to kill the dad)
-- 5 = The wooden puzzle in the bath has been taken
-- 6 = The Shadow puzzle has been solved
-- 7 = ???
-- 8 The dissection room key has been taken
-- 9 The red dog head has been taken
-- ---------------------------------------------------








-- CutsceneObjects.isInit = false
-- CutsceneObjects.lastStop = os.time()

-- function CutsceneObjects.Init()
--     if Archipelago.IsConnected() and not CutsceneObjects.isInit then
--         CutsceneObjects.isInit = true
--         CutsceneObjects.DispersalCartridge()
--     end

--     -- if the last check for cutscene objects was X time ago or more, trigger another removal
--     if os.time() - CutsceneObjects.lastStop > 15 then -- 15 seconds
--         CutsceneObjects.isInit = false
--     end
-- end

-- function CutsceneObjects.DispersalCartridge()
--     local dispersalObject = Helpers.gameObject("sm42_222_SprayingMachine01A_control")
--     if not dispersalObject then
--         return
--     end
--     local dispersalComponent = Helpers.component(dispersalObject, "gimmick.option.AddItemToInventorySettings")
--     dispersalComponent:set_field("Enable", false)
-- end

return CutsceneObjects
