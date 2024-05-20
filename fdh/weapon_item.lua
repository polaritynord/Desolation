local object = require("engine.object")

local weaponItem = {}

function weaponItem.new(weaponData, parent)
    local instance = object.new(parent)
    --Variables
    instance.velocity = 0
    instance.rotVelocity = 0
    instance.rotAcceleration = math.pi*8
    instance.realRot = 0
    instance.acceleration = 2000
    instance.distanceToPlayer = 0
end

return weaponItem