local prop = require("scripts.props.prop")
local coreFuncs = require("coreFuncs")

local particleProp = {}

function particleProp.new()
    local newProp = prop.new()
    --Variables
    newProp.particles = {}

    --Functions
    function newProp:newParticle(attributes)
        local particle = {
            type = attributes.type or "rect";
            position = attributes.position or {0, 0};
            size = attributes.size or {40, 40};
            rotation = attributes.rotation or 0;
            despawnTime = attributes.despawnTime or 1;
            timer = 0;
        }

        newProp.particles[#newProp.particles+1] = particle
    end

    function newProp:update(delta)
        for i, particle in ipairs(self.particles) do
            --Particle despawning
            particle.timer = particle.timer + delta
            if particle.timer > particle.despawnTime then
                table.remove(self.particles, i)
            end
            --Custom update function
            if particle.update then particle.update(particle, delta) end
        end
    end

    function newProp:draw()
        for _, particle in ipairs(self.particles) do
            if particle.type == "rect" then
                local offsettedPos = {particle.position[1]+self.position[1], particle.position[2]+self.position[2]}
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