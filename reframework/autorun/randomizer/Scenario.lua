local Scenario = {}


function Scenario.Init()
    if Storage.scenarioState == nil then
        return Scenario
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

function Scenario.UpdateScenarioState(item_name, item_folder_path, item_parent_name)
    if item_name == "InteractWeapon"
        and item_folder_path == "Chapter/Chapter3/ItemSet_c03/MainHouse_West/Common/KeyItem"
        and item_parent_name == "wp1210_Handgun_Get" then
        Storage.scenarioState = 4
        return true
    end

    if item_name == "InteractDetailSearch"
        and item_folder_path == "Chapter/Chapter3/c03_MainHouse/c03_MainHouse2F/c03_MainHouse2FBath/c03_MainHouse2FBath_sm"
        and item_parent_name == "sm9092_ShadowPiece02_DetailSearchItem" then
        Storage.scenarioState = 5
        return true
    end

    if item_name == "Interact_sm9091_ShadowPuzzle02A"
        and item_folder_path == "Chapter/Chapter3/c03_MainHouse/c03_MainHouseHall/c03_MainHouseHall_sm"
        and item_parent_name == "" then
        Storage.scenarioState = 9
        return true
    end

    if item_name == "InteractDetailSearch"
        and item_folder_path == "Chapter/Chapter3/c03_TaxidermyRoom/c03_TaxidermyRoomB1F/c03_RightAreaB1FMorgue/c03_RightAreaB1FMorgue_sm"
        and item_parent_name == "sm2050_workroomkey01A_Get" then
        Storage.scenarioState = 9
        return true
    end

    return false
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








return Scenario
