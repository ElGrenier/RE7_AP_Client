local CutsceneObjects = {}


function CutsceneObjects.Init()
    -- if Storage.scenarioState == nil then
    --     Storage.scenarioState = 0
    -- end

    -- Shadow Puzzle removal/activation
    if Storage.scenarioState == 4 then
        local gimm = Helpers.gameObject("sm9091_ShadowPuzzle02A_Gimmick")
        local interactObj = Helpers.transform(gimm):call("find", "Interact_sm9091_ShadowPuzzle02A"):call("get_GameObject")
        local interactBase = Helpers.old_component(interactObj, "InteractObjectBase")
        interactBase:set_field("IsEnable", false)
    end

    if Storage.scenarioState == 5 then
        local gimm = Helpers.gameObject("sm9091_ShadowPuzzle02A_Gimmick")
        local interactObj = Helpers.transform(gimm):call("find", "Interact_sm9091_ShadowPuzzle02A"):call("get_GameObject")
        local interactBase = Helpers.old_component(interactObj, "InteractObjectBase")
        interactBase:set_field("IsEnable", true)
        Storage.scenarioState = 6
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

    if Storage.scenarioState <= 5 then
        -- Desactivate door interaction
        local door_gimm = Helpers.gameObject("InteractDoor_ItemOpenF")
        local door_interactButtonBase = Helpers.old_component(door_gimm, "InteractDoor")
        door_interactButtonBase:set_field("IsEnable", false)
    end

    if Storage.scenarioState == 6 and Helpers.Round(Player.GetCurrentPosition().x) == -7.52 and Helpers.Round(Player.GetCurrentPosition().y) == 0.44 and Helpers.Round(Player.GetCurrentPosition().z) == -1.85 then
        local door_gimm = Helpers.gameObject("InteractDoor_ItemOpenF")
        local door_interactButtonBase = Helpers.old_component(door_gimm, "InteractDoor")
        door_interactButtonBase:set_field("IsEnable", true)
    end

    -- Red Dog Head removal/activation

    if Storage.scenarioState <= 8 then
        local gimm = Helpers.gameObject("sm2011_TripleCrest01C_InteractSendFsm")
        local interactButtonBase = Helpers.old_component(gimm, "InteractSendFsm")
        interactButtonBase:set_field("IsEnable", false)
    end

    if Storage.scenarioState == 9 then
        local gimm = Helpers.gameObject("sm2011_TripleCrest01C_InteractSendFsm")
        local interactButtonBase = Helpers.old_component(gimm, "InteractSendFsm")
        interactButtonBase:set_field("IsEnable", true)
        Storage.scenarioState = 10
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
-- 6 = The Shadow puzzle has been interacted (not solved, but can't make the player not)
-- 7 = The Red Dog head has been taken

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