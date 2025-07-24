local Lookups = {}

Lookups.filepath = Manifest.mod_name .. "/"
Lookups.items = {}
Lookups.all_items = {}
Lookups.locations = {}
Lookups.typewriters = {}
Lookups.difficulty = nil

function Lookups.Load(difficulty)
    -- If this was already loaded and not cleared, don't load again
    if #Lookups.items > 0 and #Lookups.locations > 0 then
        return
    end

    Lookups.difficulty = difficulty

    local item_file = Lookups.filepath .. "/items.json"
    local location_file = Lookups.filepath .. "/locations.json"
    local location_hardcore_file = Lookups.filepath .. "/locations_hardcore.json"
    local typewriter_file = Lookups.filepath .. "/typewriters.json"

    Lookups.items = json.load_file(item_file) or {}
    Lookups.locations = json.load_file(location_file) or {}
    Lookups.typewriters = json.load_file(typewriter_file) or {}

    -- have to check for hardcore file in case it's not there
    local hardcore_locations = json.load_file(location_hardcore_file) or {}


    Lookups.locations_by_id = {}
    for _, loc in pairs(Lookups.locations) do
        if loc.original_item then
            Lookups.locations_by_id[loc.original_item] = loc
        end
    end

    if hardcore_locations then
        for k, v in pairs(hardcore_locations) do
            if not v['remove'] then -- ignore "remove" locations because they're for generation only
                v['hardcore'] = true
                table.insert(Lookups.locations, v)
            end
        end
    end
end





function Lookups.Reset()
    Lookups.items = {}
    Lookups.locations = {}
    Lookups.typewriters = {}
    Lookups.difficulty = nil
    Lookups.locations_by_id = {}
end

return Lookups
