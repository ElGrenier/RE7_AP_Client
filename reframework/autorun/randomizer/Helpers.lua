local Helpers = {}

function Helpers.gameObject(obj_name)
    return scene:call("findGameObject(System.String)", obj_name)
end

function Helpers.transform(obj)
    return obj:call("get_Transform")
end

function Helpers.old_component(obj, component_namespace)
    return obj:call("getComponent(System.Type)", sdk.typeof(sdk.game_namespace(component_namespace)))
end

-- getting transform children is kinda annoying, so here's a helper for it
function Helpers.get_children(xform)
	local children = {}
	local child = xform:call("get_Child")
	while child do 
		table.insert(children, child)
		child = child:call("get_Next")
	end
	return children[1] and children
end

function Helpers.wait(seconds) 
    local start = os.time() 
    repeat until os.time() > start + seconds 
end

function Helpers.Round(number)
	return math.ceil(number * 100) / 100 -- two decimal places
end

local known_typeofs = {}
function Helpers.component(game_object, type_name)
    local t = known_typeofs[type_name] or sdk.typeof(type_name)

    if t == nil then
        return nil
    end

    known_typeofs[type_name] = t
    return game_object:call("getComponent(System.Type)", t)
end


function Helpers.create_posv3(x,y,z)
    local posv3 = ValueType.new(sdk.find_type_definition("via.vec3"))
    posv3:call(".ctor(System.Single, System.Single, System.Single)", x, y, z)
    return posv3
end

return Helpers