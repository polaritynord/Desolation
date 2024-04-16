local prop = require("scripts.props.prop")
local coreFuncs = require("coreFuncs")
local assets = require("assets")

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
            color = attributes.color or {1,1,1,1};
            update = attributes.update or nil;
            sourceImage = attributes.sourceImage or nil;
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
            local offsettedPos = {particle.position[1]+self.position[1], particle.position[2]+self.position[2]}
            local relativePos = coreFuncs.getRelativePosition(offsettedPos, Camera)

            if particle.type == "rect" then
                love.graphics.push()
                love.graphics.setColor(particle.color)
                love.graphics.translate(relativePos[1], relativePos[2])
                love.graphics.rotate(particle.rotation+self.rotation)
                love.graphics.rectangle("fill", -particle.size[1]/2*Camera.zoom, -particle.size[2]/2*Camera.zoom, particle.size[1]*Camera.zoom, particle.size[2]*Camera.zoom)
                love.graphics.pop()
            elseif particle.type == "image" then
                local src = assets.images.player.body
                local width = src:getWidth() ;  local height = src:getHeight()
                love.graphics.draw(
                    src, relativePos[1], relativePos[2], self.rotation,
                    particle.size[1]*Camera.zoom, particle.size[2]*Camera.zoom, width/2, height/2
                )
            end
        end
    end

    return newProp
end

return particleProp