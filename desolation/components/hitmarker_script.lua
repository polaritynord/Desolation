local hitmarkerScript = ENGINE_COMPONENTS.scriptComponent.new()

function hitmarkerScript:load()
    local hitmarker = self.parent
    hitmarker.UIComponent = ENGINE_COMPONENTS.UIComponent:new(hitmarker)
    --add element
    hitmarker.UIComponent.img = hitmarker.UIComponent:newImage(
        {
            source = Assets.images["hud_hitmarker"];
            scale = {1, 2};
            color = {1, 0, 0, 1};
        }
    )
end

function hitmarkerScript:update(delta)
    local hitmarker = self.parent
    local img = hitmarker.UIComponent.img
    -- Change scale
    img.scale[1] = img.scale[1] - 8 * delta
    img.scale[2] = img.scale[2] - 8 * delta
    -- Despawn
    if img.scale[1] < 0.2 then
        table.removeValue(CurrentScene.hud.tree, hitmarker)
    end
end

return hitmarkerScript