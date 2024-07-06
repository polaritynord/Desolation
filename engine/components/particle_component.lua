local coreFuncs = require("coreFuncs")

local particleComponent = {}

function particleComponent.new(parent)
    local component = {
        parent = parent;
        name = "particleComponent";
        particles = {};
        enabled = true;
        layer = 3;
    }

    function component:newParticle(attributes)
        local particle = {
            type = attributes.type or "rect";
            position = attributes.position or {0, 0};
            size = attributes.size or {40, 40};
            rotation = attributes.rotation or 0;
            despawnTime = attributes.despawnTime or 1;
            color = attributes.color or {1,1,1,1};
            update = attributes.update or nil;
            sourceImage = attributes.sourceImage or Assets.defaultImages.missing_texture;
            timer = 0;
        }

        component.particles[#component.particles+1] = particle
        return particle
    end

    function component:update(delta)
        if not self.enabled or GamePaused then return end
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

    function component:draw()
        local objPos = self.parent.position
        local camera = CurrentScene.camera
        for _, particle in ipairs(self.particles) do
            local offsettedPos = {particle.position[1]+objPos[1], particle.position[2]+objPos[2]}
            local relativePos = coreFuncs.getRelativePosition(offsettedPos, camera)

            if particle.type == "rect" then
                love.graphics.push()
                    love.graphics.setColor(particle.color)
                    love.graphics.translate(relativePos[1], relativePos[2])
                    love.graphics.rotate(particle.rotation+self.parent.rotation)
                    love.graphics.rectangle("fill", -particle.size[1]/2*camera.zoom, -particle.size[2]/2*camera.zoom, particle.size[1]*camera.zoom, particle.size[2]*camera.zoom)
                    love.graphics.setColor(1, 1, 1, 1)
                love.graphics.pop()
            elseif particle.type == "image" then
                love.graphics.setColor(particle.color)
                local src = particle.sourceImage
                local width = src:getWidth() ;  local height = src:getHeight()
                love.graphics.draw(
                    src, relativePos[1], relativePos[2], self.parent.rotation+particle.rotation,
                    particle.size[1]*camera.zoom, particle.size[2]*camera.zoom, width/2, height/2
                )
                love.graphics.setColor(1, 1, 1, 1)
            elseif particle.type == "circle" then
                love.graphics.push()
                    love.graphics.setColor(particle.color)
                    love.graphics.translate(relativePos[1], relativePos[2])
                    love.graphics.rotate(particle.rotation+self.parent.rotation)
                    love.graphics.circle("fill", 0, 0, particle.size[1])
                    love.graphics.setColor(1, 1, 1, 1)
                love.graphics.pop()
            end
        end
        CurrentScene.particleCount = CurrentScene.particleCount + #self.particles
    end

    return component
end

return particleComponent