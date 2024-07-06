local gameOver = ENGINE_COMPONENTS.scriptComponent.new()

function gameOver:load()
    local ui = self.parent.UIComponent
    ui.rectangle = ui:newRectangle(
        {
            size = {960, 540};
            color = {0, 0, 0, 1};
        }
    )
end

function gameOver:update(delta)
    local player = CurrentScene.player
    local ui = self.parent.UIComponent
    if player.health > 0 then
        --opening black fade away
        ui.rectangle.color[4] = ui.rectangle.color[4] - delta
        if ui.rectangle.color[4] < 0 then ui.rectangle.color[4] = 0 end
    else
        --game over screen background
        ui.rectangle.color = {1, 0, 0, ui.rectangle.color[4]}
        ui.rectangle.color[4] = ui.rectangle.color[4] + (0.6-ui.rectangle.color[4])*8*delta
    end
end

return gameOver