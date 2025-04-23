local Scene = {}

Scene.sceneObject = nil
Scene.gameManager = nil

function Scene.getSceneObject()
    if Scene.sceneObject ~= nil then
        return Scene.sceneObject
    end

    Scene.sceneObject = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")

    return Scene.sceneObject
end

function Scene.getGameMaster()
    return Helpers.gameObject("SystemObject")
end

function Scene.getGameManager()
    if Scene.gameManager ~= nil then
        return Scene.gameManager
    end

    local gameMaster = Scene.getGameMaster()

    Scene.gameManager = gameMaster:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("GameManager")))

    return Scene.gameManager
end

function Scene.getGUIItemBox()
    return Helpers.gameObject("InventoryMenu")
end

function Scene.isTitleScreen()
    local mfm = Scene.getGameManager()
    local currentChapter = mfm:call("get_CurrentChapter")

    return mfm:call("isTitleScene", currentChapter)
end

function Scene.isInGame()
    return Scene.getGameManager():call("isGamePlayableScene")
end

function Scene.isInPause()
    return Scene.getGameManager():call("get_IsPause") and Scene.isInGame()
end

function Scene.isGameOver()
    return Scene.getGameManager():call("isGameOver")
end

function Scene.goToGameOver()
    return Scene.getGameManager():call("setGameOverFlag", true)
end

function Scene.isUsingItemBox()
    return Scene.getGUIItemBox():get_DrawSelf() -- is the ItemBox GUI "drawn"?
end


return Scene
