
local object = {}

function object.new(parent)
    local o = {
        name = "object";
        parent = parent;
        tree = {};
        components = {};
        position = {0, 0};
        scale = {1, 1};
        rotation = 0;
    }

    function o:addChild(obj)
        self.tree[#self.tree+1] = obj
        self[obj.name] = obj
    end

    function o:addComponent(comp)
        comp.parent = self
        self.components[#self.components+1] = comp
        self[comp.name] = comp
    end

    function o:load()
        for _, component in ipairs(self.components) do
            if component.load then component:load() end
        end
        --if self.script then self.script:load() end
    end

    function o:update(delta)
        --if self.script and self.script.update then self.script:update(delta) end
        --if self.UIComponent then self.UIComponent:update(delta) end
        --if self.particleComponent then self.particleComponent:update(delta) end
        for _, v in ipairs(self.components) do
            if v.update then v:update(delta) end
        end
        for _, v in ipairs(self.tree) do
            v:update(delta)
        end
    end

    function o:draw()
        if self.imageComponent then
            CurrentScene.drawLayers[self.imageComponent.layer][#CurrentScene.drawLayers[self.imageComponent.layer]+1] = self.imageComponent
        end
        if self.UIComponent and self.UIComponent.enabled then
            CurrentScene.uiLayer[#CurrentScene.uiLayer+1] = self.UIComponent
        end
        if self.particleComponent and self.particleComponent.enabled then
            CurrentScene.particleLayer[#CurrentScene.particleLayer+1] = self.particleComponent
        end
        for _, v in ipairs(self.tree) do
            v:draw()
        end
    end

    return o
end

return object