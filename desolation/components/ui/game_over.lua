local gameOver = ENGINE_COMPONENTS.scriptComponent.new()

function gameOver:load()
    local ui = self.parent.UIComponent
    ui.rectangle = ui:newRectangle(
        {
            size = {960, 540};
            color = {1, 0, 0, 0};
        }
    )
end

function gameOver:update(delta)
    local player = CurrentScene.player
    if player.health > 0 then return end
    local ui = self.parent.UIComponent
    ui.rectangle.color[4] = ui.rectangle.color[4] + (0.6-ui.rectangle.color[4])*8*delta
end

return gameOver