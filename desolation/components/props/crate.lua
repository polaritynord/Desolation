local crateScript = ENGINE_COMPONENTS.scriptComponent.new()

function crateScript:load()
    local crate = self.parent
    --load image if nonexistant
    if Assets.mapImages["prop_crate"] == nil then
        Assets.mapImages["prop_crate"] = love.graphics.newImage("desolation/assets/images/props/crate.png")
    end
    crate.imageComponent = ENGINE_COMPONENTS.imageComponent.new(crate, Assets.mapImages["prop_crate"])
    crate.scale = {2.5, 2.5}
end

function crateScript:update(delta)
    
end

return crateScript