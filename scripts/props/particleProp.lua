local prop = require("scripts.props.prop")
local coreFuncs = require("coreFuncs")

local particleProp = {}

function particleProp.new()
    local newProp = prop.new()
    --Variables
    newProp.particles = {}

    --Functions
    function newProp:update(delta)
        for _, particle in ipairs(self.particles) do
            if particle.update then particle.update(particle, delta) end
        end
    end

    function newProp:draw()
        for _, particle in ipairs(self.particles) do
            if particle.type == "rect" then
                local offsettedPos = {pos+self.position[1], particle.position[2]+self.position[2]}
                local relativePos = coreFuncs.getRelativePosition(offsettedPos, Camera)
                love.graphics.push()
                love.graphics.translate(relativePos[1], relativePos[2])
                love.graphics.rotate(particle.rotation+self.rotation)
                love.graphics.rectangle("fill", -particle.size[1]/2, -particle.size[2]/2, particle.size[1], particle.size[2])
                love.graphics.pop()
            end
        end
    end

    return newProp
end

return particleProp