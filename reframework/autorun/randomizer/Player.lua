local Player = {}
Player.waitingForKill = false

function Player.GetGameObject()
    return Scene.getGameManager():call("getPlayer")
end

function Player.GetCurrentPosition()
    return Player.GetGameObject():get_Transform():get_Position()
end

function Player.WarpToPosition(vectorNew)
    Player.GetGameObject():get_Transform():set_UniversalPosition(vectorNew)
end

function Player.LookAt(transform)
    Player.GetGameObject():get_Transform():lookAt(transform)
end

function Player.Kill()
    if Archipelago.wasDeathLinked == false then
        if Scene.isInPause() or Scene.isUsingItemBox() or not Scene.isInGame() then
            Player.waitingForKill = true

            return
        end

        Player.waitingForKill = false
        Scene.goToGameOver()
    end
end

return Player
