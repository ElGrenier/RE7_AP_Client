local game_name = reframework:get_game_name()
if game_name ~= "re7" then
    re.msg("This script is only for RE7")
    return
end


log.debug("[Randomizer] Loading mod...")


-- START globals
AP_REF = require("AP_REF/core")

Manifest = require("randomizer/Manifest")
Lookups = require("randomizer/Lookups")

Archipelago = require("randomizer/Archipelago")
DestroyObjects = require("randomizer/DestroyObjects")
GUI = require("randomizer/GUI")
Helpers = require("randomizer/Helpers")
Inventory = require("randomizer/Inventory")
ItemBox = require("randomizer/ItemBox")
Items = require("randomizer/Items")
Player = require("randomizer/Player")
Scene = require("randomizer/Scene")
StartingWeapon = require("randomizer/StartingWeapon")
Storage = require("randomizer/Storage")
Typewriters = require("randomizer/Typewriters")
Tools = require("randomizer/Tools")
-- END globals

Lookups.Load("normal")


-- For debugging / trying out functionality:
-- Player.GetInventorySlots()
-- ItemBox.GetItems()

-- Door gimmicks (like Door_2_1_003_gimmick) have a GimmickDoor comp
--   that has references to "MyRooms" and "MyLocations", and something about "IsPairComplete"


re.on_pre_application_entry("UpdateBehavior", function()
    if Scene:isInGame() then 
        Archipelago.Init()
        Items.Init()
        DestroyObjects.Init()
        StartingWeapon.Init()

        -- If the game is saving (detected by "get_NowSaving()"), update the storage to the last received items
        local gameMaster = Scene.getGameMaster()
        local saveDataManager = Helpers.component(gameMaster, "SaveDataManager")
        local isSaving = saveDataManager:call("get_NowSaving()")
        if isSaving then
            Storage.UpdateLastSavedItems()
        end

        if Inventory.removed_gun == false and Inventory.GetHandRightItem() == 7 then
            Inventory.RemoveMainhandItem()
            Inventory.removed_gun = true
        end

        if Inventory.GetHandRightItem() == 7 and Inventory.cinematic_removed_gun == false and Player.GetYPosition() == 1.48 then
            Inventory.RemoveMainhandItem()
            Inventory.RemoveItem("Handgun_G17")
            Inventory.cinematic_removed_gun = true
            log.debug("Tried removing Handgun AFTER cinematic")
        end

        if Inventory.GetHandRightItem() == 16 and Inventory.removed_grenade_launcher == false then
            Inventory.removed_grenade_launcher = true
            Inventory.RemoveMainhandItem()
            log.debug("Tried removing Grenade Launcher")
        end

        if Archipelago.waitingForSync then
            Archipelago.waitingForSync = false
            Archipelago.Sync()
        end

        if Archipelago.CanReceiveItems() then
            Archipelago.ProcessItemsQueue()
        end

        -- if the game randomly forgets that the player exists and tries to leave the invincibility flag on from item pickup,
        --   relentlessly check for the player existing until it does, then turn that flag off
        if Archipelago.waitingForInvincibiltyOff then
            if Player.TurnOffInvincibility() then
                Archipelago.waitingForInvincibiltyOff = false
            end
        end

        if Player.waitingForKill then
            Player.Kill()
        else
            Archipelago.canDeathLink = true
            Archipelago.wasDeathLinked = false
        end
    else
        DestroyObjects.isInit = false -- look for objects that should be destroyed and destroy them again
    end

    if Scene:isGameOver() then
        if Archipelago.canDeathLink and not Archipelago.wasDeathLinked then
            Archipelago.canDeathLink = false
            Archipelago:SendDeathLink()
        end
        
        if not Archipelago.waitingForSync then
            Archipelago.waitingForSync = true
        end
    end
end)

re.on_frame(function ()
    -- ... one day OpieOP
    -- if Scene:isTitleScreen() then
    --     GUI.ShowRandomizerLogo()
    -- end

    -- if reframework:is_drawing_ui() then
    --     Tools.ShowGUI()
    -- end

    if Scene:isInGame() or Scene:isGameOver() then
        GUI.CheckForAndDisplayMessages()
    end

    if Scene:isInGame() then 
        -- only show the typewriter window when the user presses the reframework hotkey
        if reframework:is_drawing_ui() then
            Typewriters.DisplayWarpMenu()
        end
    end
end)

re.on_draw_ui(function () -- this is only called when Script Generated UI is visible
    -- nothing, but could add some debug stuff here one day
end)

log.debug("[Randomizer] Mod loaded.")
