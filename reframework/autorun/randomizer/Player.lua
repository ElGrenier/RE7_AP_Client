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

function Player.WarpToPosition(x, y, z)
    Helpers.old_component(Player.GetLocalPlayer(), "PlayerMovement"):call("recovery(via.vec3)", Helpers.create_posv3(x, y, z))
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
    else
        Player.waitingForKill = false
        Scene.goToGameOver()
    end
end

return Player
