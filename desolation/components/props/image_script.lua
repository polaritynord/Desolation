local imageScript = ENGINE_COMPONENTS.scriptComponent.new()

function imageScript:load()
    local prop = self.parent
    prop.imageComponent = ENGINE_COMPONENTS.imageComponent.new(prop, Assets.mapImages[prop.source] or Assets.images[prop.source] or Assets.defaultImages.missing_texture)
    if prop.color ~= nil then
        prop.imageComponent.color = prop.color
    end
    prop.imageComponent.layer = 3
end

function imageScript:update(delta)
    
end

return imageScript