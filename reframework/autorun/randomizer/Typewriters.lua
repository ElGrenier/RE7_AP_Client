local Typewriters = {}
Typewriters.unlocked_typewriters = {}



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

                local posv3 = ValueType.new(sdk.find_type_definition("via.vec3"))
                posv3:call(".ctor(System.Single, System.Single, System.Single)", pos[1], pos[2], pos[3])
                -- log.debug("posv3")
                -- log.debug(posv3.x)
                -- log.debug(posv3.y)
                -- log.debug(posv3.z)




                local playerObject = Player.GetGameObject()
                playerMovement = Helpers.component(playerObject, "PlayerMovement")
                gameMaster = Scene.getGameMaster()
                gameManager = Scene.getGameManager()
                saveDataManager = Helpers.component(gameMaster, "SaveDataManager")

                sceneLocal = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
                newFolder = sceneLocal:findFolder(folderLoaded)

                if chapterNumber == 5 then
                    oldFolder_2 = sceneLocal:findFolder("Chapter/Chapter4")
                    oldFolder_1 = sceneLocal:findFolder("Chapter/Chapter1")
                elseif chapterNumber == 6 then
                    oldFolder_2 = sceneLocal:findFolder("Chapter/Chapter3")
                    oldFolder_1 = sceneLocal:findFolder("Chapter/Chapter1")
                elseif chapterNumber == 4 then
                    oldFolder_2 = sceneLocal:findFolder("Chapter/Chapter3")
                    oldFolder_1 = sceneLocal:findFolder("Chapter/Chapter4")
                end

                
                gameManager:call("set_CurrentChapter(app.GameManager.ChapterNo)", chapterNumber)
                gameManager:call("deactivateFolder(via.Folder, System.Boolean)", oldFolder_2, false)
                gameManager:call("deactivateFolder(via.Folder, System.Boolean)", oldFolder_1, false)
                saveDataManager:call("folderLoadRequest(via.Folder, System.Boolean)", newFolder, false)

                playerMovement:call("recovery(via.vec3)", posv3)

                -- currentChapter = gameManager:call("get_CurrentChapter()")
                -- log.debug(currentChapter)
                -- if chapterNumber == "Chapter1_Start" and currentChapter == 5 then
                --     log.debug("Changing chapter 3 -> 1")
                --     gameManager:call("chapterJumpRequest(System.String, System.Boolean, System.String)", chapterNumber, false, "")
                -- elseif chapterNumber == "Chapter3_Start" and currentChapter == 4 then
                --     log.debug("Changing chapter 1 -> 3")
                --     gameManager:call("chapterJumpRequest(System.String, System.Boolean, System.String)", chapterNumber, false, "")
                -- elseif chapterNumber == "Chapter3_Start" and not currentChapter == 5 then
                --     log.debug("Teleporting Chapter 3")
                --     playerMovement:call("recovery(via.vec3)", posv3)
                -- elseif chapterNumber == "Chapter1_Start" and not currentChapter == 4 then
                --     playerMovement:call("recovery(via.vec3)", posv3)
                --     log.debug("Teleporting Chapter 1")
                -- end

                
                
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

    if imgui.button("Give Debug Items") then
        ItemBox.AddItem("UnlimitedAmmo", 1)
        ItemBox.AddItem("AlphaGrass", 1)
    end

    if imgui.button("Add Inventory Item") then
        local itemId = "UnlimitedAmmo"
        local quantity = 1

        -- Add to item box
        inventory = Inventory.GetInventory()
        local itemBoxData = inventory:get_field("<ItemBoxData>k__BackingField")
        itemBoxData:addItem(itemId, quantity, nil)

        -- Move to inventory
        if not inventoryMenu then return end
        local itemParam = itemBoxData:findItem(itemId)
        inventoryMenu:moveItemBoxToInventory(itemParam, quantity)
    end


    if imgui.button("Test") then
        Inventory.AddItemtoInventory()
    end

    imgui.pop_font()
    imgui.end_window()
end

return Typewriters


