local coreFuncs = require("coreFuncs")

local image = {}

function image.new()
    local instance = {
        quad = nil;
        source = Assets.defaultImages["missing_texture"],
        position = {0, 0};
        quadOriginPos = {0, 0};
        quadShearSize = {32, 32};
        scale = {1, 1};
        rotation = 0;
        parentComp = nil;
        color = {1, 1, 1, 1};
        enabled = true;
    }

    function instance:draw()
        local src = self.source
        if src == nil then return end
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)

        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        if self.quad == nil then
            love.graphics.draw(
                src, pos[1], pos[2], self.rotation,
                self.scale[1], self.scale[2], width/2, height/2
            )
        else
            love.graphics.draw(
                src, self.quad, pos[1], pos[2], self.rotation, self.scale[1], self.scale[2]
            )
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return image