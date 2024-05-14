local transformComponent = require "engine.components.transform_component"

local object = {}

function object.new(parent)
    local o = {
        name = "Object";
        parent = parent;
        tree = {}
    }
    o.transformComponent = transformComponent.new(o)

    function o:getPosition()
        return {x=self.transformComponent.x, y=self.transformComponent.y}
    end

    function o:addChild(obj)
        self.tree[#self.tree+1] = obj
        self[obj.name] = obj
    end

    function o:load()
        if self.script then self.script:load() end
    end

    function o:update(delta)
        if self.script and self.script.update then self.script:update(delta) end
        if self.particleComponent then self.particleComponent:update(delta) end
        for _, v in ipairs(self.tree) do
            v:update(delta)
        end
    end

    function o:draw()
        if self.imageComponent then
            --self.imageComponent:draw()
            CurrentScene.drawLayers[self.imageComponent.layer][#CurrentScene.drawLayers[self.imageComponent.layer]+1] = self.imageComponent
        end
        if self.particleComponent then self.particleComponent:draw() end
        for _, v in ipairs(self.tree) do
            v:draw()
        end
    end

    return o
end

return object