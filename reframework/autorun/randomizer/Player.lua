local Player = {}
Player.waitingForKill = false

function Player.GetLocalPlayer()
    local object_man = sdk.get_managed_singleton("app.ObjectManager")

    if not object_man then
        return nil
        end
    return object_man:get_field("PlayerObj")
end

function Player.GetGameObject()
    return Scene.getGameManager():call("getPlayer")
end

function Player.GetCurrentPosition()
    return Player.GetLocalPlayer():get_Transform():get_LocalPosition()
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



function Player.GetYPosition()
    local player_object = Player.GetLocalPlayer()
    local player_transform = player_object:call("get_Transform")
    player_position = player_transform:call("get_LocalPosition")
    -- log.debug(Helpers.Round(player_position.x))
    -- log.debug(Helpers.Round(player_position.y))
    -- log.debug(Helpers.Round(player_position.z))
    return Helpers.Round(player_position.y)
end

return Player
