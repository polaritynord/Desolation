local imageScript = ENGINE_COMPONENTS.scriptComponent.new()

function imageScript:load()
    local prop = self.parent
    prop.imageComponent = ENGINE_COMPONENTS.imageComponent.new(prop, Assets.mapImages[prop.source] or Assets.defaultImages.missing_texture)
end

function imageScript:update(delta)
    
end

return imageScript