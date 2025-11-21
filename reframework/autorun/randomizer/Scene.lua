local Scene = {}

Scene.sceneObject = nil
Scene.gameManager = nil

scene_timer = 0
while scene_timer < 100 and not pcall(function()
	scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")
	scene_timer = nil
end) do scene_timer = scene_timer + 1 end


function Scene.getSceneObject()
    if Scene.sceneObject ~= nil then
        return Scene.sceneObject
    end

	scene = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_CurrentScene()")

    return scene
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

function Scene.isGameLoading()
    return Scene.getGameManager():call("get_IsSceneLoading()")
end

function Scene.isGameOver()
    return Scene.getGameManager():call("isGameOver")
end

function Scene.goToGameOver()
    return Scene.getGameManager():call("setGameOverFlag(System.Boolean)", true)
end

function Scene.isUsingItemBox()
    return Scene.getGUIItemBox():get_DrawSelf() -- is the ItemBox GUI "drawn"?
end


return Scene
