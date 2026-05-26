local game_name = reframework:get_game_name()
if game_name ~= "re7" then
    re.msg("This script is only for RE7")
    return
end

-- START globals
AP_REF = require("AP_REF/core")

Manifest = require("randomizer/Manifest")
Lookups = require("randomizer/Lookups")

Logging = require("randomizer/Logging")
Archipelago = require("randomizer/Archipelago")
Scenario = require("randomizer/Scenario")
DestroyObjects = require("randomizer/DestroyObjects")
GUI = require("randomizer/GUI")
Helpers = require("randomizer/Helpers")
Inventory = require("randomizer/Inventory")
ItemBox = require("randomizer/ItemBox")
Items = require("randomizer/Items")
Player = require("randomizer/Player")
Scene = require("randomizer/Scene")
Storage = require("randomizer/Storage")
Typewriters = require("randomizer/Typewriters")
Tools = require("randomizer/Tools")
-- END globals

Lookups.Load("normal")

re.on_pre_application_entry("UpdateBehavior", function()
    if Scene:isInGame() then 
        Archipelago.Init()
        Items.Init()
        DestroyObjects.Init()
        Logging.Init()

        if Archipelago.start_at_chapter_2 == "True" and Scene.getCurrentChapter() == 4 and not Scene.isGameLoading() then
            Scene.getGameManager():call("chapterJumpRequest(System.String, System.Boolean, System.String)", "Chapter3_Start", false, "")
        end

        -- If the game is saving (detected by "get_NowSaving()"), update the storage to the last received items
        local isSaving = Helpers.old_component(Scene.getGameMaster(), "SaveDataManager"):call("get_NowSaving()")
        if isSaving then
            Storage.UpdateLastSavedItems()
        end

        Inventory.CleanupHeldWeapons()

        if Archipelago.waitingForSync and not Scene.isGameLoading() then
            Archipelago.waitingForSync = false
            Archipelago.Sync()
        end

        if Archipelago.CanReceiveItems() then
            Archipelago.ProcessItemsQueue()
        end

        if not Scene:isGameOver() then
            if Player.waitingForKill then
                Player.Kill()
            else
                Archipelago.canDeathLink = true
                Archipelago.wasDeathLinked = false
            end
        end

    else
        DestroyObjects.isInit = false -- look for objects that should be destroyed and destroy them again
    end

    if Scene:isGameOver() then
        if Archipelago.canDeathLink and not Archipelago.wasDeathLinked then
            Archipelago.canDeathLink = false
            Archipelago:SendDeathLink()
        end
        
        if not Archipelago.waitingForSync and Player.GetLocalPlayer() ~= nil then -- Ask for a resend after the player has died
            Archipelago.waitingForSync = true
        end
    end
    Scenario.Init()
end)

re.on_frame(function ()
    if reframework:is_drawing_ui() then
        Tools.ShowGUI()
    end

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

re.on_draw_ui(function ()
end)
