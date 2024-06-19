local hitmarkerScript = ENGINE_COMPONENTS.scriptComponent.new()

function hitmarkerScript:load()
    local hitmarker = self.parent
    hitmarker.UIComponent = ENGINE_COMPONENTS.UIComponent:new(hitmarker)
    --add element
    hitmarker.UIComponent:newImage(
        {
            source = Assets.images["hud_hitmarker"];
            rotation = math.atan2(hitmarker.sourcePos[2], hitmarker.sourcePos[1]);
        }
    )
end

function hitmarkerScript:update(delta)
    
end

return hitmarkerScript