local Archipelago = {}
Archipelago.seed = nil
Archipelago.slot = nil
Archipelago.starting_weapon = nil -- comes over in slot data
Archipelago.death_link = false -- comes over in slot data
Archipelago.hasConnectedPrior = false -- keeps track of whether the player has connected at all so players don't have to remove AP mod to play vanilla
Archipelago.isInit = false -- keeps track of whether init things like handlers need to run
Archipelago.waitingForSync = false -- randomizer calls APSync when "waiting for sync"; i.e., when you die
Archipelago.waitingForInvincibiltyOff = false -- occasionally, the game "forgets" who the player is, so this is a backup to toggle off item pickup invincibility
Archipelago.canDeathLink = false -- this gets set to true when you're in-game, then a deathlink can send in game over and this is set to false again, repeat -- Used in randomizer.lua
Archipelago.wasDeathLinked = false -- this gets set to true when we're killed from a deathlink, so we don't trigger another deathlink (and a loop)

Archipelago.itemsQueue = {}
Archipelago.isProcessingItems = false -- this is set to true when the queue is being processed so we don't over-give

-- set the game name in apclientpp
AP_REF.APGameName = "Resident Evil 7"

function Archipelago.Init()
    if not Archipelago.isInit then
        Archipelago.isInit = true
    end
end

function Archipelago.IsConnected()
    return AP_REF.APClient ~= nil and AP_REF.APClient:get_state() == AP_REF.AP.State.SLOT_CONNECTED
end

function Archipelago.GetPlayer()
    local player = {}

    if AP_REF.APClient == nil then
        return {}
    end

    player["slot"] = AP_REF.APClient:get_slot()
    player["seed"] = AP_REF.APClient:get_seed()
    player["number"] = AP_REF.APClient:get_player_number()
    player["alias"] = AP_REF.APClient:get_player_alias(player['number'])
    player["game"] = AP_REF.APClient:get_player_game(player['number'])

    return player
end

function Archipelago.Sync()
    if AP_REF.APClient == nil then
        return
    end

    AP_REF.APClient:Sync()
end

function Archipelago.DisableInGameClient(client_message)
    AP_REF.DisableInGameClient(client_message)
end

function Archipelago.EnableInGameClient()
    AP_REF.EnableInGameClient()
end

-- server sends slot data when slot is connected
function APSlotConnectedHandler(slot_data)
    Archipelago.hasConnectedPrior = true
    GUI.AddText('Connected.')

    return Archipelago.SlotDataHandler(slot_data)
end
AP_REF.on_slot_connected = APSlotConnectedHandler

function APSlotDisconnectedHandler()
    GUI.AddText('Disconnected.')
    Lookups.Reset()
end
AP_REF.on_socket_disconnected = APSlotDisconnectedHandler -- there's no "slot disconnected", so this is half as good

function Archipelago.SlotDataHandler(slot_data)
    local player = Archipelago.GetPlayer()

    -- if the player connected to a different seed than we last connected to, reset everything so it will import properly
    if (Archipelago.seed ~= nil and player["seed"] ~= Archipelago.seed) or (Archipelago.slot ~= nil and player["slot"] ~= Archipelago.slot) then
        GUI.AddText('Resetting mods because seed or slot name was changed.')

        Archipelago.Reset()
        Lookups.Reset()
        Storage.Reset()
    end

    Archipelago.seed = player["seed"]
    Archipelago.slot = player["slot"]

    if slot_data.starting_weapon ~= nil then
        Archipelago.starting_weapon = slot_data.starting_weapon
    end

    if slot_data.death_link ~= nil then
        Archipelago.death_link = slot_data.death_link
    end

    Lookups.Load(string.lower(slot_data.difficulty))
    Storage.Load()

    GUI.AddTexts({
        { message='AP Difficulty: ' },
        { message=Lookups.difficulty:gsub("^%l", string.upper), color="green" }
    })

    for t, typewriter_name in pairs(slot_data.unlocked_typewriters) do
        -- Typewriters.AddUnlockedText(typewriter_name, "", true) -- true for "no_save_warning"
        Typewriters.Unlock(typewriter_name, "")
    end
end

function Archipelago.CanReceiveItems()
    -- wait until the player is in game, with AP connected, and with an available item box (that's not in use) -- and is not dead (because it will just spam the item received)
    -- before sending any items over
    return Scene.isInGame() and Archipelago.IsConnected() and not Scene.isUsingItemBox() and ItemBox.GetAnyAvailable() and not Scene.isGameOver()
end

function Archipelago.CanBeKilled()
    -- wait until the player is in game, with AP connected, before attempting to kill them from a deathlink
    return Scene.isInGame() and Archipelago.IsConnected()
end

-- sent by server when items are received
function APItemsReceivedHandler(items_received)
    return Archipelago.ItemsReceivedHandler(items_received)
end
AP_REF.on_items_received = APItemsReceivedHandler

function Archipelago.ItemsReceivedHandler(items_received)
    local itemsWaiting = {}

    -- add all of the randomized items to an item queue to wait for send
    for k, row in pairs(items_received) do
        Logging.Log("Item Received Handler :")
        Logging.Log("Item Received with index")
        Logging.Log(row["index"])
        Logging.Log("Last index saved :")
        Logging.Log(Storage.lastSavedItemIndex)
        -- if the index of the incoming item is greater than the index of our last item at save, check to see if it's randomized
        -- because ONLY non-randomized items escape the queue; everything else gets queued
        if row["index"] ~= nil and (not Storage.lastSavedItemIndex or row["index"] > Storage.lastSavedItemIndex) then
            local item_data = Archipelago._GetItemFromItemsData({ id = row["item"] })
            local location_data = nil
            local is_randomized = 1

            if row["location"] ~= nil and row["location"] > 0 then
                location_data = Archipelago._GetLocationFromLocationData({ id = row["location"] })

                if location_data ~= nil then
                    if location_data['raw_data'] ~= nil then
                        if location_data['raw_data']['randomized'] ~= nil then
                            is_randomized = location_data['raw_data']['randomized']
                        end
                    end
                end
            end

            if item_data["name"] and row["player"] ~= nil and is_randomized == 0 then
                Logging.Log("ReceiveItemStarted")
                Archipelago.ReceiveItem(item_data["name"], row["player"], is_randomized)
            else
                table.insert(Archipelago.itemsQueue, row)
                table.insert(itemsWaiting, item_data['name'])
            end
        end
    end

    if not Archipelago.CanReceiveItems() and #itemsWaiting > 0 then
        GUI.AddTexts({
            { message="Item(s) waiting for nearby item box: " },
            { message=table.concat(itemsWaiting, ", "), color=AP_REF.HexToImguiColor("AAAAAA") }
        })   
    end
end

function Archipelago.ProcessItemsQueue()
    -- if we're already processing items, wait for that to finish
    if Archipelago.isProcessingItems then
        return
    end

    if #Archipelago.itemsQueue == 0 then
        Archipelago.isProcessingItems = false
        return
    end

    Archipelago.isProcessingItems = true
    local items = Archipelago.itemsQueue
    Archipelago.itemsQueue = {}

    for k, row in pairs(items) do
        Logging.Log("ProcessItemsQueue :")
        Logging.Log("Item Received with index")
        Logging.Log(row["index"])
        Logging.Log("Last index saved :")
        Logging.Log(Storage.lastSavedItemIndex)



        -- if the index of the incoming item is greater than the index of our last item at save, accept it
        if row["index"] ~= nil and (not Storage.lastSavedItemIndex or row["index"] > Storage.lastSavedItemIndex) then
            local item_data = Archipelago._GetItemFromItemsData({ id = row["item"] })
            local location_data = nil
            local is_randomized = 1


            if row["location"] ~= nil and row["location"] > 0 then
                location_data = Archipelago._GetLocationFromLocationData({ id = row["location"] })

                if location_data ~= nil then
                    if location_data['raw_data'] ~= nil then
                        if location_data['raw_data']['randomized'] ~= nil then
                            is_randomized = location_data['raw_data']['randomized']
                        end
                    end
                end
            end


            if item_data["name"] and row["player"] ~= nil then
                Archipelago.ReceiveItem(item_data["name"], row["player"], is_randomized)
            end

            -- if the index is also greater than the index of our last received index, update last received
            if row["index"] ~= nil and (not Storage.lastReceivedItemIndex or row["index"] > Storage.lastReceivedItemIndex) then
                Storage.lastReceivedItemIndex = row["index"]
            end
        end
    end

    Storage.Update()
    Archipelago.isProcessingItems = false -- unset for the next bit of processing
end

-- sent by server when locations are checked (collect, etc.?)
function APLocationsCheckedHandler(locations_checked)
    return Archipelago.LocationsCheckedHandler(locations_checked)
end
AP_REF.on_location_checked = APLocationsCheckedHandler

function Archipelago.LocationsCheckedHandler(locations_checked)
    local player = Archipelago.GetPlayer()
    
    -- if we received locations that were collected out, mark them sent so we don't get anything from it
    for k, location_id in pairs(locations_checked) do
        local location_name = AP_REF.APClient:get_location_name(tonumber(location_id), player['game'])

        for k, loc in pairs(Lookups.locations) do
            if loc['name'] == location_name then
                loc['sent'] = true

                break
            end
        end
    end
end

-- called when server is sending JSON data of some sort?
function APPrintJSONHandler(json_rows)
    return Archipelago.PrintJSONHandler(json_rows)
end
AP_REF.on_print_json = APPrintJSONHandler

function Archipelago.PrintJSONHandler(json_rows)
    local player_sender, player_receiver, sender_number, receiver_number, item_id, location_id, item, location = nil
    local player = Archipelago.GetPlayer()

    -- if it's a hint, ignore it and return
    if #json_rows > 0 and json_rows[1]["text"] ~= nil and string.find(json_rows[1]["text"], "[Hint]") then
        return
    end

    for k, row in pairs(json_rows) do
        -- if it's a player id and no sender is set, it's the sender (so the player send it?)
        if row["type"] ~= nil and row["type"] == "player_id" and not player_sender then
            player_sender = AP_REF.APClient:get_player_alias(tonumber(row["text"]))
            sender_number = tonumber(row["text"])
        -- if it's a player id and the sender is set, it's the receiver (so the player receive it?)
        elseif row["type"] ~= nil and row["type"] == "player_id" and player_sender then
            player_receiver = AP_REF.APClient:get_player_alias(tonumber(row["text"]))        
            receiver_number = tonumber(row["text"])
        elseif row["type"] ~= nil and row["type"] == "item_id" then
            item_id = row["text"]           
            
            if (row["flags"] & 1) > 0 then
                item_color = "ce28f7"
            elseif (row["flags"] & 2) > 0 then
                item_color = AP_REF.APUsefulColor
            elseif (row["flags"] & 4) > 0 then
                item_color = AP_REF.APTrapColor
            else
                item_color = "06bda1"
            end
        elseif row["type"] ~= nil and row["type"] == "location_id" then
            location_id = row["text"]
        end
    end
    
    if player_sender and item_id and player_receiver and location_id then
        -- if we received, items received will give us the message
        -- if we sent, we want the text here
        -- everything else, don't care.
        if player['alias'] ~= nil and player_sender == player['alias'] then
            if not Storage.lastSavedItemIndex or row == nil or row["index"] == nil or row["index"] > Storage.lastSavedItemIndex then
                if player_receiver then --if there is a receiver ? So its not activated if the receiver is ourself ?
                    item = AP_REF.APClient:get_item_name(item_id, AP_REF.APClient:get_player_game(receiver_number))
                    location = AP_REF.APClient:get_location_name(location_id, player['game'])

                    GUI.AddSentItemText(player_sender, item, item_color, player_receiver, location)
                end
            end
        end
    end
end

-- called when we send a "Bounce" packet for sending to another game, for things like DeathLink
function APBouncedHandler(json_rows)
    return Archipelago.BouncedHandler(json_rows)
end
AP_REF.on_bounced = APBouncedHandler

function Archipelago.BouncedHandler(json_rows) -- Used to process Deathlink
    -- {
    --  "data" : {
    --      "source": "FuzzyLTTP",
    --      "cause": "FuzzyLTTP ran out of hearts.",
    --      "time": 346345764357
    --  },
    --  "cmd": "Bounced"
    --  "tags": { "DeathLink" }
    --  }
    -- }
    
    -- if deathlink isn't enabled, don't receive deathlinks
    if not Archipelago.death_link then
        return
    end

    if json_rows ~= nil and json_rows["tags"] ~= nil then
        -- why doesn't Lua have a way to "find" a value in a table? do we really have to create this from scratch?!
        -- Check if in the json there a deathlink tag 
        for k, tag in pairs(json_rows["tags"]) do
            if tag == "DeathLink" then
                if Archipelago.CanBeKilled() then
                    if json_rows["data"]["cause"] then
                        GUI.AddTexts({
                            { message="Deathlink received: " },
                            { message=tostring(json_rows["data"]["cause"]), color="green" }
                        })
                    else
                        GUI.AddTexts({
                            { message="Deathlink received from: " },
                            { message=tostring(json_rows["data"]["source"]), color="green" }
                        })
                    end
                    Archipelago.wasDeathLinked = true
                    Player.Kill()
                end
                break
            end
        end
    end
end

function Archipelago.IsItemLocation(location_data) -- so it reuse the info used to summon this function in _GetLocationFromLocationData ? -- used in Items.lua
    local location = Archipelago._GetLocationFromLocationData(location_data, true) -- include_sent_locations
    if not location then
        return false
    end
    return true
end

function Archipelago.IsLocationRandomized(location_data) -- so it reuse the info used to summon this function in _GetLocationFromLocationData ? -- asked from Items.lua
    local location = Archipelago._GetLocationFromLocationData(location_data, true) -- include_sent_locations
    if not location then
        return false
    end
    if location['raw_data']['randomized'] == 0 and not location['raw_data']['force_item'] then
        return false
    end
    return true
end

-- Never used ?? (Not in any LUA file)
function Archipelago.GetLocationName(location_data) -- so it reuse the info used to summon this function in _GetLocationFromLocationData ? 
    local location = Archipelago._GetLocationFromLocationData(location_data, true) -- include_sent_locations
    if not location then
        return ""
    end
    return location["name"]
end

function Archipelago.CheckForVictoryLocation(location_data) -- so it reuse the info used to summon this function in _GetLocationFromLocationData ? -- Used in Items.lua
    local location = Archipelago._GetLocationFromLocationData(location_data)
    if location ~= nil and location["raw_data"]["victory"] then
        Archipelago.SendVictory()
        return true
    end
    return false
end

function Archipelago.SendLocationCheck(location_data) -- so it reuse the info used to summon this function in _GetLocationFromLocationData ? -- Used in Items.lua
    local location = Archipelago._GetLocationFromLocationData(location_data)
    local location_ids = {}

    if not location then
        return false
    end

    location_ids[1] = location["id"]

    local result = AP_REF.APClient.LocationChecks(AP_REF.APClient, location_ids) -- Send an location check (even if "result" is not used anywhere)
    local sent_loc = location['raw_data']    

    for k, loc in pairs(Lookups.locations) do

        local exact_match = true

        -- check that the location is an exact match of the location's raw data that came back from the lookup
        for lk, lv in pairs(sent_loc) do
            if not loc[lk] or loc[lk] ~= sent_loc[lk] then
                exact_match = false
                break -- if not, skip
            end
        end

        if exact_match then
            loc['sent'] = true
            break
        end
    end

    return true
end

function Archipelago.SendDeathLink() --Process Deathlink (obviously)
    -- if deathlink isn't enabled, don't send deathlinks
    if not Archipelago.death_link then
        return
    end

    local player_self = Archipelago.GetPlayer()
    local timeOfDeath = math.floor(AP_REF.APClient:get_server_time())
    local playerName = tostring(player_self.alias)

    local deathLinkData = {
        time = timeOfDeath,
        cause = playerName .. " got smashed by a molded.",
        source = playerName
    }

    AP_REF.APClient:Bounce(deathLinkData, nil, nil, { "DeathLink" }) -- data, games, slots, tags
end

function Archipelago.ReceiveItem(item_name, sender, is_randomized) -- Process receiving items (by checking the game_id in the items.json file)
    Logging.Log("Reception item : ".. tostring(item_name))
    local item_ref = nil
    local item_number = nil
    local item_ammo = nil

    for k, item in pairs(Lookups.items) do
        if item.name == item_name then
            item_ref = item
            item_number = item.game_id
            
            -- if it's a weapon, look up its ammo as well and set to item_ammo
            if item.type == "Weapon" and item.ammo ~= nil then
                for k2, item2 in pairs(Lookups.items) do
                    if item2.name == item.ammo then
                        item_ammo = item2.game_id

                        break
                    end
                end
            end

            break
        end
    end
    if not item_ref then
    Logging.Log("Item inconnu dans Lookups.items : " .. tostring(item_name))
    end

    if item_ref and item_number then
        local itemId, bulletId, count = nil
        itemId = item_number

        if item_ref.type == "Weapon" then
            bulletId = item_ammo
        end

        count = item_ref.count

        if count == nil or count <= 0 then
            count = 1
        end

        if item_ref.progression == 1 then
            item_color = "ce28f7"
        elseif item_ref.type ~= "Lore" and item_ref.type ~= "Trap" then
            item_color = AP_REF.APUsefulColor
        elseif item_ref.type == "Trap" then
            item_color = AP_REF.APTrapColor
        else
            item_color = "06bda1"
        end
        
        local player_self = Archipelago.GetPlayer()
        local sentToBox = false

        if is_randomized > 0 then  
            sentToBox = true
            ItemBox.AddItem(itemId, count)
        end

        GUI.AddReceivedItemText(item_name, item_color, tostring(AP_REF.APClient:get_player_alias(sender)), tostring(player_self.alias), sentToBox) -- Send info to player that he received an item
    end
end

function Archipelago.SendVictory()
    AP_REF.APClient:StatusUpdate(AP_REF.AP.ClientStatus.GOAL)   
end

function Archipelago._GetItemFromItemsData(item_data) -- translate from item name to item data or some sort ?
    local player = Archipelago.GetPlayer()
    local translated_item = {}
    
    translated_item['name'] = AP_REF.APClient:get_item_name(item_data['id'], player['game'])
    log.debug("Translated Item (GETITEMFROMITEMSDATA)")
    log.debug(tostring(translated_item['name']))
    if not translated_item['name'] then
        return nil
    end

    translated_item['id'] = item_data['id']

    -- now that we have name and id, return them
    return translated_item
end


function TablesEqual(t1, t2)
    if t1 == nil or t2 == nil then return false end
    if #t1 ~= #t2 then return false end
    for i = 1, #t1 do
        if t1[i] ~= t2[i] then return false end
    end
    return true
end


function Archipelago._GetLocationFromLocationData(location_data, include_sent_locations) -- This is what is hell like
    local player = Archipelago.GetPlayer()

    include_sent_locations = include_sent_locations or false -- Set to true by some function above

    local translated_location = {}

    -- local scenario_suffix_hardcore = " (H)"

    if location_data['id'] and not location_data['name'] then
        location_data['name'] = AP_REF.APClient:get_location_name(location_data['id'], player['game']) -- What is 'id' ?
    end

    -- if the difficulty is hardcore, loop first looking for hardcore locations only so we can prioritize matching those
    -- if Lookups.difficulty == 'hardcore' then
    --     for k, loc in pairs(Lookups.locations) do
    --         if loc['hardcore'] ~= nil and loc['hardcore'] then -- if it doesn't have the hardcore attribute, it's not a hardcore location, skip it for later
    --             location_name_with_region_hardcore = loc['region'] .. scenario_suffix_hardcore .. " - " .. loc['name']
        
    --             if location_data['name'] == location_name_with_region_hardcore then
    --                 translated_location['name'] = location_name_with_region_hardcore
    --                 translated_location['raw_data'] = loc
        
    --                 break
    --             end
    --         end
    --     end
    -- end -- end if hardcore diff and looking for hardcore locations

    -- if it's not hardcore difficulty or if the location wasn't matched to a hardcore one, match standard locations instead
    if not translated_location['name'] then -- Check if its not hardcore difficulty
        for k, loc in pairs(Lookups.locations) do -- For K, loc in locations.json
            -- if not (loc['hardcore'] ~= nil and loc['hardcore']) then -- if it's a hardcore location, we want to skip it here, since we're only handling standards
            location_name_with_region = loc['region'] .. " - " .. loc['name']

            if location_data['name'] == location_name_with_region then
                translated_location['name'] = location_name_with_region
                translated_location['raw_data'] = loc
                break
            end
        end
    end -- end if standard diff and looking for standard locations

    -- Fallback: try to match location from object data if no name matched
    if not translated_location['name'] and (location_data['parent_object'] ~= nil or location_data['item_position'] ~= nil) then -- loc = An entry of location.json (it goes for every itteration to check it), location_data = the location the player has gotten
        for _, loc in pairs(Lookups.locations) do
            if loc['item_object'] == location_data['item_object'] and
               loc['folder_path'] == location_data['folder_path'] then

                if loc['parent_object'] == location_data['parent_object'] and loc['item_position'] == nil then
                    log.debug("If Done")
                    translated_location['name'] = loc['region'] .. " - " .. loc['name']
                    translated_location['raw_data'] = loc
                    break

                elseif TablesEqual(loc['item_position'], location_data['item_position']) and loc['parent_object'] == nil then
                    log.debug("Elseif Done")
                    translated_location['name'] = loc['region'] .. " - " .. loc['name']
                    translated_location['raw_data'] = loc
                    break
                end
            end
        end
    end
    Logging.Log("translated location name")
    Logging.Log(tostring(translated_location['name']))
    if translated_location['name'] ~= nil then
        translated_location['id'] = AP_REF.APClient:get_location_id(translated_location['name'], player['game'])
    end
    -- now that we have name and id, return them
    return translated_location
end

function Archipelago.Reset()
    Archipelago.seed = nil
    Archipelago.slot = nil
    Archipelago.starting_weapon = nil
    Archipelago.death_link = false
    Archipelago.itemsQueue = {}
end

return Archipelago
