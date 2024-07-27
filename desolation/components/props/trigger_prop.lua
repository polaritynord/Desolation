local coreFuncs = require "coreFuncs"
local triggerProp = ENGINE_COMPONENTS.scriptComponent.new()
local triggerEvents = require("desolation.components.trigger_events")

local function customDraw(comp)
    if GetGlobal("draw_triggers") < 1 then return end
    local prop = comp.parent
    local camera = CurrentScene.camera
    local pos = coreFuncs.getRelativePosition(prop.position, camera)
    love.graphics.push()
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.translate(pos[1], pos[2])
        love.graphics.rectangle("fill", 0, 0, prop.size[1]*camera.zoom, prop.size[2]*camera.zoom)
        love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function triggerProp:load()
    local prop = self.parent
    prop.imageComponent = ENGINE_COMPONENTS.imageComponent.new(prop)
    prop.imageComponent.draw = customDraw
    if prop.size == nil then prop.size = {80, 80} end
    if prop.destroyInTrigger == nil then prop.destroyInTrigger = false end
end

function triggerProp:update(_)
    if self.parent.event == nil then return end
    local playerPos = table.new(CurrentScene.player.position)
    playerPos[1] = playerPos[1]-24
    playerPos[2] = playerPos[2]-24
    local propPos = self.parent.position
    if coreFuncs.aabbCollision(playerPos, propPos, {48, 48}, self.parent.size) then
        triggerEvents[self.parent.event](self.parent)
        --Destroy object
        if self.parent.destroyInTrigger then
            table.removeValue(CurrentScene.props.tree, self.parent)
        end
    end
end

return triggerProp