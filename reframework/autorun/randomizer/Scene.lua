local Scene = {}

Scene.sceneObject = nil
Scene.gameManager = nil

scene_timer = 0
while scene_timer < 100 and not pcall(function()
	Scene.sceneObject = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
	scene_timer = nil
end) do scene_timer = scene_timer + 1 end


function Scene.getSceneObject()
    if not Scene.sceneObject then
        Scene.sceneObject = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
    end

    return Scene.sceneObject
end

function Scene.getGameMaster()
    return Helpers.gameObject("SystemObject")
end

function Scene.getGameManager()
    if not Scene.gameManager then
        local gameMaster = Scene.getGameMaster()
        if gameMaster then
            Scene.gameManager = gameMaster:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace("GameManager")))
        end
    end

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
    local gameManager = Scene.getGameManager()
    return gameManager and gameManager:call("isGamePlayableScene")
end

function Scene.isInPause()
    local gameManager = Scene.getGameManager()
    return gameManager and gameManager:call("get_IsPause") and Scene.isInGame()
end

function Scene.isGameLoading()
    local gameManager = Scene.getGameManager()
    return gameManager and gameManager:call("get_IsSceneLoading()")
end

function Scene.isGameOver()
    local gameManager = Scene.getGameManager()
    return gameManager and gameManager:call("isGameOver")
end

function Scene.goToGameOver()
    local gameManager = Scene.getGameManager()
    return gameManager and gameManager:call("setGameOverFlag(System.Boolean)", true)
end

function Scene.isUsingItemBox()
    return Scene.getGUIItemBox():get_DrawSelf() -- is the ItemBox GUI "drawn"?
end


return Scene
