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

local function _Round(number)
    return math.ceil(number * 100) / 100 -- two decimal places
end

local function get_localplayer()
    local object_man = sdk.get_managed_singleton("app.ObjectManager")

    if not object_man then
        return nil
        end
    return object_man:get_field("PlayerObj")
end

function Player.GetYPosition()
    local player_object = get_localplayer()
    local player_transform = player_object:call("get_Transform")
    player_position = player_transform:call("get_LocalPosition")
    log.debug(_Round(player_position.x))
    log.debug(_Round(player_position.y))
    log.debug(_Round(player_position.z))
    output = _Round(player_position.y)
    return output
end

return Player
