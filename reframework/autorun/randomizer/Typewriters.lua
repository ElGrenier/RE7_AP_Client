local Typewriters = {}
Typewriters.unlocked_typewriters = {}

local function get_localplayer()
    return sdk.get_managed_singleton("app.ObjectManager"):get_field("PlayerObj")
end

local known_typeofs = {}
function get_component(game_object, type_name)
    local t = known_typeofs[type_name] or sdk.typeof(type_name)
    known_typeofs[type_name] = t
    return game_object:call("getComponent(System.Type)", t)
end

local function teleportPlayer(pos)
    local player = get_localplayer()
    local controller = get_component(player, "via.physics.CharacterController")
    controller:call("warp")
    player:get_Transform():set_Position(pos)
    controller:call("warp")
end


function Typewriters.AddUnlockedText(name, item_folder_path, no_save_warning)
    if #Lookups.typewriters == 0 then -- no typewriters, no typewriters to unlock
        return
    end
    local typewriterText = name

    if #typewriterText == 0 then
        for t, typewriter in pairs(Lookups.typewriters) do
            if typewriter["folder_path"] == item_folder_path then
                typewriterText = typewriter["name"]
                break
            end
        end
    end
end

-- Allowing specifying either the readable name or the item name, so both AP options and Item interaction can unlock
function Typewriters.Unlock(name, item_folder_path)
    if #Lookups.typewriters == 0 then -- no typewriters, no typewriters to unlock
        return
    end
    -- Typewriters.UnlockAll()
    -- return
    for t, typewriter in pairs(Lookups.typewriters) do
        if typewriter["name"] == name or typewriter["folder_path"] == item_folder_path then
            Typewriters.unlocked_typewriters[typewriter["folder_path"]] = true
            break
        end
    end
end

function Typewriters.UnlockAll()
    if #Lookups.typewriters == 0 then -- no typewriters, no typewriters to unlock
        return
    end
    for t, typewriter in pairs(Lookups.typewriters) do
        Typewriters.unlocked_typewriters[typewriter["folder_path"]] = true
    end
end

function Typewriters.GetAllUnlocked()
    local typewriter_item_names = {}
    for typewriter, is_unlocked in pairs(Typewriters.unlocked_typewriters) do
        table.insert(typewriter_item_names, typewriter)
    end
    return typewriter_item_names
end

function Typewriters.DisplayWarpMenu()
    imgui.begin_window("Fast Travel - Typewriters", nil,
        8 -- NoScrollbar
        | 64 -- AlwaysAutoResize
    )

    local font = imgui.load_font(GUI.font, GUI.font_size)

    if (font ~= nil) then
        imgui.push_font(font)
    end

    for t, typewriter in pairs(Lookups.typewriters) do
        local typewriter_disabled = false

        -- if the player has unlocked the typewriter by interacting once, set active color; otherwise, set default
        if Typewriters.unlocked_typewriters[typewriter["folder_path"]] and not typewriter_disabled then
            imgui.push_style_color(imgui.COLOR_BUTTON, Vector4f.new(2.5, 2.5, 2.5, 1.00))
        else
            imgui.push_style_color(imgui.COLOR_BUTTON, Vector4f.new(1, 1, 1, 0.07))
        end

        -- don't allow the user to teleport while using the item box, and check that they're in-game for good measure too
        if imgui.button(typewriter["name"]) and Scene.isInGame() and not Scene.isUsingItemBox() and not typewriter_disabled then
            -- if the player has unlocked the typewriter by interacting once, let them teleport; otherwise, do nothing
            if Typewriters.unlocked_typewriters[typewriter["folder_path"]] then
                local pos = typewriter["player_position"]
                local folderLoaded = typewriter["folder_path"]
                local chapterNumber = typewriter["chapter"] -- chapters start at 4 for ch 1, because title is 3

                gameMaster = Scene.getGameMaster()
                gameManager = Scene.getGameManager()
                saveDataManager = Helpers.component(gameMaster, "SaveDataManager")

                sceneLocal = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
                newFolder = sceneLocal:findFolder(folderLoaded)

                local currentChapter = gameManager:call("get_CurrentChapter()")
                log.debug(currentChapter)
                if currentChapter == 5 then
                    local oldFolder = sceneLocal:findFolder("Chapter/Chapter3")
                elseif currentChapter == 6 then
                    local oldFolder = sceneLocal:findFolder("Chapter/Chapter4")
                elseif currentChapter == 4 then
                    local oldFolder = sceneLocal:findFolder("Chapter/Chapter1")
                end

                
                gameManager:call("set_CurrentChapter(app.GameManager.ChapterNo)", chapterNumber)
                teleportPlayer(Vector3f.new(pos[1],pos[2],pos[3]))
                saveDataManager:call("folderLoadRequest(via.Folder, System.Boolean)", newFolder, false)
                gameManager:call("deactivateFolder(via.Folder, System.Boolean)", oldFolder, false)
                
                local currentChapter = gameManager:call("get_CurrentChapter()")
                log.debug(currentChapter)

            end
        end

        imgui.pop_style_color(1)

        -- Break the list onto two lines around the middle; i.e., skip the same_line once
        if not typewriter["line_break"] then
            imgui.same_line()
        end
    end

    imgui.new_line()
    imgui.new_line()

    if imgui.button("Unlock All Typewriters") then
        Typewriters.UnlockAll()
    end

    -- imgui.new_line()
    -- if imgui.button("RESET CAMERA") then
    --     local gameMaster = Scene.getGameMaster()
    --     local cameraManager = Helpers.component(gameMaster, "CameraManager")
    --     local playerCamera = cameraManager:call("get_playerCamera()")
    --     local mainCamera = cameraManager:call("get_mainCamera()")

    --     -- cameraManager:call("set_mainCamera(via.Camera)",playerCamera)
    --     cameraManager:call("forceSetCamera(via.Camera)",playerCamera)
    -- end
    -- imgui.new_line()
    -- if imgui.button("bug fix") then
    --     local sceneLocal = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
    --     local oldFolder = sceneLocal:findFolder("Chapter/Chapter3")
    --     local gameManager = Scene.getGameManager()
    --     gameManager:call("deactivateFolder(via.Folder, System.Boolean)", oldFolder, false)
    -- end
    -- imgui.new_line()
    -- if imgui.button("RESET CAMERA") then
    --     local gameMaster = Scene.getGameMaster()
    --     local chapterLoadTempManager = Helpers.component(gameMaster, "ChapterLoadTempManager")

        -- cameraManager:call("set_mainCamera(via.Camera)",playerCamera)
        -- chapterLoadTempManager:call("forceSetCamera(via.Camera)",playerCamera)
    -- end
    -- if imgui.button("LoadFolder") then
    --     -- local gameMaster = Scene.getGameMaster()
    --     -- local saveDataManager = Helpers.component(gameMaster, "SaveDataManager")
    --     local test = sceneLocal:findFolder("Chapter/Chapter3")
    --     saveDataManager:call("folderClear(via.Folder)", test)
    --     gameManager:call("deactivateFolder(via.Folder, System.Boolean)", test, false)
    --     saveDataManager:call("folderLoadRequest(via.Folder, System.Boolean)", newFolder, false)
    -- end
    if imgui.button("GiveItem") then

        ItemBox.AddItem("GrenadeLauncher", 1)
        ItemBox.AddItem("HyperBlaster", 1)
        ItemBox.AddItem("RedBlaster", 1)
        ItemBox.AddItem("UnlimitedAmmo", 1)
    end

    imgui.pop_font()
    imgui.end_window()
end

return Typewriters


