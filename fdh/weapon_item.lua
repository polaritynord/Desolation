local transformComponent = require("engine.components.transform_component")

local weaponItem = {}

function weaponItem.new(weaponData, parent)
    local instance = {
        name = "weaponItem";
        parent = parent;
        tree = {};
    }
    instance.transformComponent = transformComponent.new(instance)
    --Variables
    instance.velocity = 0
    instance.rotVelocity = 0
    instance.rotAcceleration = math.pi*8
    instance.realRot = 0
    instance.acceleration = 2000
    instance.distanceToPlayer = 0
    
    --Funcs
    function instance:load()
        print("test")
    end

    function instance:update()

    end

    function instance:draw()

    end

    return instance
end

return weaponItem